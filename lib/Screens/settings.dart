import 'package:data_offloading_app/Screens/aboutus.dart';
import 'package:data_offloading_app/Screens/manual.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/downloadall_state.dart';
import 'package:data_offloading_app/widgets/reset_widget.dart';
import 'package:data_offloading_app/Screens/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:disk_space/disk_space.dart';

/// This page displays the settings for the app.
double freeDiskSpace;

class SettingsPage extends StatelessWidget {
  static Future<FlutterBackgroundAndroidConfig> getAndroidConfig() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return FlutterBackgroundAndroidConfig(
        notificationTitle: packageInfo.appName,
        notificationText: "App im Hintergrund aktiv.",
        notificationImportance: AndroidNotificationImportance.Default);
  }

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
        color: Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: MediaQuery.of(context).size.height * 0.019);
    TextStyle textspanThin = TextStyle(
        fontWeight: FontWeight.w100,
        fontSize: MediaQuery.of(context).size.height * 0.015);

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
        if (val != null && val) {
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

    void _backgroundData(bool background) async {
      await FlutterBackground.initialize(
          androidConfig: await getAndroidConfig());
      if (!await FlutterBackground.hasPermissions) {
        return;
      }
      if (!background) {
        Hive.box('storage').put('backgroundService', false);
        await FlutterBackground.disableBackgroundExecution();
      } else {
        Hive.box('storage').put('backgroundService', true);
        await FlutterBackground.enableBackgroundExecution();
        //also enable upload in all wifis, if background execution is allowed
        Hive.box('storage').put('uploadInAllWifis', true);
      }
    }

    void _uploadInAllWifis(bool allow) async {
      Hive.box('storage').put('uploadInAllWifis', allow);
      //also disable background usage, if user does not allow all wifis
      if (!allow) _backgroundData(false);
    }

    void _backgroundDialog(bool value) async {
      await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Abbrechen',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                MaterialButton(
                  color: Colors.green,
                  child: Text(
                    'Ok',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _backgroundData(value);
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
              insetPadding: EdgeInsets.symmetric(
                  horizontal: horizontalAlertPadding,
                  vertical: verticalAlertPadding * 0.95),
              title: Text(
                'Achtung!',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0),
              ),
              content: Text(
                'Im Hintergrund kann nur erkannt werden, ob Sie mit einem WLAN-Netz verbunden sind, deshalb werden in allen WLAN-Netzwerken Sensordaten hochgeladen. Sie können also nicht gefragt werden, ob das hochladen in diesem Netzwerk in Ordnung ist. Mobilfunkdaten werden nie benutzt. Fortfahren?',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.017),
              ),
            );
          });
    }

    void _allWifiDialog(bool value) async {
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
                      _uploadInAllWifis(value);
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
                    'Da im Hintergrund nur erkannt werden kann, ob Sie mit einem WLAN-Netz verbunden sind (und nicht welches), müssen die Hintergrundaktivitäten auch deaktiviert werden, wenn Sie vor Uploads gefragt werden möchten. Fortfahren?',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.018)));
          });
    }

    void _showInfoDialogWifiNetworks() async {
      await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              actions: <Widget>[
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
              insetPadding: EdgeInsets.symmetric(
                  horizontal: horizontalAlertPadding,
                  vertical: verticalAlertPadding * 0.95),
              //contentPadding: EdgeInsets.all(8.0),
              title: Text(
                'Information',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0),
              ),
              content: Text(
                  'Wenn deaktiviert, werden Sie in jedem unbekannten WLAN-Netzwerk gefragt, ob Sie Sensordaten uploaden möchten.'),
            );
          });
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
                            // This list displays all the settings
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              // shrinkWrap: tr/Liaue,

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
                                  key: Key('Set Data Limit'),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      RichText(
                                        text: TextSpan(
                                          text: 'Datenmenge festlegen',
                                          style: textspanThick,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: '  Aktuell: ' +
                                                    (dataLimit < 1000
                                                        ? dataLimit.toString() +
                                                            ' MB'
                                                        : (dataLimit / 1000)
                                                                .toStringAsFixed(
                                                                    2) +
                                                            ' GB'),
                                                style: textspanThin),
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
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: Hive.box('storage').get(
                                                        'oldDataSwitch',
                                                        defaultValue: true)
                                                    ? '  Zuerst alte Daten runterladen'
                                                    : '  Zuerst neue Daten runterladen',
                                                style: textspanThin),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                          value: Hive.box('storage').get(
                                              'oldDataSwitch',
                                              defaultValue: true),
                                          onChanged: _changedOldData,
                                          activeColor: iconColor,
                                          activeTrackColor: iconColor)
                                    ],
                                  ),
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
                                          text: 'Hintergrund',
                                          style: textspanThick,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: Hive.box('storage').get(
                                                        'backgroundService',
                                                        defaultValue:
                                                            FlutterBackground
                                                                .isBackgroundExecutionEnabled)
                                                    ? '  App ist im Hintergrund aktiv'
                                                    : '  App ist nicht im Hintergrund aktiv',
                                                style: textspanThin),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                          value: Hive.box('storage').get(
                                              'backgroundService',
                                              defaultValue: FlutterBackground
                                                  .isBackgroundExecutionEnabled),
                                          onChanged: (value) {
                                            if (value &&
                                                !Hive.box('storage').get(
                                                    'uploadInAllWifis',
                                                    defaultValue: true)) {
                                              _backgroundDialog(value);
                                            } else {
                                              _backgroundData(value);
                                            }
                                          },
                                          activeColor: iconColor,
                                          activeTrackColor: iconColor)
                                    ],
                                  ),
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
                                          text: 'Unbekannte WLAN-Netze',
                                          style: textspanThick,
                                        ),
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.info_outline),
                                          onPressed: () =>
                                              _showInfoDialogWifiNetworks()),
                                      Switch(
                                          value: Hive.box('storage').get(
                                              'uploadInAllWifis',
                                              defaultValue: true),
                                          onChanged: (bool value) {
                                            if (!value &&
                                                FlutterBackground
                                                    .isBackgroundExecutionEnabled) {
                                              _allWifiDialog(value);
                                            } else {
                                              _uploadInAllWifis(value);
                                            }
                                          },
                                          activeColor: iconColor,
                                          activeTrackColor: iconColor)
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
