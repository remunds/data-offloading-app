import 'package:data_offloading_app/widgets/pie_chart_indicator.dart';
import 'package:flutter/material.dart';
import 'package:data_offloading_app/logic/stats.dart';
import 'package:fl_chart/fl_chart.dart';

//create the card with statistics for memory
class UsedMemoryDisplay extends StatefulWidget {
  @override
  _UsedMemoryDisplayState createState() => _UsedMemoryDisplayState();
}

class _UsedMemoryDisplayState extends State<UsedMemoryDisplay> {
  int _touchedIndexMemory;
  @override
  Widget build(BuildContext context) {
    return _makeMemoryTile();
  }

  //builder for the memory piechart
  Card _makeMemoryTile() {
    return Card(
        child: Column(
      children: [
        Center(
          child: Text(
            "Freier Speicher",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(
          //a future builder is used to deal with the asynchronos behavior of _buildMemorySections()
          child: FutureBuilder(
            future: _buildMemorySections(),
            builder:
                (context, AsyncSnapshot<List<PieChartSectionData>> snapshot) {
              if (snapshot.hasData) {
                return PieChart(PieChartData(
                  //checks if a part of the piechart is touched or not
                  pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                    setState(() {
                      if (pieTouchResponse.touchInput is FlLongPressEnd ||
                          pieTouchResponse.touchInput is FlPanEnd) {
                        _touchedIndexMemory = -1;
                      } else {
                        _touchedIndexMemory =
                            pieTouchResponse.touchedSectionIndex;
                      }
                    });
                  }),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  //snapshot.data is the widget of the future returned by _buildMemorySections()
                  sections: snapshot.data,
                ));
              } else {
                return Center(child: Text("Bitte warten..."));
              }
            },
          ),
        ),
        //build an indicator which shows which pie of the chart is which
        ChartIndicator(
            color: Colors.green,
            text: "Frei",
            index: 0,
            touchIndex: _touchedIndexMemory),
        ChartIndicator(
            color: Colors.red,
            text: "Belegt",
            index: 1,
            touchIndex: _touchedIndexMemory),
      ],
    ));
  }

  //build sections for the memory usage pie chart
  Future<List<PieChartSectionData>> _buildMemorySections() async {
    Stats.openBox();
    //generate a list of 2 piechartsections. One is used for useable memory and for used memory.
    return List.generate(2, (index) {
      //bool if the current part of the pie chart is touched or not
      final isTouched = index == _touchedIndexMemory;
      //fontsize of the touched part
      final double fontSize = isTouched ? 20 : 10;
      //radius of the touched part
      final double radius = isTouched ? 60 : 50;
      //the usedMemory in Bytes
      double usedMem = Stats.getUsedMemory().toDouble();
      //getTotalMemory() returns the size of the useable memory in MegaBytes
      double dataLimitMB = Stats.getTotalMemory();
      //calculate the the size of the useable memory in Bytes
      double dataLimitBytes = dataLimitMB * 1000000.0;
      //rounded percentage
      double percentage = ((usedMem / dataLimitBytes) * 10).ceil() / 10;
      //names to be displayed in the piechart
      String free = "${((100 - percentage))}%";
      String blocked = "${(percentage)}%";
      //if the percentage of a section is 0, nothing is displayed instead of 0%.
      if (percentage == 0) {
        blocked = "";
      }
      //there are only 2 sections in this piechart
      switch (index) {
        case 0:
          //this section represents the useable memory
          return PieChartSectionData(
              color: Colors.green,
              value: (100 - percentage),
              title: free,
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,
                  color: Colors.white));
        case 1:
          //this section represents the used memory
          return PieChartSectionData(
              color: Colors.red,
              value: percentage,
              title: blocked,
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,
                  color: Colors.white));
        default:
          //this section represents the useable memory
          return PieChartSectionData(
              color: Colors.green,
              value: 100,
              title: "Error",
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.normal,
                  color: Colors.white));
      }
    });
  }
}
