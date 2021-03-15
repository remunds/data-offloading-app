import 'package:flutter/material.dart';
import 'package:system_settings/system_settings.dart';

class HowToConnect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Text _wificonnect = Text(
      'Gehen Sie in die WLAN-Einstellungen ihres Gerätes und suchen Sie nach verfügbaren Netzwerken. '
      'Wenn Sie sich in der Nähe einer Sensorbox befinden, sollte ein Netzwerk namens "Sensorbox" auftauchen. '
      'Dies ist ein offenes WLAN Netzwerk. '
      'Verbinden Sie sich mit diesem und gehen Sie dann zurück zur App.  ',
      style: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54),
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
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
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
                  children: <Widget>[_wificonnect],
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
