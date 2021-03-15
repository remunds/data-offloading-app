import 'package:data_offloading_app/Screens/aboutus.dart';
import 'package:data_offloading_app/Screens/achievements.dart';
import 'package:data_offloading_app/Screens/manual.dart';
import 'package:data_offloading_app/Screens/settings.dart';
import 'package:data_offloading_app/Screens/statistics.dart';
import 'package:data_offloading_app/logic/known_wifi_dialog.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/download_update_state.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcaseview.dart';

var homeKeys = {
  "welcome": GlobalKey(),
  "settings": GlobalKey(),
  "manual": GlobalKey(),
  "stats": GlobalKey(),
  "achievements": GlobalKey(),
  "aboutus": GlobalKey(),
};

/// This is the Home Page. It has a header for displaying the connection status
/// and four buttons for navigating to other pages:
/// HowToUse, HowToConnect, Statistics and Achievements.
/// It's also displayed whether uploading or downloading is currently in progress.
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BoxConnectionState boxConnectionState = context.watch<BoxConnectionState>();

    Connection _connection = boxConnectionState.connectionState;

    DownloadUpload _downloadUpload =
        context.watch<DownloadUploadState>().downloadUploadState;

    Color green = Colors.green;
    Color red = Color(0xFFEE4400);
    if (_connection == Connection.UNKNOWN_WIFI) {
      KnownWifiDialog.showAddWifiDialog(context, boxConnectionState);
    }

    /// Creates a custom ShowCase Widget. Standard widgets shown when bool 'guideFinished' evaluates to true.
    Widget customShowCase(
        GlobalKey key, String title, String description, Widget child) {
      return Hive.box('storage').get('guideFinished', defaultValue: false)
          ? child
          : Showcase(
              key: key, title: title, description: description, child: child);
    }

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
                  : _connection == Connection.KNOWN_WIFI ||
                          _connection == Connection.KNOWN_WIFI
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
                  customShowCase(
                    homeKeys["settings"],
                    "Einstellungen",
                    "Hier gelangen Sie zu den Einstellungen",
                    IconButton(
                        //button initialisation
                        icon: Icon(
                          Icons.settings,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          //when settings button is pressed, route to settings page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SettingsPage()), // We use the Navigator to Route to the settings page wich is located in a new .dart file
                          );
                        }),
                  ),
                ],
              ),
              //Nature 4.0 Image
              customShowCase(
                homeKeys["welcome"],
                "Herzlich Willkommen!",
                "Es folgt eine kurze Tour durch die App. Viel Spaß!",
                Container(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/logo_n40.png'),
                )),
              ),
              //creation of the 4 tile menu
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    customShowCase(
                      homeKeys["manual"],
                      "Anleitung",
                      "Hier gelangen Sie zu einer ausführlichen Anleitung",
                      _makeHomeTile(
                          "Anleitung", Icons.article, ManualPage(), context),
                    ),
                    customShowCase(
                        homeKeys["stats"],
                        "Statistiken",
                        "Hier sehen Sie alle wichtigen Daten",
                        _makeHomeTile("Statistiken", Icons.analytics,
                            StatisticsPage(), context)),
                    customShowCase(
                        homeKeys["achievements"],
                        "Achievements",
                        "Mit dem Abschließen von Aufgaben sammeln Sie Erfolge",
                        _makeHomeTile("Achievements", Icons.emoji_events,
                            AchievementsPage(), context)),
                    customShowCase(
                        homeKeys["aboutus"],
                        "Über uns",
                        "Hier können Sie mehr über uns erfahren",
                        _makeHomeTile("Über uns", Icons.import_contacts,
                            AboutUsPage(), context))
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
    String name, IconData icon, Widget wgt, BuildContext context) {
  return Card(
      child: InkWell(
          splashColor: Colors.grey.withAlpha(30),
          onTap: () {
            //push the appropriate page to the navigator
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      wgt), // We use the Navigator to Route to the settings page which is located in a new .dart file
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
