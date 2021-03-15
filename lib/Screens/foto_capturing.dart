import 'dart:io';

import 'package:camera/camera.dart';
import 'package:data_offloading_app/Screens/foto_labelling.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:light/light.dart';

class FotoCapturePage extends StatefulWidget {
  final CameraDescription camera;

  const FotoCapturePage({
    @required this.camera,
  });

  @override
  _FotoCapturePageState createState() => _FotoCapturePageState();
}

class _FotoCapturePageState extends State<FotoCapturePage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<int> getLuxValue() async {
    Light _light = new Light();
    Future<int> luxvalue = _light.lightSensorStream.first;
    return luxvalue;
  }

  Future<void> _showCameraInfo() async {
    double verticalPadding = MediaQuery.of(context).size.height * 0.3;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.2;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Warum wird nur die Frontkamera angezeigt?',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0),
            ),
            content: Center(
                child: Text(
                    "Die Helligkeitssensoren deines Smartphones befinden sich nur auf der Vorderseite. "
                    "Deswegen solltest du das Baumkronenfoto mit der Frontkamera machen!")),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Ok',
                    style: TextStyle(color: Colors.lightGreen),
                  ))
            ],
            insetPadding: EdgeInsets.symmetric(
                vertical: verticalPadding * 0.95,
                horizontal: horizontalPadding),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // disable auto rotation of screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text('Nimm ein Foto auf'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                _showCameraInfo();
              })
        ],
      ),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and log where it's been saved.
            // var file = await ImagePicker.pickImage(source: ImageSource.camera);
            XFile xf = await _controller.takePicture();
            String luxValue;
            //this means that the back camera is selected
            if (_controller.description.name == "0") {
              luxValue = "0";
            } else {
              luxValue = (await getLuxValue()).toString();
            }
            Image img = Image.file(File(xf.path));

            // If the picture was taken, display it on a new screen.
            List<String> selectedLabels = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FotoLabelPage(img, "user"),
              ),
            );

            Navigator.pop(context, {
              "label": selectedLabels,
              "pathToImg": xf.path,
              "luxValue": luxValue
            });
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}
