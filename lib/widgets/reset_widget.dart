import 'package:flutter/material.dart';
import 'package:data_offloading_app/logic/stats.dart';

//this widget is for development purposes only. It is used to reset all data regarding the finished tasks and visited boxes.
class ResetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
          //registers if the button is tapped
          child: GestureDetector(
              onTap: () {
                Stats.reset();
              },
              child: SizedBox(
                  width: 100,
                  height: 50,
                  child: Container(
                      color: Colors.green,
                      child: Center(child: Text("Reset")))))),
    );
  }
}
