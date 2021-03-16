import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/download_update_state.dart';
import 'package:data_offloading_app/provider/poslist_state.dart';
import 'package:data_offloading_app/provider/downloadall_state.dart';
import 'package:data_offloading_app/provider/tasklist_state.dart';
import 'package:data_offloading_app/widgets/home.dart';
import 'package:data_offloading_app/widgets/map.dart';
import 'package:data_offloading_app/widgets/tasks.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter/services.dart';
import 'package:data_offloading_app/logic/stats.dart';

var mainKeys = {"mapKey": GlobalKey(), "tasks": GlobalKey()};

void main() async {
  //initialize hive, the nosql database
  await Hive.initFlutter();
  Box storage = await Hive.openBox('storage');
  Stats.setBox(storage);

  // This Widget inits the showcase of the functionalities of the app. After first startup it never appears again
  Widget showCaseStart(Builder builder) {
    return ShowCaseWidget(
        onStart: (index, key) {
          log('onStart: $index, $key');
        },
        onComplete: (index, key) {
          log('onComplete: $index, $key');
        },
        onFinish: () {
          storage.put('guideFinished', true);
          log('finished');
        },
        autoPlay: false,
        builder: builder);
  }

  MultiProvider mainApp = MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BoxConnectionState()),
      ChangeNotifierProvider(create: (_) => TaskListProvider()),
      ChangeNotifierProvider(create: (_) => DownloadAllState()),
      ChangeNotifierProvider(create: (_) => PosListProvider()),
      ChangeNotifierProvider(create: (_) => DownloadUploadState()),
    ],
    builder: (context, child) => MainApp(),
  );

  runApp(storage.get('guideFinished', defaultValue: false)
      ? mainApp
      : showCaseStart(
          Builder(builder: (context) => mainApp),
        ));
}

/// This is the main application widget.
class MainApp extends StatefulWidget {
  // const MyApp({Key key}) : super(key: key);
  static const String _title = 'Data Offloading App';

  // updates connection state
  static void getConnectionState(BuildContext context) async {
    BoxConnectionState boxConnection = context.read<BoxConnectionState>();
    Connection state = boxConnection.connectionState;
    String name = await WifiInfo().getWifiName();
    BoxCommunicator boxCommunicator = BoxCommunicator();

    Box storage = await Hive.openBox('storage');
    List knownWifis = storage.get('knownWifis', defaultValue: []);

    switch (state) {
      case Connection.NONE:
        if (name == "Sensorbox") {
          if (Platform.isAndroid) {
            //force wifi so that we do not have problems with mobile data interfering api requests
            WiFiForIoTPlugin.forceWifiUsage(true);
          }
          boxConnection.connectedToSensorbox();
          boxCommunicator.downloadData(context);
          break;
        } else if (name != null) {
          // connected to a wifi
          if (knownWifis.contains(name)) {
            boxConnection.connectedToKnownWifi();
            boxCommunicator.uploadToBackend(context);
          } else {
            boxConnection.connectedToUnknownWifi();
          }
        }
        break;

      case Connection.SENSORBOX:
        if (name == null)
          boxConnection.disconnected();
        else if (name != "Sensorbox") {
          if (knownWifis.contains(name)) {
            boxConnection.connectedToKnownWifi();
            boxCommunicator.uploadToBackend(context);
          } else {
            boxConnection.connectedToUnknownWifi();
          }
        }
        break;

      case Connection.KNOWN_WIFI:
        if (name == null)
          boxConnection.disconnected();
        else if (name == "Sensorbox") {
          boxConnection.connectedToSensorbox();
          boxCommunicator.downloadData(context);
        }
        break;

      case Connection.UNKNOWN_WIFI:
        if (name == null)
          boxConnection.disconnected();
        else if (name == "Sensorbox") {
          boxConnection.connectedToSensorbox();
          boxCommunicator.downloadData(context);
        } else if (knownWifis.contains(name)) {
          boxConnection.connectedToKnownWifi();
          boxCommunicator.uploadToBackend(context);
        }
        break;
    }
  }

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Timer _timer;

  void getPermission() async {
    if (Platform.isAndroid) {
      print('Checking Android permissions');
      var status = await Permission.location.status;
      // Blocked?
      if (status.isUndetermined || status.isDenied || status.isRestricted) {
        // Ask the user to unblock
        if (await Permission.location.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          print('Location permission granted');
        } else {
          print('Location permission not granted');
        }
      } else {
        print('Permission already granted (previous execution?)');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      MainApp.getConnectionState(context);
    });
    getPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  List<Widget> _pages = [Map(), Home(), Tasks()];

  int _selectedIndex = 1;
  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.green);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    List<GlobalKey<State<StatefulWidget>>> globalKeyList = [];
    homeKeys.values.forEach((val) => globalKeyList.add(val));
    mainKeys.values.forEach((val) => globalKeyList.add(val));

    //startup of the showcase on first app start
    if (Hive.box('storage').get('guideFinished', defaultValue: false) ==
        false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase(globalKeyList);
      });
    }

    /// Creates a custom ShowCase Widget. Standard widgets shown when bool 'guideFinished' evaluates to true.
    Widget customShowCase(
        GlobalKey key, String title, String description, Widget child) {
      return Hive.box('storage').get('guideFinished', defaultValue: false)
          ? child
          : Showcase(
              key: key, title: title, description: description, child: child);
    }

    return MaterialApp(
        title: MainApp._title,
        theme: ThemeData(
          primarySwatch: Colors.green,
          //Theme colors of the app
        ),
        home: MaterialApp(
          home: new Scaffold(
            body: SafeArea(
              child: _pages.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              //our navigation bar at the bottom
              items: [
                BottomNavigationBarItem(
                    icon: customShowCase(
                        mainKeys["mapKey"],
                        "Karte",
                        "Suchen Sie nach Sensorboxen in ihrer Nähe",
                        Icon(Icons.map)),
                    label: "Map"),
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: customShowCase(
                        mainKeys["tasks"],
                        "Aufgaben",
                        "Schließen Sie Aufgaben einer verbundenen Sensorbox ab",
                        Icon(Icons.assignment_turned_in)),
                    label: "Aufgaben"),
              ],
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.lightGreen,
              onTap: _onItemTap,
              currentIndex: _selectedIndex,
            ),
          ),
        ));
  }
}
