import 'dart:async';
import 'dart:convert';

import 'package:data_offloading_app/Screens/settings.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/tasklist_state.dart';

import '../data/task.dart';
import 'task_widget.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tasks extends StatefulWidget {
  @override
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  //BuildContext context;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    context.read<TaskListProvider>().awaitTasks();
    //check every second for new Tasks
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      context.read<TaskListProvider>().awaitTasks();
    });
    loadTasksFromJson();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  List<Task> _currentTasks;

  void loadTasksFromJson() async {
    List<Task> taskList = List<Task>();
    String taskListString = await DefaultAssetBundle.of(context)
        .loadString("assets/dummyData.json");
    List<dynamic> taskListJson = jsonDecode(taskListString);
    taskList = taskListJson.map((elem) => Task.fromJson(elem)).toList();
    setState(() {
      _currentTasks = taskList;
      print("set current tasks");
      print(taskList);
    });
  }

  @override
  Widget build(BuildContext context) {
    // List<Task> _currentTasks = //context.watch<TaskListProvider>().taskList;
    Connection _connection = Connection.SENSORBOX;
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
              //Here starts the tasks view
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
          //Expanded Widget to expand over whole
          Expanded(
            //2 ternary operators. The first one checks if there is a connection to a sensorbox.
            //The other checks on the length of the task list if connection is established
            child: _connection == Connection.SENSORBOX
                ? _currentTasks == null
                    ? Text("Aufgaben konnten nicht geladen werden.")
                    : _currentTasks.length != 0
                        //The following ListView shows
                        ? ListView.builder(
                            padding: EdgeInsets.symmetric(
                                //Use a 1% horizontal padding for the list view
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.01),
                            itemCount: _currentTasks == null
                                ? 0
                                : _currentTasks.length,
                            itemBuilder: (BuildContext context, int index) {
                              return TaskWidget(_currentTasks[index]);
                            },
                          )
                        : Text(
                            "Glückwunsch, alle Aufgaben wurden erledigt!",
                            textAlign: TextAlign.center,
                          )
                : Text(
                    "Verbinden Sie sich mit einer Sensorbox, um Aufgaben zu erhalten.",
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
      ),
    );
  }
}
