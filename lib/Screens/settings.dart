import 'package:data_offloading_app/Screens/aboutus.dart';
import 'package:data_offloading_app/Screens/manual.dart';
import 'package:data_offloading_app/Screens/statistics.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/downloadall_state.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.01;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.01;
    double verticalAlertPadding = MediaQuery.of(context).size.height * 0.35;
    double horizontalAlertPadding = MediaQuery.of(context).size.width * 0.1;

    Connection _connection =
        context.watch<BoxConnectionState>().connectionState;
    int _downloadAllState = context.watch<DownloadAllState>().downloadState;

    BuildContext _downloadIconContext = context;

    //Dialog shown when user wants to change download data limit
    Future<void> _showDataLimitDialog() async {
      Box sliderBox = await Hive.openBox('storage');
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: sliderBox.listenable(),
              builder: (context, box, widget) {
                return AlertDialog(
                  title: Text(
                    'Legen Sie das aktuelle Datenlimit fest, welches von der App in Anspruch genommen werden darf.',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0),
                  ),
                  insetPadding: EdgeInsets.symmetric(
                      horizontal: horizontalAlertPadding,
                      vertical: verticalAlertPadding),
                  contentPadding: EdgeInsets.all(8.0),
                  content: Slider(
                      activeColor: Colors.lightGreen,
                      inactiveColor: Colors.lightGreen,
                      value: sliderBox.get('dataLimitValueInMB',
                          defaultValue: 10.0),
                      min: 10.0,
                      max: 10000.0,
                      divisions: 100,
                      label: sliderBox
                          .get('dataLimitValueInMB', defaultValue: 10.0)
                          .round()
                          .toString(),
                      onChanged: (double value) =>
                          {sliderBox.put('dataLimitValueInMB', value)}),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'Abgeschlossen',
                        style: TextStyle(color: Colors.lightGreen),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              });
        },
      );
    }

    //Dialog shown when user wants to download all data
    Future<void> _showDownloadAllDialog() async {
      await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: _connection == Connection.SENSORBOX
                        ? Text(
                            'Ja',
                            style: TextStyle(color: Colors.lightGreen),
                          )
                        : Text('Wie verbinde ich mich?',
                            style: TextStyle(color: Colors.lightGreen)),
                    onPressed: () {
                      _connection == Connection.SENSORBOX
                          ? Navigator.of(context).pop(true)
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ManualPage()), // We use the Navigator to Route to the settings page wich is located in a new .dart file
                            );
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Abbrechen',
                      style: TextStyle(color: Colors.lightGreen),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
                insetPadding: EdgeInsets.symmetric(
                    horizontal: horizontalAlertPadding,
                    vertical: verticalAlertPadding * 0.95),
                //contentPadding: EdgeInsets.all(8.0),
                title: Text(
                  'Achtung!',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0),
                ),
                content: _connection == Connection.SENSORBOX
                    ? Text(
                        'Wollen Sie wirklich alle Daten auf ihr Gerät laden? (Das Datenlimit wird nicht berücksichtigt)')
                    : Text('Bitte verbinden Sie sich mit einer Sensorbox'));
          }).then((val) {
        if (val) {
          BoxCommunicator().downloadAllData(_downloadIconContext);
        }
      });
    }

    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: Hive.box('storage').listenable(),
          builder: (context, box, widget) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding,
                    horizontal:
                        horizontalPadding), //set a padding of 1% of screen size on all sides
                child: Column(
                  children: [
                    Row(
                      //Make a Row with a settings button on the right side
                      mainAxisAlignment: MainAxisAlignment
                          .start, //align the button to the left side
                      children: [
                        IconButton(
                            //button initialisation
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.black45,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        Text(
                          '   Einstellungen',
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black45),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: <Widget>[
                          Text(
                            'Download-Einstellungen',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54),
                            textAlign: TextAlign.left,
                          ),
                          Card(
                              child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: 'Datenmenge festlegen',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                                    /*defining default style is optional */
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '  Aktuell: ' +
                                              Hive.box('storage')
                                                  .get('dataLimitValueInMB',
                                                      defaultValue: 10.0)
                                                  .round()
                                                  .toString() +
                                              ' MB',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 12.0)),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.equalizer_rounded,
                                  color: Colors.lightGreen,
                                )
                              ],
                            ),
                            onPressed: () {
                              _showDataLimitDialog();
                            },
                          )),
                          //NATIVITY IS STILL MISSING. SORRY FOR THAT
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Entwickleroptionen',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54),
                            textAlign: TextAlign.left,
                          ),
                          Card(
                              child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Alle Daten herunterladen',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                ),
                                _downloadAllState == 0
                                    ? Icon(
                                        Icons.download_rounded,
                                        color: Colors.lightGreen,
                                      )
                                    : _downloadAllState == 1
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.lightGreen),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            Icons.done_rounded,
                                            color: Colors.lightGreen,
                                          ),
                              ],
                            ),
                            onPressed: () {
                              _showDownloadAllDialog();
                            },
                          )),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Sonstige Einstellungen',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54),
                            textAlign: TextAlign.left,
                          ),
                          Card(
                              child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: 'Mitteilungen',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                                    /*defining default style is optional */
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              '  Erlauben Sie Benachrichtigungen',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 12.0)),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: Hive.box('storage').get(
                                      'notificationSwitch',
                                      defaultValue: false),
                                  onChanged: (bool value) {
                                    Hive.box('storage')
                                        .put('notificationSwitch', value);
                                  },
                                  activeColor: Colors.lightGreen,
                                  activeTrackColor: Colors.lightGreenAccent,
                                )
                              ],
                            ),
                            onPressed: () {},
                          )),
                          Card(
                              child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: 'Anleitung',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '  Wie funktioniert die App? ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 12.0)),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.article_rounded,
                                  color: Colors.lightGreen,
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ManualPage()), // We use the Navigator to Route to the settings page wich is located in a new .dart file
                              );
                            },
                          )),
                          Card(
                              child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: 'Statistiken',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '  Nackte Zahlen ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 12.0)),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.analytics_rounded,
                                  color: Colors.lightGreen,
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StatisticsPage()),
                              );
                            },
                          )),
                          Card(
                              child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    text: 'About us',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '  Hör mal wer da hämmert',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w100,
                                              fontSize: 12.0)),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.import_contacts_rounded,
                                  color: Colors.lightGreen,
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AboutUsPage()),
                              );
                            },
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
