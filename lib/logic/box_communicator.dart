import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/data/idAndTimestamp.dart';
import 'package:data_offloading_app/provider/download_update_state.dart';
import 'package:data_offloading_app/provider/downloadall_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:retry/retry.dart';
import 'package:provider/provider.dart';

import '../data/task.dart';
import '../data/box_position.dart';
import 'stats.dart';

class BoxCommunicator {
  double dataLimitInMB =
      Hive.box('storage').get('dataLimitValueInMB', defaultValue: 10.0);
  int _numberOfBoxes = 0;
  LazyBox<String> box;
  Box<dynamic> storage;

  int getNumberOfBoxes() {
    return _numberOfBoxes;
  }

  Map<String, String> headers = {"Content-type": "application/json"};
  final String boxIP =
      "http://10.3.141.1:8000"; //"http://192.168.178.26:8000"; //
  final String backendIP = "http://192.168.0.64:8001";

  void uploadToBackend(context) async {
    //We use Provider.of instead of context.read because context will be passed by a StatefulWidget or StatefulElement. StatefulElement has no instance method read.
    Provider.of<DownloadUploadState>(context, listen: false).uploading();
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
        if (Provider.of<BoxConnectionState>(context, listen: false)
                .connectionState !=
            Connection.SENSORBOX) {
          Provider.of<DownloadUploadState>(context, listen: false).idle();
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
          Provider.of<DownloadUploadState>(context, listen: false).idle();
          return;
        }
        //else: succesfully uploaded, continue
      }
      //delete data from disk
      await currBox.deleteFromDisk();
    }
    Provider.of<DownloadUploadState>(context, listen: false).idle();
  }

  void downloadData(context) async {
    print("downloading...");
    Provider.of<DownloadUploadState>(context, listen: false).downloading();

    var boxName;
    final r = RetryOptions(maxAttempts: 5);
    //register to get the current boxName from the Sensorbox
    final boxResponse = await r.retry(
        () => http.get(boxIP + "/api/register").timeout(Duration(seconds: 3)),
        retryIf: (e) => e is SocketException || e is TimeoutException);

    if (boxResponse.statusCode == 200) {
      var res = jsonDecode(boxResponse.body);
      boxName = res["piId"];
    } else {
      print('failed to register');
      Provider.of<DownloadUploadState>(context, listen: false).idle();
      return;
    }

    //storage box stores the number of received bytes at 'totalSizeInBytes'
    storage = await Hive.openBox('storage');
    //opens the box for the current connected Sensorbox
    box = await Hive.openLazyBox(boxName.toString());
    Box boxes = await Hive.openBox('boxes');
    boxes.add(boxName);

    //list to store all the id's of files/chunks that have already
    // been downloaded/stored
    List<String> idList = [];
    Stats.setBox(storage);
    //add the current box to the list of already visited boxes stored on the hive
    Stats.addVisitedBox(boxName);

    bool oldData = storage.get('oldDataSwitch', defaultValue: true);

    String query = "";
    //add priority to query
    if (oldData) {
      query += "?data=old";
    } else {
      query += "?data=new";
    }

    try {
      while (
          Provider.of<DownloadAllState>(context, listen: false).downloadState !=
              1) {
        int totalSizeInBytes = storage.get('totalSizeInBytes', defaultValue: 0);
        //is the data limit reached?
        if (totalSizeInBytes > dataLimitInMB * 1000000) {
          print("data limit reached");
          Provider.of<DownloadUploadState>(context, listen: false).idle();
          break;
        }
        //make getData call to collect data chunks or files from box
        final response = await retry(
            () => http
                .get(boxIP + "/api/getData" + query)
                .timeout(Duration(seconds: 3)),
            retryIf: (e) => e is SocketException || e is TimeoutException);

        if (response.statusCode == 200 && response.body.length != 0) {
          var id = jsonDecode(response.body)["_id"];
          if (id == null) {
            print('response had no id');
            continue;
          }

          if (await box.get(id) != null || idList.contains(id)) {
            //all files of the current box have been downloaded or checked (sizeLimit reached)
            print("got all files");
            Provider.of<DownloadUploadState>(context, listen: false).idle();
            break;
          }
          //add the current id to the idList, so we can later check whether we had this file already
          idList.add(id);

          //for priority: split data string so that we can use the
          // timestamp to compare values.
          int incomingTime = jsonDecode(response.body)[
                  "timestamp"] ?? //if null: use after "??", else before
              jsonDecode(response.body)["uploadDate"];
          if (incomingTime == null) {
            print("error getting time from response");
            Provider.of<DownloadUploadState>(context, listen: false).idle();
            break;
          }

          //check for data limit
          if (totalSizeInBytes > dataLimitInMB * 1000000) {
            print("data limit reached, only replacing older/newer files now");
            //for priority: decode data string so that we can use the
            // timestamp to compare values.
            int incomingTime = jsonDecode(response.body)[
                    "timestamp"] ?? //if null: use after "??", else before
                jsonDecode(response.body)["uploadDate"];
            if (incomingTime == null) {
              print("error getting time from response");
              break;
            }

            for (int i = 0; i < box.length; i++) {
              String data = await box.getAt(i);

              int currTime = jsonDecode(data)["timestamp"] ??
                  jsonDecode(data)["uploadDate"];
              if (currTime == null) {
                print("error getting time from current box value");
                continue;
              }
              //compare current data's timestamp to the received data's timestamp
              // if oldDataSwitch is on: replace if incomingTime is older, else if incomingTime is younger.
              bool replace =
                  oldData ? currTime > incomingTime : currTime < incomingTime;
              if (replace) {
                //replace the current data on the smartphone because it is older than the incoming data
                // and therefore has the lower priority
                await box.deleteAt(i);
                await box.put(id, response.body);
                //if we want the storage to be extremely accurate,
                // we need to get the size of the deleted key here and
                // subtract it from 'totalSizeInBytes' and add the
                // new contentLength like this:
                // storage.put('totalSizeInBytes',
                //     totalSizeInBytes - oldKeySize + response.contentLength);
                print("new entry at: ");
                print(DateTime.now());
              } else {
                print("skipped one entry");
              }
            }
          } else {
            await box.put(id, response.body);
            //add size of this response to size of all data combined (for limiting data usage)
            await storage.put(
                'totalSizeInBytes', totalSizeInBytes + response.contentLength);
            print("new entry at: ");
            print(DateTime.now());
          }
        } else {
          // If the server did not return a 200 OK response,
          // then throw an exception.
          print(response.statusCode);
          print("done downloading");
          Provider.of<DownloadUploadState>(context, listen: false).idle();
          break;
        }
      }
    } catch (err) {
      //user probably left the current Sensorbox
      print("user left:");
      print(err);
    }
    Provider.of<DownloadUploadState>(context, listen: false).idle();
    await box.close();
  }

  //This function is called when a button on the settings page is pressed. After that
  //the method will be executed. Normally all files and chunks will be downloaded that
  //are not on device yet.
  void downloadAllData(BuildContext context) async {
    print("Downloading All Data ...");
    context.read<DownloadAllState>().downloadingAll();
    if (storage == null || !storage.isOpen) {
      storage = await Hive.openBox('storage');
    }
    var boxName;
    int deviceTimestamp;
    List idList = List();
    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    //register to get the current boxName and get a id(timestamp) from the Sensorbox
    //we use Future.delayed to pause the completed state for a certain time to show the user completion of download
    final boxResponse = await retry(
        () => http.get(boxIP + "/api/register").timeout(Duration(seconds: 3)),
        retryIf: (e) => e is SocketException || e is TimeoutException);
    if (boxResponse.statusCode == 200) {
      var res = jsonDecode(boxResponse.body);
      if (res["piId"] == null || res["timestamp"] == null) {
        print("Failed to get piId or Timestamp");
        context.read<DownloadAllState>().completed();
        await Future.delayed(const Duration(seconds: 15));
        context.read<DownloadAllState>().initial();
        return;
      }
      boxName = res["piId"];
      deviceTimestamp = res["timestamp"];
      //storage box stores the number of received bytes at 'totalSizeInBytes'
      //opens the box for the current connected Sensorbox
      if (box == null || !box.isOpen) {
        box = await Hive.openLazyBox(boxName);
      }
      print("Opened box with boxname " + boxName.toString());
      //If List of IDs is empty execute the download without a data limit and without priority restrictions
      if (box.length > 0) {
        idList = box.keys.toList();
      }
      //after getting list of ids on device for corresponding boxname we send the list to the box among device id (timestamp)
      IdListAndTimeStamp idListAndTimeStamp =
          new IdListAndTimeStamp(timestamp: deviceTimestamp, idList: idList);
      String body = json.encode(idListAndTimeStamp);
      final currentDataRegisterResponse = await retry(
          () => http
              .post(boxIP + "/api/registerCurrentData",
                  headers: headers, body: body)
              .timeout(Duration(seconds: 3)),
          retryIf: (e) => e is SocketException || e is TimeoutException);
      // if the files db AND chunk db is empty we get a notification and the download stops
      if (currentDataRegisterResponse.statusCode == 201) {
        print("No data on box");
        context.read<DownloadAllState>().completed();
        await Future.delayed(const Duration(seconds: 15));
        context.read<DownloadAllState>().initial();
        return;
      }
      if (currentDataRegisterResponse.statusCode == 200) {
        print("Box recieved ids and timestamp successfully");
      } else {
        throw Exception('Failed to send IDs and timestamp with status code ' +
            currentDataRegisterResponse.statusCode.toString());
      }
    } else {
      throw Exception('failed to register');
    }

    //if no data has been received: start with 0.
    int totalSizeInBytes = storage.get('totalSizeInBytes', defaultValue: 0);
    //now this loop will be executed when the general download loop is paused.
    // Rest of work is done on the box
    while (
        Provider.of<DownloadAllState>(context, listen: false).downloadState ==
            1) {
      final response = await retry(
          () => http
              .get(boxIP + "/api/getAllData?deviceTimestamp=$deviceTimestamp",
                  headers: headers)
              .timeout(Duration(seconds: 3)),
          retryIf: (e) => e is SocketException || e is TimeoutException);

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);

        var id = res["_id"];

        if (id == null) {
          print('response had no id');
          continue;
        }

        box.put(id, response.body);

        storage.put(
            'totalSizeInBytes', totalSizeInBytes + response.contentLength);
        print("new entry at: " + DateTime.now().toString());
      } else if (response.statusCode == 201) {
        print("Status Code: " + response.statusCode.toString());
        print('data download is finished');
        context.read<DownloadAllState>().completed();
        await Future.delayed(const Duration(minutes: 2));
        context.read<DownloadAllState>().initial();
        break;
      } else {
        print("Status Code: " + response.statusCode.toString());
        print('failed to get any data');
      }
    }
  }

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(boxIP + "/api/getTasks", headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> taskListJson = jsonDecode(response.body);
      List<Task> taskList = List<Task>();

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

  Future<Map<String, dynamic>> fetchImage(var id) async {
    final response =
        await http.get(boxIP + "/api/getImage/?id=$id", headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> img = jsonDecode(response.body);
      return img;
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
    var req =
        http.MultipartRequest('POST', Uri.parse(boxIP + "/api/saveUserImage"));

    req.files.add(await http.MultipartFile.fromPath('data', imgPath));
    req.fields['label'] = label;
    // set type to user to distinguish from box images
    req.fields['takenBy'] = 'user';

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
