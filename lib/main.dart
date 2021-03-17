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
import 'package:flutter_background/flutter_background.dart';
import 'package:dart_ping/dart_ping.dart';

import 'Screens/settings.dart';

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

  bool success = await FlutterBackground.initialize(
      androidConfig: await SettingsPage.getAndroidConfig());
  if (success) {
    await FlutterBackground.enableBackgroundExecution();
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

  /// Tests whether we are connected to a sensorbox or another wifi
  static Future<Connection> _checkWifiConnection() async {
    // ping to the sensorbox to see if it's available
    final pingBox = Ping(
      BoxCommunicator.boxRawIP,
      count: 1,
      timeout: 1,
      interval: 1,
      ipv6: false,
    );
    List<PingData> boxResponses = await pingBox.stream.toList();
    //if the response was valid -> we are connected to a sensorbox
    for (PingData d in boxResponses) {
      if (d.error == null && d.response != null) {
        return Connection.SENSORBOX;
      }
    }
    //else try the backend
    final pingBackend = Ping(
      BoxCommunicator.backendRawIP,
      count: 1,
      timeout: 1,
      interval: 1,
      ipv6: false,
    );
    // if the backend response was valid -> we are connected to another wifi network
    List<PingData> backendResponses = await pingBackend.stream.toList();
    for (PingData d in backendResponses) {
      if (d.error == null && d.response != null) {
        return Connection.UNKNOWN_WIFI;
      }
    }
    //if backend and box are not reachable -> our wifi has no connection
    return Connection.NONE;
  }

  ///Checks whether we are connected to wifi, mobile data, or not at all
  ///using the connectivitymanager from android (natively)
  static Future<bool> _connectedToWifi() async {
    const MethodChannel _channel = const MethodChannel('ConnectionManager');
    String connectionType = await _channel.invokeMethod('getConnectionType');
    if (connectionType == "WIFI") {
      return true;
    }
    return false;
  }

  /// Updates connection state and call functions depending on the state
  static void getConnectionState(BuildContext context) async {
    BoxConnectionState boxConnection = context.read<BoxConnectionState>();
    Connection oldState = boxConnection.connectionState;

    //1. check if connected to wifi
    if (!await _connectedToWifi()) {
      boxConnection.disconnected();
      return;
    }

    //2. check whether the connection is wifi or Sensorbox
    Connection currConnection = await _checkWifiConnection();
    print(currConnection);

    BoxCommunicator boxCommunicator = BoxCommunicator();

    Box storage = await Hive.openBox('storage');

    // if we are connected to a wifi network, check if it is known,
    // or if it is allowed to upload in all wifis
    if (currConnection == Connection.UNKNOWN_WIFI) {
      String name = await WifiInfo().getWifiName();
      List knownWifis = storage.get('knownWifis', defaultValue: []);
      bool userAllowsAllWifis =
          storage.get('uploadInAllWifis', defaultValue: true);
      if (knownWifis.contains(name) || userAllowsAllWifis) {
        currConnection = Connection.KNOWN_WIFI;
      }
    }

    // this switch case checks whether the connection changed to the last time we checked
    // if it did it calls the corresponding functions accordingly.
    switch (oldState) {
      case Connection.NONE:
        if (currConnection == Connection.SENSORBOX) {
          if (Platform.isAndroid) {
            //force wifi so that we do not have problems with mobile data interfering api requests
            WiFiForIoTPlugin.forceWifiUsage(true);
          }
          boxConnection.connectedToSensorbox();
          boxCommunicator.downloadData(context);
        } else if (currConnection == Connection.KNOWN_WIFI) {
          boxConnection.connectedToKnownWifi();
          boxCommunicator.uploadToBackend(context);
        } else if (currConnection == Connection.UNKNOWN_WIFI) {
          boxConnection.connectedToUnknownWifi();
        }
        break;

      case Connection.SENSORBOX:
        if (currConnection == Connection.NONE)
          boxConnection.disconnected();
        else if (currConnection == Connection.KNOWN_WIFI) {
          boxConnection.connectedToKnownWifi();
          boxCommunicator.uploadToBackend(context);
        } else if (currConnection == Connection.UNKNOWN_WIFI) {
          boxConnection.connectedToUnknownWifi();
        }
        break;

      case Connection.KNOWN_WIFI:
        if (currConnection == Connection.NONE)
          boxConnection.disconnected();
        else if (currConnection == Connection.SENSORBOX) {
          if (Platform.isAndroid) {
            //force wifi so that we do not have problems with mobile data interfering api requests
            WiFiForIoTPlugin.forceWifiUsage(true);
          }
          boxConnection.connectedToSensorbox();
          boxCommunicator.downloadData(context);
        } else if (currConnection == Connection.UNKNOWN_WIFI) {
          boxConnection.connectedToUnknownWifi();
        }
        break;

      case Connection.UNKNOWN_WIFI:
        if (currConnection == Connection.NONE)
          boxConnection.disconnected();
        else if (currConnection == Connection.SENSORBOX) {
          if (Platform.isAndroid) {
            //force wifi so that we do not have problems with mobile data interfering api requests
            WiFiForIoTPlugin.forceWifiUsage(true);
          }
          boxConnection.connectedToSensorbox();
          boxCommunicator.downloadData(context);
        } else if (currConnection == Connection.KNOWN_WIFI) {
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

  List<Widget> _pages = [FMap(), Home(), Tasks()];

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
