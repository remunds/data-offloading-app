import 'package:flutter/material.dart';

class BoxInfoPage extends StatefulWidget {
  @override
  _BoxInfoPageState createState() => _BoxInfoPageState();
}

class _BoxInfoPageState extends State<BoxInfoPage> {
  @override
  int power = 0;
  int dataLoad = 0;
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("BoxInfo"),
        ),
        body: Column(children: [
          Center(
            child: Text("Power level:" + power.toString()),
          ),
          Center(
            child: Text("Dataload: " + dataLoad.toString()),
          )
        ]));
  }
}
