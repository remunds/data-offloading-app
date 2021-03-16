import 'package:flutter/material.dart';

import '../data/task.dart';
import '../logic/box_communicator.dart';

/// Provider for list of [Task]
class TaskListProvider with ChangeNotifier {

  /// list of [Task]
  List<Task> _taskList = List();

  List<Task> get taskList => _taskList;

  /// fetches Tasks from server and notifies listeners
  void awaitTasks() {
    BoxCommunicator().fetchTasks().then((taskList) {
      if (taskList == null) {
        print("error fetching tasks");
      } else {
        _taskList = taskList;
        notifyListeners();
      }
    });
  }

  /// deletes [task] from server and notifies listeners
  void deleteFromTasks(Task task) async {
    //getting the response code of the sensorbox. The deletion is successful if code 200 is returned.
    int response = await BoxCommunicator().deleteTask(task);
    if (response == 200) {
      _taskList.remove(task);
      notifyListeners();
    } else {
      print(response);
      throw Exception("Failed to delete task");
    }
  }
}
