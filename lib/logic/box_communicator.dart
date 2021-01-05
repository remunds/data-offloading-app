
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/task.dart';

class BoxCommunicator {
  Future<List<Task>> fetchTasks() async {
    Map<String, String> headers = {"Content-type": "application/json"};
    final response =
        await http.get("http://192.168.178.26:8000/api/getTasks", headers: headers);

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
  Future<Image> fetchImage(var id) async {
    Map<String, String> headers = {"Content-type": "image/jpeg"};
    final response =
    await http.get("http://192.168.178.26:8000/api/getImage/?id=${id}", headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> taskListJson = jsonDecode(response.body);
      Uint8List bytesUint8 = Uint8List.fromList(taskListJson['data']['data'].cast<int>());
      return Image.memory(bytesUint8);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('failed to fetch image');
    }
  }
}
