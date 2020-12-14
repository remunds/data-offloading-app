import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

import 'map.dart';

import 'provider/box_connection_state.dart';
import 'widgets/home.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BoxConnectionState()),
      ],
      builder: (context, child) => const MyApp(),
    ));
// child: const MyApp())); //runs the main application widget

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  static const String _title = 'Data Offloading App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.green, //Theme color of the app
      ),
      home: BaseAppWidget(), //"home" page
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class BaseAppWidget extends StatefulWidget {
  @override
  _BaseAppWidgetState createState() =>
      _BaseAppWidgetState(); //Because the apps basic structure is stateful and never changes its state we have to create a state.
}

/// This is the private State class that goes with BaseAppWidget.
class _BaseAppWidgetState extends State<BaseAppWidget> {
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
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      Home.getConnectionState(context);
    });
    getPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // Home.getConnectionState(context);
    double verticalPadding = MediaQuery.of(context).size.height * 0.01;
    double horizontalPadding = MediaQuery.of(context).size.width *
        0.01; // Getting the pixels to use for the 1%-padding

    return new MaterialApp(
      home: DefaultTabController(
        // Initializing a tab controller with 3 tabs to have swipe functionality between screens with a length of 3 tabs
        length: 3,
        child: new Scaffold(
          body: SafeArea(
            // SafeArea used to avoid that content lies behind the notification barr
            child: TabBarView(
              //This Widget is to fill the screen with content. We have an array which length equals the length of TabController. Every array item is a new page.
              children: [
                new Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: horizontalPadding),
                  //set an padding of 1% of screen size on all sides
                  child: Column(
                    children: [Text('Map')],
                  ),
                ),
                Home(),
                new Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: horizontalPadding),
                  //set an padding of 1% of screen size on all sides
                  child: Column(
                    children: [Text('Tasks')], //dummy widget
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: new TabBar(
            //our navigation bar at the botton
            tabs: [
              // array of tabs, are icons enough?
              Tab(
                icon: new Icon(Icons.map),
              ),
              Tab(
                icon: new Icon(Icons.home),
              ),
              Tab(
                icon: new Icon(Icons.assignment_turned_in),
              ),
            ],
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
