import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

class HomeWifiDialog {
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
