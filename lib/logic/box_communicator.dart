import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:retry/retry.dart';

import '../data/task.dart';
import '../data/box_position.dart';

class BoxCommunicator {
  final int dataLimitInkB = 100;
  int _numberOfBoxes = 0;

  int getNumberOfBoxes() {
    return _numberOfBoxes;
  }

  Map<String, String> headers = {"Content-type": "application/json"};
  final String boxIP = "http://10.3.141.1:8000";
  final String backendIP = "http://192.168.0.64:8001";

  void uploadToBackend(context) async {
    print("uploading");
    Box boxes = await Hive.openBox('boxes');
    String query;

    //iterate over all Sensorboxes we downloaded data from
    for (String box in boxes.values) {
      Box currBox = await Hive.openBox(box);
      //get all the data from one Sensorbox
      for (String data in currBox.values) {
        //if files_id is specified, given data is a chunk
        if (data.contains("files_id")) {
          query = "?format=chunk";
        } else {
          query = "?format=file";
        }

        //check if still connected
        if (!context.read<BoxConnectionState>().connectionState) {
          return;
        }
        final boxResponse = await retry(
            () => http
                .get(backendIP + "/api/postData/" + box + query)
                .timeout(Duration(seconds: 3)),
            retryIf: (e) => e is SocketException || e is TimeoutException);
        if (boxResponse.statusCode != 200) {
          //user probably left WiFi
          print("user probably left wifi");
          return;
        }
        //else: succesfully uploaded, continue
      }
      //delete data from disk
      await currBox.deleteFromDisk();
    }
  }

  void downloadData() async {
    print("downloading...");
    String boxName;
    final r = RetryOptions(maxAttempts: 5);
    //register to get the current boxName from the Sensorbox
    final boxResponse = await r.retry(
        () => http.get(boxIP + "/api/register").timeout(Duration(seconds: 3)),
        retryIf: (e) => e is SocketException || e is TimeoutException);

    if (boxResponse.statusCode == 200) {
      var res = jsonDecode(boxResponse.body);
      boxName = res["piID"];
    } else {
      throw Exception('failed to register');
    }

    //storage box stores the number of received bytes at 'totalSizeInBytes'
    Box storage = await Hive.openBox('storage');
    //opens the box for the current connected Sensorbox
    LazyBox box = await Hive.openLazyBox(boxName);
    Box boxes = await Hive.openBox('boxes');
    boxes.add(boxName);

    //if no data has been received: start with 0.
    int totalSizeInBytes = storage.get('totalSizeInBytes', defaultValue: 0);
    try {
      while (true) {
        //is the data limit reached?
        if (totalSizeInBytes > dataLimitInkB * 1000) {
          print("data limit reached");
          break;
        }
        //make getData call to collect data chunks or files from box
        final response = await r.retry(
            () =>
                http.get(boxIP + "/api/getData").timeout(Duration(seconds: 3)),
            retryIf: (e) => e is SocketException || e is TimeoutException);

        if (response.statusCode == 200) {
          var id = jsonDecode(response.body)["_id"];
          if (id == null) {
            print('response had no id');
            continue;
          }
          //all files of the current box have been downloaded
          if (await box.get(id) != null) {
            print("got all files");
            break;
          }
          await box.put(id, response.body);
          //add size of this response to size of all data combined (for limiting data usage)
          storage.put(
              'totalSizeInBytes', totalSizeInBytes + response.contentLength);
          print("new entry at: ");
          print(DateTime.now());
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          print(response.statusCode);
          print('failed to get any data');
          return;
        }
      }
    } catch (err) {
      //user probably left the current Sensorbox
      print("user left:");
      print(err);
    }
    await box.close();
  }

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(boxIP + "/api/getTasks", headers: headers);

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

    // sending a http post to the sensorbox to delete the task from our db.
    final response = await http.post(boxIP + "/api/deleteTask",
        headers: headers, body: taskDel);
    return response.statusCode;
  }

  Future<Image> fetchImage(var id) async {
    final response =
        await http.get(boxIP + "/api/getImage/?id=$id", headers: headers);

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
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }

  void setLabel(var id, String label) async {
    var body = {'id': id, 'label': label};
    final response = await http.post(boxIP + "/api/putLabel",
        body: json.encode(body), headers: headers);

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

  //fetches the lat and long coordinates from all sensorboxes
  Future<List<BoxPosition>> fetchPositions() async {
    List<BoxPosition> posList = new List<BoxPosition>();
    int currBox = 1;
    String url = backendIP + "/api/getPosition/" + currBox.toString();
    dynamic response = await http.get(url, headers: headers);
    if (response.statusCode != 200) {
      print("StatusCode " + response.statusCode.toString());
      print("Something went wrong!");
      return null;
    }
    //request sensorbox positions until no boxes are left
    while (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> posListJson = jsonDecode(response.body);
      posList.addAll(posListJson.entries
          .map((elem) => BoxPosition.fromJson(elem))
          .toList());

      ++currBox;
      String url = backendIP + "/api/getPosition/" + currBox.toString();
      response = await http.get(url, headers: headers);
    }
    _numberOfBoxes = currBox - 1;
    print(posList);

    return posList;
  }

  void saveUserImage(var imgPath, var label) async {
    String base64Img = base64Encode(File(imgPath).readAsBytesSync());

    var req =
        http.MultipartRequest('POST', Uri.parse(boxIP + "/api/saveUserImage"));
    req.files.add(http.MultipartFile.fromString('data', base64Img));
    req.fields['label'] = label;
    req.fields['type'] = 'image/jpeg'; // TODO: is type necessary?
    final response = await req.send();

    if (response.statusCode == 200) {
      print("successfully saved user image with label");
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('failed to save image');
    }
  }
}
