import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/task.dart';

class BoxCommunicator {
  Future<List<Task>> fetchTasks() async {
    Map<String, String> headers = {"Content-type": "application/json"};
    final response = await http
        .get("http://10.3.141.1:8000/api/getData/pi1/tasks", headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> taskListJson = jsonDecode(response.body);
      List<Task> taskList = List<Task>(taskListJson.length);
      for (int i = 0; i < taskListJson.length; ++i) {
        taskList[i] = Task.fromJson(taskListJson[i]);
      }
      return taskList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('failed to load tasks');
    }
  }
}
