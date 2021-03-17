import 'package:flutter/material.dart';
import 'package:system_settings/system_settings.dart';

/// This widget is a page for explaining how to connect to a Sensorbox.
class HowToConnect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var displaywidth = MediaQuery.of(context).size.width;
    var displayheight = MediaQuery.of(context).size.height;

    TextStyle descriptionStyle = TextStyle(
        fontSize: displayheight * 0.018,
        fontWeight: FontWeight.w600,
        color: Colors.black54);
    TextStyle titleStyle = TextStyle(
        fontSize: displaywidth * 0.05,
        fontWeight: FontWeight.w600,
        color: Colors.black);

    Text _wificonnect1 = Text(
      '1. Gehen Sie in die WLAN-Einstellungen ihres Geräts. ',
      style: descriptionStyle,
    );
    Text _wificonnect2 = Text(
      '2. Wenn Sie sich in der Nähe einer Sensorbox befinden, sollte ein Netzwerk namens "Sensorbox" auftauchen. ',
      style: descriptionStyle,
    );
    Text _wificonnect3 = Text(
      '3. Verbinden Sie sich mit diesem und gehen Sie dann zurück zur App.  ',
      style: descriptionStyle,
    );
    Text _wificonnect4 = Text(
      'Achtung: Dieser Vorgang ist nur ein Mal nötig und muss nicht wiederholt werden.  ',
      style: TextStyle(
          fontSize: displayheight * 0.018,
          fontWeight: FontWeight.w800,
          color: Colors.black54),
    );

    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Text(
                ' Wie verbinde ich mich? ',
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: <Widget>[
                    _wificonnect1,
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    _wificonnect2,
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    _wificonnect3,
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    _wificonnect4,
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.asset(
                  'assets/example_wifi_connect.png',
                  scale: 3,
                ),
              )
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  SystemSettings.wifi();
                },
                child: Text(
                  "Zu den WLAN-Einstellungen",
                  style: TextStyle(color: Colors.lightGreen),
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )
        ],
      ),
    );
  }
}
