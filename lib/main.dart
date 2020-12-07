import 'package:flutter/material.dart';

void main() => runApp(MyApp()); //runs the main application widget

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Data Offloading App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.green, //Theme color of the app
      ),
      home: BaseAppWidget(), //"home" page
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class BaseAppWidget extends StatefulWidget {
  BaseAppWidget({Key key}) : super(key: key); //muss ich noch herausfinden

  @override
  _BaseAppWidgetState createState() =>
      _BaseAppWidgetState(); //Because the apps basic structure is stateful and never changes its state we have to create a state.
}

/// This is the private State class that goes with BaseAppWidget.
class _BaseAppWidgetState extends State<BaseAppWidget> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    //Function that sets the state of the bottom bar to the selected icon (index 0 for "Karte", index 1 for "Uebersicht" and index 2 for "Tasks")

    setState(() {
      _selectedIndex = index;
      print(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      Text("Map"),
      Text("Overview"),
      Text("Task")
    ]; //dummy Widgets, will be replaced in future
    double verticalPadding = MediaQuery.of(context).size.height * 0.01;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.01;
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal:
                horizontalPadding), //set an padding of 5% of screen size on all sides
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
                      //not yet implemented
                    }),
              ],
            ),
            _children[_selectedIndex],
          ],
        ),
      )),
      bottomNavigationBar: BottomNavigationBar(
        //Bottom navigation bar widget
        items: const <BottomNavigationBarItem>[
          // List, where all buttons/icons are stored
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Tasks',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
