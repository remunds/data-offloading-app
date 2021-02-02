import 'package:data_offloading_app/Screens/aboutus.dart';
import 'package:data_offloading_app/Screens/achievements.dart';
import 'package:data_offloading_app/Screens/manual.dart';
import 'package:data_offloading_app/Screens/settings.dart';
import 'package:data_offloading_app/Screens/statistics.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/download_update_state.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Connection _connection =
        context.watch<BoxConnectionState>().connectionState;

    DownloadUpload _downloadUpload =
        context.watch<DownloadUploadState>().downloadUploadState;

    Color green = Colors.green;
    Color red = Color(0xFFEE4400);

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
                    _makeHomeTile("About us", Icons.import_contacts,
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
                  : Text(""),
            ],
          ),
        ),
      ],
    ));
  }
}

//this function create a tile in a 2x2 Gridview. All tiles are the same except for the title, icon, the page it routes to and the context
Card _makeHomeTile(
    String name, IconData icon, StatelessWidget slwgt, BuildContext context) {
  return Card(
      child: InkWell(
          splashColor: Colors.grey.withAlpha(30),
          onTap: () {
            //push the appropiate page to the navigator
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      slwgt), // We use the Navigator to Route to the settings page wich is located in a new .dart file
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
