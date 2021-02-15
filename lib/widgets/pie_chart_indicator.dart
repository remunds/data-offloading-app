import 'package:flutter/material.dart';

//this class is used to build the indicators for the piecharts. They are usually displayed in the bottom left corner of a piechart
class ChartIndicator extends StatelessWidget {
  final Color color;
  final String text;
  //the index and touchIndex are used in conjunction with the fl_charts lib. They are needed to determine if part of the piechart that corresponds to the current indicator is tapped or not.
  final int index, touchIndex;
  ChartIndicator({this.color, this.text, this.index, this.touchIndex});
  @override
  Widget build(BuildContext context) {
    //if index and touchIndex are the same the corresponding part of the piechart is tapped. The indicator gets bigger, increases its fontWeight and changes its color if it is tapped.
    final isTouched = index == touchIndex;
    //the gradient stores the "how grey" the text of the indicator should be
    final int gradient = isTouched ? 800 : 400;
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(shape: BoxShape.rectangle, color: color),
      ),
      //spacer
      const SizedBox(width: 5),
      Text(text,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[gradient])),
    ]);
  }
}