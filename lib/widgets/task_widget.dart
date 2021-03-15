import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:data_offloading_app/Screens/foto_capturing.dart';
import 'package:data_offloading_app/Screens/foto_labelling.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../data/task.dart';
import '../provider/tasklist_state.dart';
import 'package:provider/provider.dart';
import 'package:data_offloading_app/logic/stats.dart';

class TaskWidget extends StatefulWidget {
  TaskWidget(this.task);
  final Task task;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

//This is is our TaskWidget. Every task is represented by a ExpansionTile, where you can see the title and a icon when it's unexpanded.
//When you expand the tile you also see the task description and a button to check off that task
class _TaskWidgetState extends State<TaskWidget> {
  Future<CameraDescription> _getCamera() async {
    final cameras = await availableCameras();
    //select the fron camera
    CameraDescription cam = cameras[1];
    //if there is no frontcamera take the backcamera
    if (cam == null) {
      return cameras[0];
    }
    return cam;
  }

  @override
  Widget build(BuildContext context) {
    //this local function calls a provider function that deletes the task from the global task list and calls a delete function in box_communicator
    void _deleteTask(Task task) async {
      context.read<TaskListProvider>().deleteFromTasks(task);
    }

    var tileContent;
    // if imageId is null, then this is not an image task
    if (widget.task.imageId != null) {
      // this is an image task
      String takenBy =
          widget.task.title.compareTo("Nutzerbild beschriften") == 0
              ? "einem Nutzer"
              : "der Box";
      tileContent = [
        Text(
          "Dieses Bild wurde von " + takenBy + " aufgenommen.",
          style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.black45),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.0),
        RaisedButton(
            onPressed: () async {
              var id = widget.task.imageId;
              try {
                // fetch image from database
                Map<String, dynamic> imgJson =
                    await BoxCommunicator().fetchImage(id);
                // convert bytes to image
                Uint8List bytesUint8 =
                    Uint8List.fromList(imgJson['data']['data'].cast<int>());
                String takenBy = imgJson['takenBy'];
                Image img = Image.memory(bytesUint8);

                // route to image label page and wait for return
                // return value will be the designated label

                List<String> selectedLabels = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FotoLabelPage(img, takenBy)),
                );

                // if user has set a label, then save that label to the database
                if (selectedLabels.isNotEmpty) {
                  try {
                    BoxCommunicator().setLabel(id, selectedLabels);
                    _deleteTask(widget.task);
                    Stats.increaseTask("imageTask");
                    Fluttertoast.showToast(
                        msg: "Super, Aufgabe erledigt!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } catch (e) {
                    print(e);
                  }
                }
              } catch (e) {
                print(e);
              }
            },
            child: Text(widget.task.description)),
      ];
    } else if (widget.task.title.compareTo("Baumkronen Foto") == 0) {
      // this is a task for capturing an image
      tileContent = [
        RaisedButton(
            onPressed: () async {
              CameraDescription cam = await _getCamera();
              var img = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FotoCapturePage(camera: cam)),
              );
              print(img);
              if (img != null &&
                  img["pathToImg"] != null &&
                  img["label"] != null &&
                  img["luxValue"] != null) {
                try {
                  BoxCommunicator().saveUserImage(
                      img["pathToImg"], img["label"], img["luxValue"]);
                  _deleteTask(widget.task);
                  Stats.increaseTask("imageTask");
                  Fluttertoast.showToast(
                      msg: "Super, Aufgabe erledigt!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } catch (e) {
                  print(e);
                }
              }
            },
            child: Text(widget.task.description))
      ];
    } else {
      tileContent = [
        Text(
          widget.task.description,
          style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.black45),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.0),
        RaisedButton(
          onPressed: () {
            _deleteTask(widget.task);
            Stats.increaseTask("cleaningTask");
            Fluttertoast.showToast(
                msg: "Super, Aufgabe erledigt!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                fontSize: 16.0);
          },
          textColor: Colors.white,
          padding: EdgeInsets.all(0.0),
          child: Container(
            color: Colors.green[700],
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Aufgabe erledigt!',
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        )
      ];
    }

    return Column(
      children: [
        ExpansionTile(
            title: Text(
              widget.task.title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
            ),
            leading: Icon(
              Icons.assignment_turned_in,
              size: 26,
              color: Colors.green,
            ),
            children: tileContent),
      ],
    );
  }
}
