import 'package:flutter/material.dart';

class ImportantInfo extends StatelessWidget {
  final TextStyle textStyle = TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54);
  final SizedBox placeHolder = SizedBox(
    height: 10,
  );
  final Color c = Colors.lightGreen;

  Widget build(BuildContext context) {
    Text _info1 = Text(
      'Wir freuen uns, dass Sie sich für den Naturschutz einsetzen möchten. Mit Hilfe dieser App werden Naturdaten gesammelt und Forschern zur Verfügung gestellt.',
      style: textStyle,
    );

    Text _info2 = Text(
      'Dies geschieht zum Großteil im Hintergrund der App und ist daher für Sie als Nutzer*in nicht direkt sichtbar, '
      'dennoch leisten Sie eine großen Beitrag für uns und die Natur'
      'und greifen den Forschern von Natur 4.0 - Sensing Biodiversity unter die Arme',
      style: textStyle,
    );

    Text _info3 = Text(
      'Konkret werden während der Nutzung, sobald die Verbindung zu einer unserer Sensorboxen besteht,'
      'aufgezeichnete Daten der Sensoren auf ihr Gerät geladen.'
      'Sollten Sie dann zu einem späteren Zeitpunkt mit ihrem Gerät in einem Netzwerk sein, welchem eine Internetverbindung aufweist,'
      'so werden diese Daten auf einen Server geladen und von ihrem Gerät gelöscht. Sie brauchen sich also keine Sorgen zu machen. ',
      style: textStyle,
    );

    Text _info4 = Text(
      'Dazu haben Sie die Möglichkeit aktiv, durch Abschließen von Aufgaben, am Naturschutz teilzunehmen und Errungenschaften freizuschalten.',
      style: textStyle,
    );

    return Card(
        child: Column(children: [
      SizedBox(
        height: 5,
      ),
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Vorwort',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      Row(children: [
        Container(
            padding: EdgeInsets.all(8.0),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(children: <Widget>[
              _info1,
              placeHolder,
              _info2,
              placeHolder,
              _info3,
              placeHolder,
              _info4,
              placeHolder
            ]))
      ])
    ]));
  }
}
