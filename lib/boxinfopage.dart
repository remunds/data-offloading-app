import 'package:flutter/material.dart';

class BoxInfoPage extends StatefulWidget {
  final power;
  final dataLoad;
  BoxInfoPage(this.power, this.dataLoad);
  @override
  _BoxInfoPageState createState() => _BoxInfoPageState();
}

class _BoxInfoPageState extends State<BoxInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("BoxInfo"),
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
