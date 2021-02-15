import 'package:data_offloading_app/provider/tasklist_state.dart';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_offloading_app/logic/stats.dart';
import 'dart:io';
import 'package:data_offloading_app/provider/box_connection_state.dart';

void main() async {
  test("TaskListProviderTest", () {
    TaskListProvider tLP = new TaskListProvider();
    tLP.awaitTasks();
    print(tLP.taskList);
  });
}
