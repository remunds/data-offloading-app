import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/download_update_state.dart';
import 'package:data_offloading_app/provider/downloadall_state.dart';
import 'package:data_offloading_app/provider/poslist_state.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:retry/retry.dart';
import 'package:provider/provider.dart';

import '../data/task.dart';
import '../data/box_position.dart';
import 'stats.dart';

/// Class for communicating with Sensorbox and Backend Server
/// This class is used for:
///   - downloading data
///   - uploading data
///   - fetching Sensorbox coordinates
///   - fetching images
///   - sending user images to server
///   - labelling images
class BoxCommunicator {
  /// number of boxes known by the server
  int _numberOfBoxes = 0;

  /// Hive [LazyBox] stores large amounts of downloaded data
  LazyBox<String> box;

  /// Hive [Box] stores global data across all files
  Box<dynamic> storage;

  /// standard headers for HTTP Requests
  Map<String, String> headers = {"Content-type": "application/json"};
  // make sure that the boxIP is not a common IP in networks,
  // as we distinguish between sensorboxes and
  // regular wifi networks by checking if boxIP is available in the current network.
  static final String boxRawIP = "10.3.141.1";
  static final String backendRawIP = "192.168.0.102";
  final String boxIP = "http://$boxRawIP:8000";
  final String backendIP = "http://$backendRawIP:8000";

  /// getter for [_numberOfBoxes]
  int getNumberOfBoxes() {
    return _numberOfBoxes;
  }

  /// uploads data stored on device to the backend with wifi connection
  /// calls /api/postData
  ///
  /// [context] build context from page calling this function
  void uploadToBackend(BuildContext context, {http.Client client}) async {
    client ??= new http.Client();

    //We use Provider.of instead of context.read because context will be passed by a StatefulWidget or StatefulElement. StatefulElement has no instance method read.
    Provider.of<DownloadUploadState>(context, listen: false).uploading();
    print("uploading");
    Box boxes = await Hive.openBox('boxes');
    String query;

    //iterate over all boxes we downloaded data from
    for (var boxVal in boxes.values) {
      String box = boxVal.toString();
      LazyBox<String> currBox = await Hive.openLazyBox(box);
      //get all the data from one Sensorbox
      for (String data in currBox.keys) {
        //if files_id is specified, given data is a chunk

        if ((await currBox.get(data)).contains("files_id")) {
          query = "?format=chunk";
        } else {
          query = "?format=file";
        }

        //check if still connected
        if (Provider.of<BoxConnectionState>(context, listen: false)
                    .connectionState ==
                Connection.SENSORBOX ||
            Provider.of<BoxConnectionState>(context, listen: false)
                    .connectionState ==
                Connection.NONE) {
          Provider.of<DownloadUploadState>(context, listen: false).idle();
          print("connection lost");
          return;
        }
        var boxResponse;
        String toSend = await currBox.get(data);
        try {
          boxResponse = await retry(
              () => client
                  .post(backendIP + "/api/postData/" + box + query,
                      headers: headers, body: toSend)
                  .timeout(Duration(seconds: 12)),
              retryIf: (e) => e is SocketException || e is TimeoutException,
              maxAttempts: 3);
        } catch (e) {
          print("failed to upload data to: $backendIP/api/postData/$box$query");
          print(e);
          Provider.of<DownloadUploadState>(context, listen: false).idle();
          return;
        }
        print("response:");
        print(boxResponse.statusCode);
        if (boxResponse.statusCode != 200) {
          //user probably left WiFi
          print("user probably left wifi");
          Provider.of<DownloadUploadState>(context, listen: false).idle();
          // client.close();
          return;
        }
        // client.close();
        //else: successfully uploaded, continue
      }
      //delete data from disk
      await currBox.deleteAll(currBox.keys);
      await currBox.deleteFromDisk();
      // await deleteBoxFromDisk(currBox);
      // await currBox.clear();
      // currBox.deleteFromDisk();
      // currBox = await Hive.openBox(box);
      // print("sizeof currBox: ${currBox.length}");
      // // currBox.close();
      // // await currBox.deleteFromDisk();
    }
    Provider.of<DownloadUploadState>(context, listen: false).idle();
    print("done uploading");
    Box storage = await Hive.openBox('storage');
    storage.put('totalSizeInBytes', 0);
  }

  /// downloads data from the server
  /// calls /api/register and /api/getData
  ///
  /// [context] build context from page calling this function
  /// data limit in MB for downloading data
  void downloadData(BuildContext context, {http.Client client}) async {
    client ??= new http.Client();
    double dataLimitInMB;
    dataLimitInMB = Hive.box('storage').get('dataLimitValueInMB',
        defaultValue: await DiskSpace.getFreeDiskSpace * 0.5);
    print("downloading...");
    Provider.of<DownloadUploadState>(context, listen: false).downloading();

    var boxName;
    final r = RetryOptions(maxAttempts: 2);
    //register to get the current boxName from the Sensorbox
    print("registering");
    var boxResponse;
    int deviceTimestamp;
    try {
      boxResponse = await r.retry(
        () => client.get(boxIP + "/api/register").timeout(Duration(seconds: 2)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
    } catch (e) {
      print("registering failed: not reachable");
      Provider.of<DownloadUploadState>(context, listen: false).idle();
      return;
    }

    if (boxResponse.statusCode == 200) {
      var res = jsonDecode(boxResponse.body);
      boxName = res["piId"];
      deviceTimestamp = res["timestamp"];
    } else {
      print("failed to register:");
      Provider.of<DownloadUploadState>(context, listen: false).idle();
      return;
    }

    //storage box stores the number of received bytes at 'totalSizeInBytes'
    storage = await Hive.openBox('storage');
    //opens the box for the current connected Sensorbox
    if (Hive.isBoxOpen(boxName.toString())) {
      box = Hive.lazyBox(boxName.toString());
    } else {
      box = await Hive.openLazyBox(boxName.toString());
    }
    Box boxes = await Hive.openBox('boxes');
    if (!boxes.values.contains(boxName)) {
      print("adding $boxName");
      boxes.add(boxName);
    }

    //list to store all the id's of files/chunks that have already
    // been downloaded/stored
    List<String> idList = [];
    Stats.setBox(storage);
    //add the current box to the list of already visited boxes stored on the hive
    Stats.addVisitedBox(boxName.toString());

    bool oldData = storage.get('oldDataSwitch', defaultValue: true);

    String query = "";
    //add priority to query
    if (oldData) {
      query += "?data=old";
    } else {
      query += "?data=new";
    }
    query += "&deviceTimestamp=$deviceTimestamp";

    try {
      //check if user pressed the download-ALL button
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
        final response = await r.retry(
            () => client
                .get(boxIP + "/api/getData" + query)
                .timeout(Duration(seconds: 5)),
            retryIf: (e) => e is SocketException || e is TimeoutException);

        if (response.statusCode == 200 && response.body.length != 0) {
          var id = jsonDecode(response.body)["_id"];
          if (id == null) {
            print('response had no id');
            continue;
          }
          print("received file: $id");

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
              continue;
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

  /// downloads all files and chunks that are not on device yet
  /// calls /api/register and /api/getAllData
  ///
  /// [context] build context from page calling this function
  void downloadAllData(BuildContext context, {http.Client client}) async {
    client ??= new http.Client();
    print("Downloading All Data ...");
    context.read<DownloadAllState>().downloadingAll();
    if (storage == null || !storage.isOpen) {
      storage = await Hive.openBox('storage');
    }
    var boxName;
    int deviceTimestamp;
    Map<String, String> headers = {
      "Content-type": "application/json",
    };

    //register to get the current boxName and get a id(timestamp) from the Sensorbox
    //we use Future.delayed to pause the completed state for a certain time to show the user completion of download
    final boxResponse = await retry(
        () => client.get(boxIP + "/api/register").timeout(Duration(seconds: 3)),
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
      if (Hive.isBoxOpen(boxName.toString())) {
        box = Hive.lazyBox(boxName.toString());
      } else {
        box = await Hive.openLazyBox(boxName.toString());
      }

      print("Registered as ID$deviceTimestamp at box with boxname " +
          boxName.toString());
    } else {
      context.read<DownloadAllState>().initial();
      throw Exception('failed to register');
    }

    //if no data has been received: start with 0.
    int totalSizeInBytes = storage.get('totalSizeInBytes', defaultValue: 0);
    //now this loop will be executed when the general download loop is paused.
    // Rest of work is done on the box
    //If chunk is already on phone next chunk will be downloaded until box sends http code 201 (all chunks sent to phone)
    try {
      while (
          Provider.of<DownloadAllState>(context, listen: false).downloadState ==
              1) {
        if (await DiskSpace.getFreeDiskSpace <= 1000) {
          print("Disk Space Limit ( >= 1000 MB) reached");
          context.read<DownloadAllState>().completed();
          await Future.delayed(const Duration(minutes: 2));
          context.read<DownloadAllState>().initial();
          break;
        }

        final response = await retry(
            () => client
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
          if (box.containsKey(id)) {
            log("ID already on Box");
            continue;
          } else {
            box.put(id, response.body);
            storage.put(
                'totalSizeInBytes', totalSizeInBytes + response.contentLength);
            print("new entry at: " + DateTime.now().toString());
          }
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
    } catch (err) {
      print("User Left");
      print(err);
      context.read<DownloadAllState>().initial();
    }
  }

  /// fetches tasks from server
  /// calls /api/getTasks
  ///
  /// returns a list of [Task]
  /// or throws Exception if tasks could not be loaded from server
  Future<List<Task>> fetchTasks({http.Client client}) async {
    client ??= new http.Client();

    final response = await retry(
        () => client
            .get(boxIP + "/api/getTasks", headers: headers)
            .timeout(Duration(seconds: 3)),
        retryIf: (e) => e is SocketException || e is TimeoutException);

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

  /// sends a request to delete [task]
  /// calls /api/deleteTask
  ///
  /// [task] task to be deleted
  ///
  /// returns the status code of the server call
  Future<int> deleteTask(Task task, {http.Client client}) async {
    client ??= new http.Client();
    //enconding the task to JSON
    String taskDel = json.encode(task);

    // sending a http post to the sensorbox to delete the task from our db.
    final response = await retry(
        () => client
            .post(boxIP + "/api/deleteTask", headers: headers, body: taskDel)
            .timeout(Duration(seconds: 3)),
        retryIf: (e) => e is SocketException || e is TimeoutException);

    return response.statusCode;
  }

  /// fetches image from server
  /// calls /api/getImage
  ///
  /// [id] image id
  ///
  /// returns image as map with fields 'data', 'labels' and 'takenBy'
  Future<Map<String, dynamic>> fetchImage(var id, {http.Client client}) async {
    client ??= new http.Client();
    final response = await retry(
        () => client
            .get(boxIP + "/api/getImage/?id=$id", headers: headers)
            .timeout(Duration(seconds: 3)),
        retryIf: (e) => e is SocketException || e is TimeoutException);

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

  /// sends image labels to server
  /// calls /api/putLabel route
  ///
  /// [id] image id
  /// [labels] list of selected labels
  ///
  /// throws Exception if labels could not be saved on server
  void setLabel(var id, List<String> labels, {http.Client client}) async {
    client ??= new http.Client();
    String labelsStr =
        labels.toString().substring(1, labels.toString().length - 1);

    var body = {'id': id, 'label': labelsStr};
    final response = await retry(
        () => client
            .post(boxIP + "/api/putLabel",
                body: json.encode(body), headers: headers)
            .timeout(Duration(seconds: 3)),
        retryIf: (e) => e is SocketException || e is TimeoutException);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print("successfully saved labels");
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      throw Exception('failed to save label');
    }
  }

  /// fetches the lat and long coordinates from all sensorboxes
  /// calls /api/getPosition/ route
  ///
  /// returns sensorbox coordinates as future list of [BoxPosition]
  Future<void> fetchPositions(BuildContext context, State caller,
      {http.Client client}) async {
    List<BoxPosition> posList = List<BoxPosition>();
    client ??= new http.Client();
    int currBox = 1;
    String url = backendIP + "/api/getPosition/" + currBox.toString();

    var response = await retry(
        () => client.get(url, headers: headers).timeout(Duration(seconds: 3)),
        retryIf: (e) => e is SocketException || e is TimeoutException);

    if (response.statusCode != 200) {
      print("StatusCode " + response.statusCode.toString());
      print("Something went wrong!");
      return;
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
      response = await retry(
          () => client.get(url, headers: headers).timeout(Duration(seconds: 3)),
          retryIf: (e) => e is SocketException || e is TimeoutException);
    }
    _numberOfBoxes = currBox - 1;
    if (caller.mounted) context.read<PosListProvider>().setPositions(posList);
  }

  /// sends a HTTP Multipart Request to box server, containing the user image and selected labels
  /// calls /api/saveUserImage route
  ///
  /// [imgPath] path to image file
  /// [labels] array of selected labels
  /// [luxValue] value of light sensor during image capturing
  ///
  /// throws Exception if image could not be saved on server
  void saveUserImage(var imgPath, var labels, var luxValue,
      {http.Client client}) async {
    // array of labels to string for simplified transmission in json
    String labelsStr =
        labels.toString().substring(1, labels.toString().length - 1);
    client ??= new http.Client();
    var req =
        http.MultipartRequest('POST', Uri.parse(boxIP + "/api/saveUserImage"));

    req.files.add(await http.MultipartFile.fromPath('data', imgPath));
    req.fields['label'] = labelsStr;
    // set takenBy field to user to distinguish from box images
    req.fields['takenBy'] = 'user';
    req.fields['luxValue'] = luxValue;
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
