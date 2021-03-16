import 'package:flutter/material.dart';
import 'package:data_offloading_app/logic/stats.dart';
import 'package:fl_chart/fl_chart.dart';

/// A widget for displaying the favourite (most visited) boxes.
/// This widget is displayed on the Statistics page.
class FavoriteBoxDisplay extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //a future builder is used to deal with the asynchronous behavior of _makeFavBoxTile()
    return FutureBuilder(
        future: _makeFavBoxTile(),
        builder: (context, AsyncSnapshot<Card> snapshot) {
          if (snapshot.hasData) {
            //snapshot.data is the widget of the future returned by _makeFavBoxTile()
            return snapshot.data;
          } else {
            return Card(child: Center(child: Text("Bitte warten...")));
          }
        });
  }

  /// wrapper to build a single bar of the bar chart.
  /// x is the value on the x-axis and y is the value on the y-axis.
  /// x is int because the differences on the x-axis are always the same.
  BarChartGroupData _buildChartBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y,
          width: 40,
          borderRadius: BorderRadius.circular(7),
          colors: [Colors.green, Colors.green],
        )
      ],
    );
  }

  /// create the card with statistics for the most visited boxes
  Future<Card> _makeFavBoxTile() async {
    List<dynamic> _allBoxes = Stats.getVisitedBoxes();
    //toList() adds an empty element to the end of the set. Therefore the length of boxes is calculated with length() -1.
    //boxes stores the box-ids of the visited boxes
    List<dynamic> boxes =
        Stats.getMostFrequentlyVisitedBoxes().toSet().toList();
    //initial names for the boxes. These are the names that are displayed if not 1 or 2 or 3 different boxes have been visited.
    List<String> names = ["1st", "2nd", "3rd"];
    //at least one box has been visited
    if (boxes.length - 1 >= 1) {
      names[0] = boxes[0];
    }
    //at least two different boxes have been visited
    if (boxes.length - 1 >= 2) {
      names[1] = boxes[1];
    }
    //three or more boxes have been visited
    if (boxes.length - 1 >= 3) {
      names[2] = boxes[2];
    }
    //the frequencies list stores how many times the three most visited boxes have been visited. The first element of the list stores the visits of the most visited box
    List<double> frequencies = [];
    for (var i = 0; i < 3; i++) {
      frequencies.add(Stats.getFrequency(names[i], _allBoxes));
    }
    return Card(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Top 3 besuchte Boxen",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
            Expanded(
                child: BarChart(BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    //barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                        show: true,
                        //here the names on the x-axis are rendered
                        bottomTitles: SideTitles(
                            showTitles: true,
                            //set textstyle
                            getTextStyles: (value) => const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                            //get the titles from the names array
                            getTitles: (double value) {
                              switch (value.toInt()) {
                                case 1:
                                  return '${names[2]}';
                                case 2:
                                  return '${names[1]}';
                                case 3:
                                  return '${names[0]}';
                                default:
                                  return null;
                              }
                            }),
                        leftTitles: SideTitles(showTitles: false)),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                  //build bars of the chart
                  _buildChartBar(1, frequencies[2]),
                  _buildChartBar(2, frequencies[1]),
                  _buildChartBar(3, frequencies[0])
                ]))),
          ]),
    );
  }
}
