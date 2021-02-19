import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutNature40 extends StatelessWidget {
  final TextStyle textStyle = TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54);

  @override
  Widget build(BuildContext context) {
    Text _nature40 = Text(
        'Natur 4.0 verbindet Wissenschaftler*innen der Geographie, Mathematik, '
        'Ökologie und Informatik mit naturschutzfachlichen Expert*innen, Schulen und Verbänden.  ',
        style: textStyle);
    Text _nature40StartingPoint = Text(
        'Naturschutzstrategien erfordern die Beobachtung und Bewertung von Landschaft. '
        'Expert*innenerhebungen müssen hier Kompromisse zwischen Detailgrad, '
        'räumlicher Abdeckung und zeitlicher Wiederholung eingehen, '
        'die auch durch Rückgriff auf flugzeug- oder satellitengestützte '
        'Fernerkundungsansätze nur bedingt aufgelöst werden. '
        'Dies schränkt differenzierte naturschutzfachliche Planungs- und Reaktionsmöglichkeiten ein.   ',
        style: textStyle);
    Text _nature40Goals = Text(
        'Ziel des LOEWE-Schwerpunkts Natur 4.0 ist die Entwicklung eines Prototyps von Natur 4.0, '
        'einem modularen Umweltmonitoringsystem zur hoch aufgelösten Beobachtung '
        'von naturschutzrelevanten Arten, Lebensräumen und Prozessen. '
        'Natur 4.0 basiert auf der Kombination von naturschutzfachlichen Expert*innenaufnahmen '
        'und vernetzten Fernerkundungs- und Umweltsensoren, die an ferngesteuerten Fluggeräten, '
        'fahrenden Robotern und Tieren angebracht sowie in bildungswissenschaftlichen Projekten eingesetzt werden. '
        'Zusammen mit leistungsfähigen Datenintegrations- und Datenanalysemethoden '
        'ermöglicht Natur 4.0 die differenzierte und effektive Beobachtung von Landschaft. '
        'Die erfassten Zeitreihen dienen zudem der Entwicklung von Frühwarnindikatoren. '
        'Natur 4.0 geht damit einen neuen Weg im Bereich der flächendeckenden Umweltbeobachtung. '
        'Es verdichtet die in situ Untersuchungen von Expert*innen und nutzt '
        'die nicht-reguläre Datenerhebung mit mobilen Plattformen zur Modellierung '
        'naturschutzfachlicher Informationen in Form von regulären, kleinräumig differenzierten Rasterkarten.',
        style: textStyle);

    Text _nature40ContactAndMore = Text(
        'Einen detailierteren Überblick über das Projekt, seine Teilprojekte und die verwendete Sensorik '
        'finden Sie auf unserer Website, welche unten verlinkt ist. Bei Interesse, '
        'Fragen und Anregungen schreiben Sie bitte eine E-Mail an unsere Projektkoordination.',
        style: textStyle);

    _launchNature40() async {
      const url = 'https://www.uni-marburg.de/de/fb19/natur40';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    _launchLOEWE() async {
      const url =
          'https://wissenschaft.hessen.de/wissenschaft/landesprogramm-loewe';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    Row _title(String sub, double fontSize) {
      return Row(
        children: [
          Text(
            sub,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    Row _textfield(Text content) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              children: <Widget>[content],
            ),
          )
        ],
      );
    }

    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          _title(' Natur 4.0 | Sensing Biodervisity', 20.0),
          _textfield(_nature40),
          _title(' Natur 4.0 - Kurz und bündig', 20.0),
          SizedBox(
            height: 5,
          ),
          _title(' Ausgangsbasis', 18.0),
          _textfield(_nature40StartingPoint),
          _title(' Ziele', 18.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Image.asset(
                  'assets/natur40_konzept.png',
                  scale: 3,
                  alignment: Alignment.center,
                ),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          _textfield(_nature40Goals),
          _title(' Mehr Informationen und Kontakt ', 18.0),
          _textfield(_nature40ContactAndMore),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  _launchNature40();
                },
                child: Text(
                  "Zur Webaufritt von Natur 4.0",
                  style: TextStyle(color: Colors.lightGreen, fontSize: 12.0),
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  _launchLOEWE();
                },
                child: Text(
                  'Zum Webauftritt "Landesprogramm LOEWE" ',
                  style: TextStyle(color: Colors.lightGreen, fontSize: 12.0),
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
