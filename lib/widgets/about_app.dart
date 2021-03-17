import 'package:data_offloading_app/Screens/privacy.dart';
import 'package:data_offloading_app/Screens/software.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// This page displays the "about "information at the bottom of the "about us".
class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Text _appIdeaAndEmergence = Text(
      'Im Rahmen des Bachelorpraktikums des Fachbereichs Informatik der TU Darmstadt '
      'im Wintersemester 2020/21 wurde eine Gruppe von 5 Studierenden beauftragt, '
      'eine Smartphone-Applikation zur drahtlosen Übertragung '
      'von Sensordaten auf unsere Server zu entwickeln. '
      'Dabei ist in mühevoller Arbeit diese Applikation enstanden.',
      style: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54),
    );

    Text _appContactAndGit = Text(
      'Für technische Informationen zur Applikation, besuchen Sie das GitHub Repository oder wenden Sie sich per E-Mail an das Entwicklungsteam.',
      style: TextStyle(
          fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black54),
    );

    /// please fill out the List<String> to and List<String> cc to the approprite email address
    _launchMailTo() async {
      final mailtoLink = Mailto(
        to: [],
        cc: [],
        subject: 'Frage zur Data Offloading App ',
        body: '',
      );

      String mail = mailtoLink.toString();

      await launch(mail);
    }

    /// This function links to the git repository of the project
    Future<int> _launchGitHub() async {
      const url = 'https://github.com/remunds/data-offloading-app';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
      return null;
    }

    /// This function links to used license of the project
    _launchLicense() async {
      const url = 'http://www.gnu.de/documents/gpl.de.html';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
      return null;
    }

    /// This function creates a title with a title and a specific font size
    ///
    /// [sub] is the text of the title
    /// [fontSize] is the font size of the text
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

    /// This function creates a text field
    Row _textField(Text content) {
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

    /// This card displays the "about" information at the bottom of the page
    return Card(
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          _title(' Projekt "Mobile Data Offloading" ', 20.0),
          SizedBox(
            height: 8,
          ),
          _title(' Idee und Entstehung ', 18.0),
          SizedBox(
            height: 5,
          ),
          _textField(_appIdeaAndEmergence),
          _title(' Mehr Informationen und Kontakt', 18.0),
          _textField(_appContactAndGit),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    _launchGitHub();
                  },
                  child: Row(
                    children: [
                      Text(
                        "GitHub Repository ",
                        style:
                            TextStyle(color: Colors.lightGreen, fontSize: 14.0),
                      ),
                      Icon(
                        FontAwesomeIcons.github,
                        color: Colors.lightGreen,
                      )
                    ],
                  ))
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    _launchMailTo();
                  },
                  child: Row(
                    children: [
                      Text(
                        'E-Mail ',
                        style:
                            TextStyle(color: Colors.lightGreen, fontSize: 14.0),
                      ),
                      Icon(
                        Icons.mail_rounded,
                        color: Colors.lightGreen,
                      )
                    ],
                  ))
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    _launchLicense();
                  },
                  child: Row(
                    children: [
                      Text(
                        'Lizenz ',
                        style:
                            TextStyle(color: Colors.lightGreen, fontSize: 14.0),
                      ),
                      Icon(
                        Icons.book,
                        color: Colors.lightGreen,
                      )
                    ],
                  ))
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Privacy()), // We use the Navigator to Route to the settings page wich is located in a new .dart file
                  );
                },
                child: Text(
                  'Datenschutz ',
                  style: TextStyle(color: Colors.lightGreen, fontSize: 14.0),
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Software()), // We use the Navigator to Route to the settings page wich is located in a new .dart file
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Verwendete Software ',
                        style:
                            TextStyle(color: Colors.lightGreen, fontSize: 14.0),
                      ),
                      Icon(
                        Icons.developer_mode_rounded,
                        color: Colors.lightGreen,
                      )
                    ],
                  ))
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      ),
    );
  }
}
