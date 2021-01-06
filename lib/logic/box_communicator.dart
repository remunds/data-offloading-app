import 'package:data_offloading_app/provider/taskList.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/task.dart';

import 'package:provider/provider.dart';

class BoxCommunicator {
  Future<List<Task>> fetchTasks() async {
    Map<String, String> headers = {"Content-type": "application/json"};
    final response =
        await http.get("http://10.3.141.1:8000/api/getTasks", headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print("Hier 0");
      List<dynamic> taskListJson = jsonDecode(response.body);
      print("Printing Tasks from Json: " + taskListJson.toString());
      List<Task> taskList = List<Task>(taskListJson.length);
      for (int i = 0; i < taskListJson.length; ++i) {
        print("Hier 1");
        taskList[i] = Task.fromJson(taskListJson[i]);
        print("Hier 2 ");
      }
      return taskList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('failed to load tasks');
    }
  }

  void deleteTask(Task task, BuildContext context) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    final response = await http.post("http://10.3.141.1:8000/api/deleteTask",
        headers: headers, body: jsonEncode(task));

    if (response.statusCode == 200) {
      context.read<TaskListProvider>().deleteFromTasks(task);
      print("Deleted Task");
    } else {
      print(response.statusCode);
      throw Exception("Failed to delete task");
    }
  }
}
