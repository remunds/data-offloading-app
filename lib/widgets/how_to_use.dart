import 'package:data_offloading_app/Screens/achievements.dart';
import 'package:data_offloading_app/Screens/settings.dart';
import 'package:data_offloading_app/Screens/statistics.dart';
import 'package:flutter/material.dart';

/// This widget is a page for displaying the instructions for using the app.
class HowToUse extends StatelessWidget {
  final TextStyle textStyle = TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54);
  final SizedBox placeHolder = SizedBox(
    height: 10,
  );
  final Color c = Colors.lightGreen;

  @override
  Widget build(BuildContext context) {
    Text _usage1 = Text(
        'Sobald Sie mit einer Sensorbox verbunden sind, startet der automatische Download von Sensordaten. '
        'Dabei ist es unwichtig, wie lange Sie mit der Sensorbox verbunden sind. '
        'Bitte stellen Sie vor dem Verbinden sicher, dass sie das Speicherlimit, '
        'welches der App zur Verfügung steht, in den Einstellungen auf ihre Wünsche anpassen. '
        'Wenn das Limit erreicht ist, werden keine Daten mehr heruntergeladen. ',
        style: textStyle);
    Text _usage2 = Text(
      'Wenn Sie nun mit einem WLAN-Netzwerk, welches über eine Internetanbindung '
      'verfügt, verbunden sind, werden Sie gefragt, ob Sie dieses WLAN zum Datenupload verwenden möchten. '
      'Stimmen Sie zu, werden die Sensordaten auf Ihrem Gerät '
      'automatisch auf einen Server geladen und die Daten auf ihrem Gerät gelöscht. '
      'Das WLAN wird abgespeichert, so dass Sie beim nächsten Verbinden nicht erneut zustimmen müssen.',
      style: textStyle,
    );
    Text _usage3 = Text(
        'Sind Sie mit einer Sensorbox verbunden, so werden Ihnen auf der entsprechenden Seite '
        'Aufgaben angezeigt, die für diese Sensorbox zu erledigen sind,'
        ' wie z.B. die Sensorbox zu säubern. '
        'Wenn Sie Aufgaben abschließen und sich mit Sensorboxen verbinden, sammeln Sie Punkte. '
        'Je mehr Punkte Sie sammeln, desto mehr Achievements (Erfolge) werden freigeschaltet. ',
        style: textStyle);
    Text _usage4 = Text(
        'Unter dem Punkt "Statistiken" auf der Hauptseite, können Sie sämtliche Statistiken einsehen. '
        'Diese Daten werden von uns jedoch nicht erhoben und werden vom Gerät gelöscht, '
        'falls die App oder die App-Daten gelöscht werden. ',
        style: textStyle);

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
                    fontSize: MediaQuery.of(context).size.width * 0.05,
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
                    placeHolder,
                    _usage2,
                    placeHolder,
                    _usage3,
                    placeHolder,
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
                  style: TextStyle(color: c),
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
                  style: TextStyle(color: c),
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
                  style: TextStyle(color: c),
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
