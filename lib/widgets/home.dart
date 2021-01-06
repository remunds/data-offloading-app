import 'dart:async';

import 'package:data_offloading_app/Screens/foto_labelling.dart';
import 'package:data_offloading_app/Screens/settings.dart';
import 'package:data_offloading_app/provider/box_connection_state.dart';

import '../logic/box_communicator.dart';
import '../data/task.dart';
import 'task_widget.dart';

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Home extends StatefulWidget {
  static void getConnectionState(BuildContext context) async {
    String name = await WifiInfo().getWifiName();
    if (name == "W(G)LAN_f8805106c6" &&
        !context.read<BoxConnectionState>().connectionState) {
      if (Platform.isAndroid) {
        //force wifi so that we do not have problems with mobile data interfering api requests
        WiFiForIoTPlugin.forceWifiUsage(true);
      }
      context.read<BoxConnectionState>().connected();
    } else if (name != "W(G)LAN_f8805106c6" &&
        context.read<BoxConnectionState>().connectionState) {
      context.read<BoxConnectionState>().disconnected();
    }
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Task> _currentTasks;
  Timer _timer;

  void _fetchTasks() async {
    print("fetching tasks");
    try {
      List<Task> taskList = await BoxCommunicator().fetchTasks();
      setState(() {
        _currentTasks = taskList;
      });
    } catch (e) {
      print(e);
    }
  }

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
  void initState() {
    super.initState();
    //_fetchTasks();
    //_fetchImage();
    //check every 5 seconds for new Tasks
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      //_fetchTasks();
      //_fetchImage();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool _connection = context.watch<BoxConnectionState>().connectionState;
    print(_connection);
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.01),
      child: Column(
        children: [
          Row(
            //Make a Row with a settings button on the right side
            mainAxisAlignment:
                MainAxisAlignment.end, //align the button to the right side
            children: [
              IconButton(
                  //button initialisation
                  icon: Icon(
                    Icons.settings,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    // this is what happens when the settings button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SettingsPage()), // We use the Navigator to Route to the settings page wich is located in a new .dart file
                    );
                  }),
            ],
          ),
          Text(_connection
              ? "You are connected to a Sensorbox"
              : "You are currently not connected to a Sensorbox"),
          Expanded(
            child: ListView.builder(
              itemCount: _currentTasks == null ? 0 : _currentTasks.length,
              itemBuilder: (BuildContext context, int index) {
                return TaskWidget(_currentTasks[index]);
              },
            ),
          ),
          Expanded(
            child: GestureDetector(
              child: Card(
                child: Text("foto labelling page"),
              ),
              onTap: () async {
                var id = "5ff444933dd44d0e8aa05509";
                Image img = await _fetchImage(id);
                int selectedLabel = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FotoLabelPage(img)),
                );

                if(selectedLabel != null){
                  try {
                    BoxCommunicator().setLabel(id, selectedLabel);
                  } catch (e) {
                    print(e);
                  }
                }
              },
            )
          )
        ],
      ),
    );
  }
}
