import 'package:flutter/material.dart';
import 'package:data_offloading_app/logic/stats.dart';

/// A widget for displaying the level
class LevelDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // a future builder is used to deal with the asynchronous behaviour of _makeLevelTile()
    return FutureBuilder(
        future: _makeLevelTile(),
        builder: (context, AsyncSnapshot<Container> snapshot) {
          if (snapshot.hasData) {
            //snapshot.data is the widget of the future returned by _makeLevelTile()
            return snapshot.data;
          } else {
            return Center(
              child: Text("Bitte warten..."),
            );
          }
        });
  }

  /// function to build the level tile
  Future<Container> _makeLevelTile() async {
    Stats.openBox();
    //get the current level stored in the Hive
    int _localLevel = Stats.getLevel();
    //get the current progress within a level stored in the Hive
    double progress = Stats.getProgress();
    return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Text(
                "Level $_localLevel",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              ),
            ),
            Center(
              //this is the progress indicator. The current level state is stored in the value attribute
              child: LayoutBuilder(builder: (context, contraints) {
                return LinearProgressIndicator(
                  minHeight: MediaQuery.of(context).size.height * 0.03,
                  backgroundColor: Colors.green[200],
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Colors.green[400]),
                  value: progress,
                );
              }),
            )
          ],
        ));
  }
}
