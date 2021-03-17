import 'package:flutter/material.dart';
import 'package:data_offloading_app/logic/stats.dart';

/// This widget is a reset button for development purposes only.
/// It is used to reset all statistics data regarding the finished tasks and visited boxes.
class ResetButton extends StatelessWidget {
  final double horizontalAlertPadding;
  final double verticalAlertPadding;

  ResetButton({this.horizontalAlertPadding, this.verticalAlertPadding});

  @override
  Widget build(BuildContext context) {
    //Dialog shown when user wants to download all data
    Future<void> _showResetDialogue() async {
      await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Ja',
                      style: TextStyle(color: Colors.lightGreen),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Abbrechen',
                      style: TextStyle(color: Colors.lightGreen),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
                insetPadding: EdgeInsets.symmetric(
                    horizontal: horizontalAlertPadding,
                    vertical: verticalAlertPadding * 0.95),
                title: Text(
                  'Statistiken zurücksetzen?',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0),
                ),
                content: Text(
                    'Wollen Sie wirklich alle Statistiken und Errungenschaften auf ihrem Gerät zurücksetzen?'));
          }).then((val) {
        if (val != null && val) {
          Stats.reset();
        }
      });
    }

    return Card(
        child: FlatButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Statistiken zurücksetzen',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.019,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          Icon(
            Icons.leaderboard,
            color: Colors.lightGreen,
          )
        ],
      ),
      onPressed: () => _showResetDialogue(),
    ));
  }
}
