import 'package:data_offloading_app/widgets/level_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AchievementsPage extends StatefulWidget {
  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  ConfettiController _controllerCenter;

  void initState() {
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 1));
    super.initState();
  }

  void dispose() {
    _controllerCenter.dispose();
    Fluttertoast.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.01;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.01;
    double _descriptionSize = MediaQuery.of(context).size.width * 0.034;
    double _titleSize = MediaQuery.of(context).size.width * 0.048;
    Color _lockedColor = Colors.black45;
    Color _unlockedColor = Colors.black;
    Color _checkColor = Colors.lightGreen;

    Stack _achievement(
        String title, String description, bool unlocked, Icon achIcon) {
      return Stack(children: [
        Padding(
          padding: EdgeInsets.all(0.5),
          child: Card(
              child: FlatButton(
            onPressed: () {
              if (unlocked) {
                _controllerCenter.play();
              } else {
                Fluttertoast.showToast(
                    msg: "Noch nicht freigeschaltet",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            },
            child: Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.width * 0.08,
                        width: MediaQuery.of(context).size.width * 0.08,
                        child: achIcon)
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                Column(children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.68,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                  fontSize: _titleSize,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      unlocked ? _unlockedColor : _lockedColor),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              description,
                              style: TextStyle(
                                  fontSize: _descriptionSize,
                                  color:
                                      unlocked ? _unlockedColor : _lockedColor),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.08,
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: unlocked
                          ? Icon(
                              FontAwesomeIcons.check,
                              color: _checkColor,
                            )
                          : Icon(
                              FontAwesomeIcons.lock,
                              color: _lockedColor,
                            ),
                    )
                  ],
                ),
              ],
            ),
          )),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirectionality: BlastDirectionality
                .explosive, // don't specify a direction, blast randomly
            shouldLoop:
                true, // start again as soon as the animation is finished
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // manually specify the colors to be used
          ),
        ),
      ]);
    }

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('storage').listenable(),
        builder: (BuildContext context, value, Widget child) {
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
                        .start, //align the button to the right side
                    children: [
                      IconButton(
                          //button initialisation
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      Text(
                        '   Achievements',
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
                  LevelDisplay(),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: [
                        _achievement(
                          "Stadtkind",
                          "Besuche deine erste Sensorbox",
                          Hive.box('storage').get('visitedBoxes',
                                  defaultValue: []).length >=
                              1,
                          Icon(
                            FontAwesomeIcons.box,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Dorfkind",
                          "Besuche fünf Sensorboxen",
                          Hive.box('storage').get('visitedBoxes',
                                  defaultValue: []).length >=
                              5,
                          Icon(
                            FontAwesomeIcons.box,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Waldschrat",
                          "Besuche zehn Sensorboxen",
                          (Hive.box('storage').get('visitedBoxes',
                                  defaultValue: [])).length >=
                              10,
                          Icon(
                            FontAwesomeIcons.box,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Putzmuffel",
                          "Befreie eine Sensorbox von Schmutz",
                          Hive.box('storage')
                                  .get('cleaningTask', defaultValue: 0) >=
                              1,
                          Icon(
                            FontAwesomeIcons.tasks,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Putzfink",
                          "Befreie fünf Sensorboxen von Schmutz",
                          Hive.box('storage')
                                  .get('cleaningTask', defaultValue: 0) >=
                              5,
                          Icon(
                            FontAwesomeIcons.tasks,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Hobbyfotograf*in",
                          "Mache dein erstes Foto einer Baumkrone",
                          Hive.box('storage')
                                  .get('brightnessTask', defaultValue: 0) >=
                              1,
                          Icon(
                            FontAwesomeIcons.tasks,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Profifotograf*in",
                          "Schließe fünf Fotoaufgaben ab",
                          Hive.box('storage')
                                  .get('brightnessTask', defaultValue: 0) >=
                              5,
                          Icon(
                            FontAwesomeIcons.tasks,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Label-Anfänger*in",
                          "Labele ein Foto",
                          Hive.box('storage')
                                  .get('imageTask', defaultValue: 0) >=
                              1,
                          Icon(
                            Icons.label,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Label-Profi",
                          "Labele fünf Fotos",
                          Hive.box('storage')
                                  .get('imageTask', defaultValue: 0) >=
                              5,
                          Icon(
                            Icons.label,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Aller guten Dinge sind drei!",
                          "Erreiche Level 3",
                          Hive.box('storage').get('level', defaultValue: 0) >=
                              5,
                          Icon(
                            Icons.star,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "5 Gewinnt",
                          "Erreiche Level 5",
                          Hive.box('storage').get('level', defaultValue: 0) >=
                              5,
                          Icon(
                            Icons.star,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Seven, heaven!",
                          "Erreiche Level 7",
                          Hive.box('storage').get('level', defaultValue: 0) >=
                              5,
                          Icon(
                            Icons.star,
                            color: Colors.black54,
                          ),
                        ),
                        _achievement(
                          "Workaholic",
                          "Erreiche Level 10",
                          Hive.box('storage').get('level', defaultValue: 0) >=
                              5,
                          Icon(
                            Icons.star,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
