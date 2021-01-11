import 'package:flutter/material.dart';

import '../data/task.dart';
import '../logic/box_communicator.dart';

//This is the taskList Provider. It has a method to fetch and delete tasks and notifies its listenters if something changes
class TaskListProvider with ChangeNotifier {
  List<Task> _taskList = List();

  List<Task> get taskList => _taskList;

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

  void deleteFromTasks(Task task) async {
    //getting the response code of the sensorbox. The deletion is successfull if code 200 is returned.
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
