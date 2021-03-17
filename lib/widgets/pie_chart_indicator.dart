import 'package:flutter/material.dart';

/// This class is used to build the indicators for the pie charts.
/// They are usually displayed in the bottom left corner of a pie chart.
class ChartIndicator extends StatelessWidget {
  final Color color;
  final String text;

  /// The index and touchIndex are used in conjunction with the fl_charts lib.
  /// They are needed to determine if part of the pie chart that corresponds to the current indicator is tapped or not.
  final int index, touchIndex;

  ChartIndicator({this.color, this.text, this.index, this.touchIndex});

  @override
  Widget build(BuildContext context) {
    // If index and touchIndex are the same the corresponding part of the pie chart is tapped.
    // The indicator gets bigger, increases its fontWeight and changes its color if it is tapped.
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
