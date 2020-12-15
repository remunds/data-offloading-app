import 'package:flutter/material.dart';

class BoxInfo extends StatefulWidget {
  final power;
  final dataLoad;
  BoxInfo(this.power, this.dataLoad);
  @override
  _BoxInfoPageState createState() => _BoxInfoPageState();
}

class _BoxInfoPageState extends State<BoxInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("BoxInfo"),
          backgroundColor: Colors.green,
        ),
        body: Column(children: [
          Center(
            child: Text("Power level:" + widget.power.toString()),
          ),
          Center(
            child: Text("Dataload: " + widget.dataLoad.toString()),
          )
        ]));
  }
}
