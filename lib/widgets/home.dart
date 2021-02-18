import 'package:camera/camera.dart';
import 'package:data_offloading_app/Screens/aboutus.dart';
import 'package:data_offloading_app/Screens/achievements.dart';
import 'package:data_offloading_app/Screens/foto_capturing.dart';
import 'package:data_offloading_app/Screens/manual.dart';
import 'package:data_offloading_app/Screens/settings.dart';
import 'package:data_offloading_app/Screens/statistics.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/download_update_state.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<CameraDescription> _getCamera() async {
    final cameras = await availableCameras();
    return cameras.first;
  }

  void _showFirstOpenDialog(BuildContext context) async {
    double verticalAlertPadding = MediaQuery.of(context).size.height * 0.30;
    double horizontalAlertPadding = MediaQuery.of(context).size.width * 0.1;

    Box box = await Hive.openBox('storage');
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, box, widget) {
              return AlertDialog(
                title: Text(
                  'Herzlich Willkommen! ',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0),
                ),
                insetPadding: EdgeInsets.symmetric(
                    horizontal: horizontalAlertPadding,
                    vertical: verticalAlertPadding),
                contentPadding: EdgeInsets.all(20.0),
                content: Text(
                    'Möchten Sie wissen wie diese App funktioniert? Dann klicken Sie auf "Anleitung". Ansonsten können Sie dieses Fenster schließen '),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Zur Anleitung',
                      style: TextStyle(color: Colors.lightGreen),
                    ),
                    onPressed: () {
                      Hive.box('storage').put('firstTime', false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManualPage()),
                      );
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Schließen',
                      style: TextStyle(color: Colors.lightGreen),
                    ),
                    onPressed: () {
                      Hive.box('storage').put('firstTime', false);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  @override
  initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (Hive.box('storage').get('firstTime', defaultValue: true)) {
        _showFirstOpenDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Connection _connection =
        context.watch<BoxConnectionState>().connectionState;

    DownloadUpload _downloadUpload =
        context.watch<DownloadUploadState>().downloadUploadState;

    Color green = Colors.green;
    Color red = Color(0xFFEE4400);
    //Im Moment fuehrt die Folgende Abfrage bei Auswertung zu zweifacher ausfuehrung des jeweiligen Codes.

    return new Scaffold(
        body: Stack(
      //A stack is used so that the connection status only covers other widgets
      fit: StackFit.expand,
      children: [
        Positioned(
          height: 20.0,
          left: 0.0,
          right: 0.0,
          //ConnectionMessage widget
          child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              color: _connection == Connection.NONE ? red : green,
              child: _connection == Connection.SENSORBOX
                  ? Center(
                      child: Text("Mit Sensorbox verbunden"),
                    )
                  : _connection == Connection.WIFI
                      ? Center(
                          child: Text(
                            "Mit Wlan verbunden",
                          ),
                        )
                      : Center(
                          child: Text(
                            "Keine Sensorbox in Reichweite",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.01,
              horizontal: MediaQuery.of(context).size.width * 0.01),
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              Row(
                //Make a Row with a settings button on the right side
                mainAxisAlignment:
                    MainAxisAlignment.end, //align the button to the right side
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
              //Nature 4.0 Image
              Container(
                  child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.asset('assets/logo_n40.png'))),
              //creation of the 4 tile menu
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _makeHomeTile(
                        "Anleitung", Icons.article, ManualPage(), context),
                    _makeHomeTile("Statistiken", Icons.analytics,
                        StatisticsPage(), context),
                    _makeHomeTile("Achievements", Icons.emoji_events,
                        AchievementsPage(), context),
                    _makeHomeTile("Über uns", Icons.import_contacts,
                        AboutUsPage(), context)
                  ],
                ),
              ),
              (_downloadUpload != DownloadUpload.IDLE &&
                      _connection != Connection.NONE)
                  ? Container(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (_downloadUpload == DownloadUpload.DOWNLOAD)
                                    ? Text("Download läuft...")
                                    : Text("Upload läuft..."),
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.lightGreen),
                                    strokeWidth: 2,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  //: Text(""),
              : RaisedButton(
                  onPressed: () async {
                    CameraDescription cam = await _getCamera();
                    var img = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FotoCapturePage(camera: cam)),
                    );

                    print(img);
                    if (img["pathToImg"] != null && img["label"] != null) {
                      try {
                        BoxCommunicator()
                            .saveUserImage(img["pathToImg"], img["label"]);
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
                  child: Text("capture"))
            ],
          ),
        ),
      ],
    ));
  }
}

//this function create a tile in a 2x2 Gridview. All tiles are the same except for the title, icon, the page it routes to and the context
Card _makeHomeTile(
    String name, IconData icon, Widget wgt, BuildContext context) {
  return Card(
      child: InkWell(
          splashColor: Colors.grey.withAlpha(30),
          onTap: () {
            //push the appropiate page to the navigator
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      wgt), // We use the Navigator to Route to the settings page wich is located in a new .dart file
            );
          },
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: new LayoutBuilder(builder: (context, constraints) {
                      return new Icon(
                        icon,
                        size: constraints.biggest.height * 0.80,
                        color: Colors.green,
                      );
                    }),
                  ),
                  Text(name)
                ],
              ))));
}
