// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'dart:html';
import 'dart:io';

import 'package:data_offloading_app/data/box_position.dart';
import 'package:data_offloading_app/data/task.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:data_offloading_app/main.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/download_update_state.dart';
import 'package:data_offloading_app/provider/downloadall_state.dart';
import 'package:data_offloading_app/provider/poslist_state.dart';
import 'package:data_offloading_app/provider/tasklist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

class MockContext extends Mock implements BuildContext {}

Future<void> deleteHiveFromDisk() async {
  // Get the application's document directory
  var appDir = await getApplicationDocumentsDirectory();

  // // Get the chosen sub-directory for Hive files
  var hiveDb = Directory('${appDir.path}/hive_storage');

  // // Delete the Hive directory and all its files
  hiveDb.delete(recursive: true);

  print("deleted: ${appDir.path}/hive_storage/");
}

void main() async {
  var appDir = await getApplicationDocumentsDirectory();
  var path = Directory('${appDir.path}').path;
  // var path = Directory.current.path;
  Hive.init(path + '/hive_storage');
  await Hive.openBox('storage');
  BoxCommunicator boxC = BoxCommunicator();
  Box boxes = await Hive.openBox('boxes');
  Box box1 = await Hive.openBox('1');
  BuildContext testContext;

  testWidgets('box communicator test', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BoxConnectionState()),
        ChangeNotifierProvider(create: (_) => TaskListProvider()),
        ChangeNotifierProvider(create: (_) => DownloadAllState()),
        ChangeNotifierProvider(create: (_) => PosListProvider()),
        ChangeNotifierProvider(create: (_) => DownloadUploadState()),
      ],
      builder: (context, child) {
        testContext = context;
        return MainApp();
      },
    ));

    // function needs to think that we are connected to a sensorbox
    Provider.of<BoxConnectionState>(testContext, listen: false)
        .connectedToSensorbox();

    boxes.add('1');
    box1.put("id:1", "data: adsfasdfadfs");
    expect(box1.length, 1);
    expect(File(path + '/hive_storage/1.hive').existsSync(), true);
    expect(File(path + '/hive_storage/1.lock').existsSync(), true);

    final client = MockClient();
    when(client.post(boxC.backendIP + "/api/postData/1?format=file",
            body: anyNamed("body")))
        .thenAnswer((_) async => http.Response('', 200));
    await boxC.uploadToBackend(testContext, client: client);
    print("after boxC");
    expect(File(path + '/hive_storage/1.lock').existsSync(), false);
    expect(File(path + '/hive_storage/1.hive').existsSync(), false);
    await deleteHiveFromDisk();
    await tester.binding.idle();

    // fetch task test
    List<Task> lT = await boxC.fetchTasks(client: client);
    expect(lT.length > 0, true);

    // delete task test
    int statusCode =
        await boxC.deleteTask(new Task(description: "test"), client: client);
    expect(statusCode, 200);

    // fetch image test
    int id = 1;
    Map<String, dynamic> img = await boxC.fetchImage(id, client: client);
    expect(img, isNot(equals(null)));

    //fetch positions
    List<BoxPosition> bP = await boxC.fetchPositions(client: client);
    expect(bP, isNot(equals(null)));

    // set label
    String label1 = "label1";
    expect(() => boxC.setLabel(id, label1, client: client),
        isNot(throwsException));

    // save user image
    String label2 = "label2";
    expect(() => boxC.saveUserImage(path, label2, client: client),
        isNot(throwsException));
  });
  // });
}
