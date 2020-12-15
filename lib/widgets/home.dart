import 'dart:async';

import 'package:data_offloading_app/provider/box_connection_state.dart';

import '../logic/box_communicator.dart';
import '../data/task.dart';
import 'task_widget.dart';

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Home extends StatefulWidget {
  static void getConnectionState(BuildContext context) async {
    String name = await WifiInfo().getWifiName();
    if (name == "Sensorbox") {
      if (Platform.isAndroid) {
        //force wifi so that we do not have problems with mobile data interfering api requests
        WiFiForIoTPlugin.forceWifiUsage(true);
      }
      context.read<BoxConnectionState>().connected();
    } else {
      context.read<BoxConnectionState>().disconnected();
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
              : "You are currently not connected to a Sensorbox"),
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
