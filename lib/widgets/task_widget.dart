import 'package:flutter/material.dart';
import '../data/task.dart';
import '../logic/box_communicator.dart';

class TaskWidget extends StatelessWidget {
  TaskWidget(this.task);
  final Task task;
  final date = new DateTime.now();

  @override
  Widget build(BuildContext context) {
    void _deleteTask(Task task) {
      BoxCommunicator().deleteTask(task, context);
    }

    return Column(
      children: [
        ExpansionTile(
          title: Text(
            task.title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
          ),
          leading: Icon(
            Icons.assignment_turned_in,
            size: 26,
            color: Colors.green,
          ),
          children: [
            Text(
              task.description,
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.0),
            RaisedButton(
              onPressed: () => {_deleteTask(task)},
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
          ],
        ),
      ],
    );
  }
}
