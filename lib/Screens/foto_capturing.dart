import 'dart:io';

import 'package:camera/camera.dart';
import 'package:data_offloading_app/Screens/foto_labelling.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            Image img = Image.file(File(xf.path));

            // If the picture was taken, display it on a new screen.
            List<String> selectedLabels = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FotoLabelPage(img, "user"),
              ),
            );

            Navigator.pop(
                context, {"label": selectedLabels, "pathToImg": xf.path});
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}
