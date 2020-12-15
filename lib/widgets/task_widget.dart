import 'package:flutter/material.dart';
import '../data/task.dart';

class TaskWidget extends StatelessWidget {
  TaskWidget(this.task);
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
      ),
    );
  }
}
