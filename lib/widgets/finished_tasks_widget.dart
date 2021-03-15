import 'package:data_offloading_app/widgets/pie_chart_indicator.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:data_offloading_app/logic/stats.dart';

//create the card with statistics for fulfilled tasks
class FinishedTasksDisplay extends StatefulWidget {
  @override
  _FinishedTasksDisplayState createState() => _FinishedTasksDisplayState();
}

class _FinishedTasksDisplayState extends State<FinishedTasksDisplay> {
  int _touchedIndex;
  List<Color> colorList = [
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.black,
    Colors.white,
    Colors.blue
  ];
  List<String> taskList = ['imageTask', 'cleaningTask', 'brightnessTask'];
  @override
  Widget build(BuildContext context) {
    //a FutureBuilder is used to deal with the asynchronous behavior of the Hive
    return FutureBuilder(
        future: _selectPieChart(),
        builder: (context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            //snapshot.data is the widget of the future returned by _makeFavBoxTile()
            return snapshot.data;
          } else {
            return Card(child: Center(child: Text("Bitte warten...")));
          }
        });
  }

  //if no tasks have been done the selector selects a message to be displayed. Otherwise the pie chart is displayed. This is used to prevent rendering errors for a piechart with no value-entries.
  Future<Widget> _selectPieChart() async {
    Box storage = await Hive.openBox('storage');
    //if the user hasn't finished any tasks the pie chart has no values to display. Therefore the message "Du hast bisher noch keine Tasks erfuellt" will be displayed
    if (storage.get('totalFinishedTasks', defaultValue: 0) == 0) {
      return Card(
          child: Center(
              child: Text("Sie haben bisher noch keine Tasks erfüllt.")));
    } else {
      //if the user has finished at least one task the pie chart is displayed.
      return _makeTaskTile();
    }
  }

  //function to build the indicators in the bottom left corner.
  List<ChartIndicator> _buildIndicators() {
    List<ChartIndicator> indicators = [];
    //colorIndex is used to select the appropriate color of the colorList.
    int colorIndex = 0;
    for (int taskIndex = 0; taskIndex < taskList.length; taskIndex++) {
      //when there are more tasks than colors the list is repeated from the beginning
      colorIndex = taskIndex % 5;
      indicators.add(ChartIndicator(
          color: colorList[colorIndex],
          text: taskList[taskIndex],
          index: taskIndex,
          touchIndex: _touchedIndex));
    }
    return indicators;
  }

  Card _makeTaskTile() {
    return Card(
        child: Column(
      children: [
        Center(
          child: Text(
            "Meist gemachte Tasks",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(
            //a future builder is used to deal with the asynchronous behavior of _buildTaskSections()
            child: FutureBuilder(
          future: _buildTaskSections(),
          builder:
              (context, AsyncSnapshot<List<PieChartSectionData>> snapshot) {
            if (snapshot.hasData) {
              return PieChart(PieChartData(
                //checks if piechart part is touched or not
                pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                  setState(() {
                    if (pieTouchResponse.touchInput is FlLongPressEnd ||
                        pieTouchResponse.touchInput is FlPanEnd) {
                      _touchedIndex = -1;
                    } else {
                      _touchedIndex = pieTouchResponse.touchedSectionIndex;
                    }
                  });
                }),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                //snapshot.data is the widget of the future returned by _buildTaskSections()
                sections: snapshot.data,
              ));
            } else {
              return Center(child: Text("Bitte warten..."));
            }
          },
        )),
        Text("Sie haben bisher " +
            Stats.getTotalNumberOfTasks().toString() +
            " Task" +
            (Stats.getTotalNumberOfTasks() > 1 ? "s" : "") +
            " abgeschlossen"),
        Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildIndicators()),
      ],
    ));
  }

  //build sections for the fulfilled tasks pie chart
  Future<List<PieChartSectionData>> _buildTaskSections() async {
    Stats.openBox();
    //read Total number of tasks here
    int totalNumOfTasks =
        Stats.getBox().get('totalFinishedTasks', defaultValue: 0);

    List<PieChartSectionData> taskPies = [];
    //index of the current color of the colorList
    int colorIndex = 0;
    //bool if the current part of the pie chart is touched or not
    bool isTouched;
    //font size of the touched part
    double fontSize;
    //radius of the touched part
    double radius;
    //this var stores how many times a certain task has been done by the user
    int numOfTask;
    //value of the part of the pie chart
    double value;
    //percentage displayed of the part in the pie chart
    String percentage;
    for (int taskIndex = 0; taskIndex < taskList.length; taskIndex++) {
      isTouched = taskIndex == _touchedIndex;
      fontSize = isTouched ? 20 : 10;
      radius = isTouched ? 60 : 50;
      colorIndex = taskIndex % 5;
      numOfTask = Stats.getBox().get(taskList[taskIndex], defaultValue: 0);
      value = numOfTask.toDouble() / totalNumOfTasks.toDouble();
      //the displayed percentage is rounded
      percentage = ((((value * 100.0)) * 10).ceil() / 10).toString() + "%";
      if (value == 0.0) {
        percentage = "";
      }
      //a PieChartSectionData element is added the the list.
      taskPies.add(PieChartSectionData(
          //the current color is accessed via the colorIndex in the colorList
          color: colorList[colorIndex], //[colorIndex],
          value: value,
          title: percentage,
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white)));
    }
    return taskPies;
  }
}
