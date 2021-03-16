import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

/// Class for adding currently connected Wifi to Known Wifis for Data Upload
class KnownWifiDialog {

  /// opens dialog asking whether connected wifi should be added to known wifis
  ///
  /// [context] build context from page calling this function
  /// [connection] connection state to be updated
  static void showAddWifiDialog(
      BuildContext context, BoxConnectionState connection) async {
    String name = await WifiInfo().getWifiName();

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sie sind mit einem unbekannten Wifi verbunden."),
            content: Text("Möchten Sie dieses Wifi zum Datenupload verwenden?"),
            actions: [
              FlatButton(
                  onPressed: () {
                    // add connected Wifi to list of Known Wifis
                    List knownWifis =
                        Hive.box('storage').get('knownWifis', defaultValue: []);
                    knownWifis.add(name);
                    Hive.box('storage').put('knownWifis', knownWifis);
                    Navigator.of(context).pop();
                  },
                  child: Text("Ja")),
              FlatButton(
                  onPressed: () {
                    // connect to Known Wifi without uploading data so that user won't be asked again to add this wifi to known
                    connection.connectedToKnownWifi();
                    Navigator.of(context).pop();
                  },
                  child: Text("Nein")),
            ],
          );
        });
  }
}
