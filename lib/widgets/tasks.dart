import 'dart:async';

import 'package:data_offloading_app/Screens/settings.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/taskList.dart';

import '../logic/box_communicator.dart';
import '../data/task.dart';
import 'task_widget.dart';

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Tasks extends StatefulWidget {
  static void getConnectionState(BuildContext context) async {
    String name = await WifiInfo().getWifiName();
    if (name == "Sensorbox" &&
        !context.read<BoxConnectionState>().connectionState) {
      if (Platform.isAndroid) {
        //force wifi so that we do not have problems with mobile data interfering api requests
        WiFiForIoTPlugin.forceWifiUsage(true);
      }
      context.read<BoxConnectionState>().connected();
    } else if (name != "Sensorbox" &&
        context.read<BoxConnectionState>().connectionState) {
      context.read<BoxConnectionState>().disconnected();
    }
  }

  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  //BuildContext context;
  List<Task> _currentTasks;
  Timer _timer;

  void _fetchTasks(BuildContext context) async {
    print("fetching tasks at tasks.dart");
    print(context);
    try {
      List<Task> taskList = [];
      print("tasks.dart getting Tasks");
      taskList = await context.read<TaskListProvider>().awaitTasks();
      setState(() {
        _currentTasks = taskList;
      });
    } catch (e) {
      print(e);
      print("LOOOOOOOOOOOOOOOOOL");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks(context);
    //check every 5 seconds for new Tasks
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      _fetchTasks(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool _connection = context.watch<BoxConnectionState>().connectionState;
    print(_connection);
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.01),
      child: Column(
        children: [
          Row(
            //Make a Row with a settings button on the right side
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //align the button to the right side
            children: [
              Text(
                "   Aufgaben",
                style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black45),
                textAlign: TextAlign.center,
              ),
              IconButton(
                  //button initialisation
                  icon: Icon(
                    Icons.settings,
                    color: Colors.black45,
                  ),
                  onPressed: () {
                    // this is what happens when the settings button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SettingsPage()), // We use the Navigator to Route to the settings page wich is located in a new .dart file
                    );
                  }),
            ],
          ),
          Expanded(
            child: _connection
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(
                        //vertical: MediaQuery.of(context).size.height * 0.1,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    itemCount: _currentTasks == null ? 0 : _currentTasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return TaskWidget(_currentTasks[index]);
                    },
                  )
                : Text("You are currently not connected to a sensorbox"),
          ),
        ],
      ),
    );
  }
}
