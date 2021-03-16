import 'package:data_offloading_app/widgets/favorite_box_widget.dart';
import 'package:data_offloading_app/widgets/finished_tasks_widget.dart';
import 'package:data_offloading_app/widgets/level_display_widget.dart';
import 'package:data_offloading_app/widgets/used_memory_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This page displays the following statistics:
///   - most frequently visited boxes,
///   - number and type of finished tasks
///   - used device memory
class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.01;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.01;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal:
                  horizontalPadding), //set a padding of 1% of screen size on all sides
          child: Column(
            children: [
              // This row displays the appbar on the top of the screen
              Row(
                //Make a Row with a back button on the left side
                mainAxisAlignment:
                    MainAxisAlignment.start, //align the button to the left side
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
                    '   Statistiken',
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

              // The following widget displays the level display
              LevelDisplay(),
              Expanded(
                //The following list displays all the statistics widgets
                child: GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisCount: 1,
                  children: [
                    //create all the statistics cards and a reset button.
                    FavoriteBoxDisplay(),
                    FinishedTasksDisplay(),
                    UsedMemoryDisplay(),
                    // ResetButton(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
