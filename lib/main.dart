import 'logic/boxcommunicator.dart';
import 'data/task.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'Screens/settings.dart';

void main() => runApp(MyApp()); //runs the main application widget

/// This is the main application widget.
class MyApp extends StatelessWidget {
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

<<<<<<< HEAD
/// This is the private State class that goes with BaseAppWidget.
class _BaseAppWidgetState extends State<BaseAppWidget> {
  @override
  Widget build(BuildContext context) {
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
                new Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: horizontalPadding),
                  //set a padding of 1% of screen size on all sides
                  child: Column(
                    children: [
                      Row(
                        //Make a Row with a settings button on the right side
                        mainAxisAlignment: MainAxisAlignment
                            .end, //align the button to the right side
                        children: [
                          IconButton(
                              //button initialisation
                              icon: Icon(
                                Icons.settings,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                // this is what happens when the settings button is pressed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SettingsPage()), // We use the Navigator to Route to the settings page wich is located in a new .dart file
                                );
                              }),
                        ],
                      ),
                      Text('Home') //dummy widget
                    ],
                  ),
                ),
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
=======
class _MyHomePageState extends State<MyHomePage> {
  Future<Album> _futureAlbum;

  // final Connectivity _connectivity = new Connectivity();
  // StreamSubscription<ConnectivityResult> _connectivitySubscription;
  //var subscription;
  String _connectionStatus;
  String _connection;
  
  
  @override
  void initState() async {
    super.initState();
    _futureAlbum = BoxCommunicator.fetchAlbum();
    // _connectivitySubscription =
    // subscription =
    //     _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
    //   setState(() => _connectionStatus = result.toString());
    //});
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    _connection = "mobile";
  } else if (connectivityResult == ConnectivityResult.wifi) {
    _connection = "wifi";
  } else {
    _connection = "nothing";
  }
  }

  @override
  void dispose() {
    // subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'The following data came from the API:',
            ),
            FutureBuilder<Album>(
              future: _futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.title);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              }
            ),
            Text(_connection) 
          ],
        ),
      )
>>>>>>> 62833f5 (wip, api call works, wifi connections doesnt)
    );
  }
}
