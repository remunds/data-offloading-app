import 'package:data_offloading_app/Screens/achievements.dart';
import 'package:data_offloading_app/Screens/settings.dart';
import 'package:data_offloading_app/Screens/statistics.dart';
import 'package:flutter/material.dart';

class HowToUse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Text _usage1 = Text(
      'Sobald Sie verbunden sind startet der automatische Download der Sensordaten. Dabei ist es unwichtig wie lange Sie mit der Sensorbox verbunden sind. Bitte stellen Sie vor dem verbinden sicher, dass sie das Speicherlimit, welches der App zur Verfügung steht in den Einstellungen auf ihre Wünsche anpassen. Wenn das Limit erreicht ist werden keine Daten mehr heruntergeladen. ',
      style: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54),
    );
    Text _usage2 = Text(
      'Wenn Sie nun mit einem WLAN-Netzwerk, welches über eine Internetanbindung verfügt, verbunden sind, werden die Sensordaten auf Ihrem Gerät automatisch auf einen Server geladen und die Daten auf ihrem Gerät gelöscht.',
      style: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54),
    );
    Text _usage3 = Text(
      'Unter dem Punkt "Statistiken" auf der Hauptseite, können Sie sämtliche Statistiken einsehen. Diese Daten werden von uns jedoch nicht erhoben und werden vom Gerät gelöscht, falls die App oder die App-Daten gelöscht werden. ',
      style: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54),
    );
    Text _usage4 = Text(
      'Wenn Sie Aufgaben abschließen und sich mit Sensorboxen verbinden, sammeln Sie Punkte. Je mehr Punkte Sie sammeln, desto mehr Achievements (Erfolge) werden freigeschaltet. ',
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
                ' Wie nutze ich die App? ',
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
                  children: <Widget>[
                    _usage1,
                    SizedBox(
                      height: 10,
                    ),
                    _usage2,
                    SizedBox(
                      height: 10,
                    ),
                    _usage3,
                    SizedBox(
                      height: 10,
                    ),
                    _usage4,
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
                child: Text(
                  "Download-Einstellungen",
                  style: TextStyle(color: Colors.lightGreen),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatisticsPage()),
                  );
                },
                child: Text(
                  "Statistiken",
                  style: TextStyle(color: Colors.lightGreen),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AchievementsPage()),
                  );
                },
                child: Text(
                  "Achievements",
                  style: TextStyle(color: Colors.lightGreen),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )
        ],
      ),
    );
  }
}
