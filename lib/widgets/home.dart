import 'dart:async';

import 'package:data_offloading_app/provider/boxconnectionstate.dart';

import '../logic/boxcommunicator.dart';
import '../data/task.dart';
import 'taskwidget.dart';

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';

// class Home extends StatefulWidget {
//   Home({Key key, this.title}) : super(key: key);
//   final String title;

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String _currentConnectionText;
//   List<Widget> _currentTasks;

//   List<Widget> _createTaskList(List<Task> taskList) {
//     List<Widget> widgetList = new List<Widget>(taskList.length);
//     for (int i = 0; i < widgetList.length; ++i) {
//       widgetList[i] = TaskWidget(taskList[i]);
//     }
//     return widgetList;
//   }

//   void _fetchTasks() async {
//     List<Task> taskList = await BoxCommunicator().fetchTasks();
//     List<Widget> taskListWidget = _createTaskList(taskList);
//     setState(() {
//       _currentTasks = taskListWidget;
//     });
//   }

//   void _getWifi(BuildContext context) async {
//     String name = await WifiInfo().getWifiName();
//     //TODO:
//     // only fetch tasks and force wifiusage once per Sensorbox (get Hardware-ID like MAC from Box) -> we want the app to transfer data, not only tasks :)
//     if (name == "Sensorbox") {
//       if (Platform.isAndroid) {
//         //force wifi so that we do not have problems with mobile data interfering api requests
//         WiFiForIoTPlugin.forceWifiUsage(true);
//       }
//       context.read<BoxConnectionState>.connected();
//       _fetchTasks();
//       setState(() {
//         _currentConnectionText = "You are currently in reach of a Sensorbox";
//       });
//     } else {
//       setState(() {
//         _currentConnectionText = "Please move closer to a Sensorbox";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _getWifi(context);
//     return Column(
//       children: [
//         Text(_currentConnectionText ?? "no connection information"),
//         //Expanded(child: ListView(children: _currentTasks ?? [])),
//       ],
//     );
//   }
// }

class Home extends StatefulWidget {
  static void getConnectionState(BuildContext context) async {
    String name = await WifiInfo().getWifiName();
    //TODO:
    // only fetch tasks and force wifiusage once per Sensorbox (get Hardware-ID like MAC from Box) -> we want the app to transfer data, not only tasks :)
    if (name == "Sensorbox") {
      if (Platform.isAndroid) {
        //force wifi so that we do not have problems with mobile data interfering api requests
        WiFiForIoTPlugin.forceWifiUsage(true);
      }
      context.read<BoxConnectionState>().connected();
      //_fetchTasks();
      // setState(() {
      //   _currentConnectionText = "You are currently in reach of a Sensorbox";
      // });
    } else {
      context.read<BoxConnectionState>().disconnected();
      // setState(() {
      //   _currentConnectionText = "Please move closer to a Sensorbox";
      // });
    }
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> _currentTasks;
  Timer t;

  void _fetchTasks() async {
    print("fetching tasks");
    List<Task> taskList = await BoxCommunicator().fetchTasks();
    setState(() {
      _currentTasks = taskList;
    });
  }

  List<Widget> _createTaskList(List<Task> taskList) {
    List<Widget> widgetList = new List<Widget>(taskList.length);
    for (int i = 0; i < widgetList.length; ++i) {
      widgetList[i] = TaskWidget(taskList[i]);
    }
    return widgetList;
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    //check every 5 seconds for new Tasks
    Timer.periodic(Duration(seconds: 5), (Timer t) {
      _fetchTasks();
      setState(() {
        this.t = t;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    t.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool _connection = context.watch<BoxConnectionState>().connectionState;
    print(_connection);
    return Expanded(
      child: Column(
        children: [
          Text(_connection
              ? "You are connected to a Sensorbox"
              : "You are currently not in reach of a Sensorbox"),
          Expanded(
            child: ListView.builder(
              itemCount: _currentTasks == null ? 0 : _currentTasks.length,
              itemBuilder: (BuildContext context, int index) {
                return TaskWidget(_currentTasks[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}
