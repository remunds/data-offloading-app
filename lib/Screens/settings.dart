import 'package:data_offloading_app/Screens/aboutus.dart';
import 'package:data_offloading_app/Screens/manual.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/downloadall_state.dart';
import 'package:data_offloading_app/widgets/reset_widget.dart';
import 'package:data_offloading_app/Screens/statistics.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:disk_space/disk_space.dart';

/// This page displays the settings for the app.
double freeDiskSpace;

class SettingsPage extends StatelessWidget {
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.01;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.01;

    double verticalAlertPadding = MediaQuery.of(context).size.height * 0.30;
    double horizontalAlertPadding = MediaQuery.of(context).size.width * 0.1;

    Connection _connection =
        context.watch<BoxConnectionState>().connectionState;
    int _downloadAllState = context.watch<DownloadAllState>().downloadState;

    BuildContext _downloadIconContext = context;

    Color iconColor = Colors.lightGreen;

    TextStyle textspanThick = TextStyle(
        color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16.0);
    TextStyle textspanThin =
        TextStyle(fontWeight: FontWeight.w100, fontSize: 12.0);

    Widget _divider(String divideText) {
      return Stack(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.025,
        ),
        Text(
          divideText,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.black54),
          textAlign: TextAlign.left,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        )
      ]);
    }

    Widget _sitemapCard(String site, String desc, IconData icon, Widget route) {
      return Card(
          child: FlatButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: site,
                style: textspanThick,
                children: <TextSpan>[
                  TextSpan(text: desc, style: textspanThin),
                ],
              ),
            ),
            Icon(icon, color: iconColor),
          ],
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        },
      ));
    }

    //Dialog shown when user wants to change download data limit
    Future<void> _showDataLimitDialog() async {
      Box sliderBox = await Hive.openBox('storage');
      freeDiskSpace = await DiskSpace.getFreeDiskSpace;
      return await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: sliderBox.listenable(),
              builder: (context, box, widget) {
                double dataLimitValue = sliderBox.get('dataLimitValueInMB',
                    defaultValue: freeDiskSpace * 0.5);
                String dataLimit = dataLimitValue.round() < 1000
                    ? dataLimitValue.round().toString() + ' MB'
                    : (dataLimitValue.round() / 1000).toStringAsFixed(2) +
                        ' GB';
                return AlertDialog(
                  title: Text(
                    'Legen Sie das aktuelle Datenlimit fest, welches von der App in Anspruch genommen werden darf. Aktuell: ' +
                        dataLimit,
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
                      value: dataLimitValue > freeDiskSpace * 0.9
                          ? freeDiskSpace * 0.9
                          : dataLimitValue,
                      min: 10.0,
                      max: freeDiskSpace * 0.9,
                      divisions: 100,
                      label: dataLimit,
                      onChanged: (double value) =>
                          {sliderBox.put('dataLimitValueInMB', value)}),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'Ok',
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

    /// Dialog shown when user wants to download all data
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
                      style: TextStyle(color: iconColor),
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
                        'Wollen Sie wirklich alle Daten auf ihr Gerät laden? (Das Datenlimit wird nicht berücksichtigt.)')
                    : Text('Bitte verbinden Sie sich mit einer Sensorbox.'));
          }).then((val) {
        if (val && val != null) {
          BoxCommunicator().downloadAllData(_downloadIconContext);
        }
      });
    }

    /// switch if the user wants to download old data or new data first
    ///
    /// [value] == true old data is downloaded first
    /// [value] == false new data is downloaded first
    void _changedOldData(bool value) async {
      if (value) {
        Hive.box('storage').put('oldDataSwitch', true);
      } else {
        await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Ja',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onPressed: () {
                      Hive.box('storage').put('oldDataSwitch', value);
                      Navigator.of(context).pop(true);
                    },
                  ),
                  MaterialButton(
                    color: Colors.green,
                    child: Text(
                      'Abbrechen',
                      style: TextStyle(color: Colors.white),
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
                content: Text(
                    'Nur für Wissenschaftler*innen. Wollen sie wirklich den Download mit den neuesten Daten starten?'),
              );
            });
      }
    }

    return Scaffold(
      body: FutureBuilder<double>(
          future: DiskSpace.getFreeDiskSpace,
          builder: (context, snapshot) {
            return ValueListenableBuilder(
                valueListenable: Hive.box('storage').listenable(),
                builder: (context, box, widget) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  double dataLimit = Hive.box('storage').get(
                      'dataLimitValueInMB',
                      defaultValue: snapshot.data * 0.5);
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                child: Text(
                                  '   Einstellungen',
                                  style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black45),
                                  textAlign: TextAlign.center,
                                ),
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
                                _divider("Download-Einstellungen"),
                                Card(
                                    child: FlatButton(
                                  key: Key('Set Data Limit'),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      RichText(
                                        text: TextSpan(
                                          text: 'Datenmenge festlegen',
                                          style: textspanThick,
                                          /*defining default style is optional */
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: '  Aktuell: ' +
                                                    (dataLimit < 1000.0
                                                        ? dataLimit.toString() +
                                                            ' MB'
                                                        : (dataLimit / 1000.0)
                                                                .toStringAsFixed(
                                                                    2) +
                                                            ' GB'),
                                                style: textspanThin),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.equalizer_rounded,
                                        color: iconColor,
                                      )
                                    ],
                                  ),
                                  onPressed: () {
                                    _showDataLimitDialog();
                                  },
                                )),
                                Card(
                                    child: Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.04),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      RichText(
                                        text: TextSpan(
                                          text: 'Datenpriorität',
                                          style: textspanThick,
                                          /*defining default style is optional */
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: Hive.box('storage').get(
                                                        'oldDataSwitch',
                                                        defaultValue: true)
                                                    ? '  Zuerst alte Daten herunterladen'
                                                    : '  Zuerst neue Daten herunterladen',
                                                style: textspanThin),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: Hive.box('storage').get(
                                            'oldDataSwitch',
                                            defaultValue: true),
                                        onChanged: _changedOldData, // {
                                        //   Hive.box('storage')
                                        //       .put('oldDataSwitch', value);
                                        // },
                                        activeColor: iconColor,
                                        activeTrackColor: iconColor,
                                      )
                                    ],
                                  ),
                                )),
                                _divider("Entwickleroptionen"),
                                Card(
                                    child: FlatButton(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'Alle Daten herunterladen',
                                        style: textspanThick,
                                      ),
                                      _downloadAllState == 0
                                          ? Icon(
                                              Icons.download_rounded,
                                              color: iconColor,
                                            )
                                          : _downloadAllState == 1
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(iconColor),
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.done_rounded,
                                                  color: iconColor,
                                                ),
                                    ],
                                  ),
                                  onPressed: () {
                                    _showDownloadAllDialog();
                                  },
                                )),
                                _divider("Sonstige Einstellungen"),
                                Card(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.04),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                            text: 'Mitteilungen',
                                            style: textspanThick,
                                            /*defining default style is optional */
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      '  Benachrichtigungen erlauben',
                                                  style: textspanThin),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: Hive.box('storage').get(
                                              'notificationSwitch',
                                              defaultValue: false),
                                          onChanged: (bool value) {
                                            Hive.box('storage').put(
                                                'notificationSwitch', value);
                                          },
                                          activeColor: iconColor,
                                          activeTrackColor: iconColor,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                ResetButton(
                                    horizontalAlertPadding:
                                        horizontalAlertPadding,
                                    verticalAlertPadding: verticalAlertPadding),
                                _divider("Sitemap"),
                                _sitemapCard(
                                    'Anleitung ',
                                    '  Wie funktioniert die App? ',
                                    Icons.article_rounded,
                                    ManualPage()),
                                _sitemapCard('Statistiken ', '  Nackte Zahlen ',
                                    Icons.analytics_rounded, StatisticsPage()),
                                _sitemapCard(
                                    'About us',
                                    '  Hör mal wer da hämmert',
                                    Icons.import_contacts_rounded,
                                    AboutUsPage())
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
