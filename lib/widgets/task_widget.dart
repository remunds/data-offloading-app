import 'package:data_offloading_app/Screens/foto_labelling.dart';
import 'package:data_offloading_app/logic/box_communicator.dart';
import 'package:flutter/material.dart';
import '../data/task.dart';
import '../provider/tasklist_state.dart';
import 'package:provider/provider.dart';

class TaskWidget extends StatefulWidget {
  TaskWidget(this.task);
  final Task task;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

//This is is our TaskWidget. Every task is represented by a ExpansionTile, where you can see the title and a icon when it's unexpanded.
//When you expand the tile you also see the task description and a button to check off that task
class _TaskWidgetState extends State<TaskWidget> {
  Future<Image> _fetchImage(String id) async {
    print("fetching image");
    try {
      return await BoxCommunicator().fetchImage(id);
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    //this local function calls a provider function that deletes the task from the global task list and calls a delete function in box_communicator
    void _deleteTask(Task task) async {
      context.read<TaskListProvider>().deleteFromTasks(task);
    }

    var tile_content;
    if (widget.task.imageId == null) {
      tile_content = [
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
          onPressed: () => {_deleteTask(widget.task)},
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
    } else {
      tile_content = [
        RaisedButton(
            onPressed: () async {
              var id = "5ff5e24be9ee9419f4d58c82";
              Image img = await _fetchImage(id);
              int selectedLabel = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FotoLabelPage(img)),
              );

              if (selectedLabel != null) {
                try {
                  BoxCommunicator().setLabel(id, selectedLabel);
                  _deleteTask(widget.task);
                } catch (e) {
                  print(e);
                }
              }
            },
            child: Text(widget.task.description)),
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
            children: tile_content),
      ],
    );
  }
}
