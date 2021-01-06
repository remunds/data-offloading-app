import 'package:flutter/material.dart';

import '../data/task.dart';
import '../logic/box_communicator.dart';

class TaskListProvider with ChangeNotifier {
  List<Task> _taskList = [];

  List<Task> get taskList => _taskList;

  Future<List<Task>> awaitTasks() async {
    print("Provider Task Fetching");
    try {
      List<Task> taskList = await BoxCommunicator().fetchTasks();
      _taskList = taskList;
      notifyListeners();
      return _taskList;
    } catch (e) {
      print(e);
      return _taskList;
    }
  }

  void deleteFromTasks(Task task) async {
    List<Task> taskList = await BoxCommunicator().fetchTasks();
    _taskList = taskList;
    _taskList.remove(task);
    notifyListeners();
  }
}
