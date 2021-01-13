import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/task.dart';

class BoxCommunicator {
  Future<List<Task>> fetchTasks() async {
    Map<String, String> headers = {"Content-type": "application/json"};
    final response =
        await http.get("http://10.3.141.1:8000/api/getTasks", headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> taskListJson = jsonDecode(response.body);
      List<Task> taskList = new List<Task>();

      taskList = taskListJson.map((elem) => Task.fromJson(elem)).toList();

      return taskList;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('failed to load tasks');
    }
  }

  //This is the way to communicate the deletion of a task with the box
  Future<int> deleteTask(Task task) async {
    //enconding the task to JSON
    String taskDel = json.encode(task);

    Map<String, String> headers = {
      "Content-type": "application/json",
    };
    // sending a http post to the sensorbox to delete the task from our db.
    final response = await http.post("http://10.3.141.1:8000/api/deleteTask",
        headers: headers, body: taskDel);
    return response.statusCode;
  }

  Future<Image> fetchImage(var id) async {
    Map<String, String> headers = {"Content-type": "image/jpeg"};
    final response = await http
        .get("http://10.3.141.1:8000/api/getImage/?id=$id", headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> img = jsonDecode(response.body);
      Uint8List bytesUint8 =
          Uint8List.fromList(img['data']['data'].cast<int>());
      return Image.memory(bytesUint8);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('failed to fetch image');
    }
  }

  void setLabel(var id, int label) async {
    var body = {'id': id, 'label': label.toString()};
    final response = await http.post("http://10.3.141.1:8000/api/putLabel",
        body: json.encode(body), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      print("successfully saved label");
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('failed to save label');
    }
  }
}
