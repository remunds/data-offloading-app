import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.01;
    double horizontalPadding = MediaQuery.of(context).size.width * 0.01;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal:
                  horizontalPadding), //set an padding of 1% of screen size on all sides
          child: Column(
            children: [
              Row(
                //Make a Row with a settings button on the right side
                mainAxisAlignment: MainAxisAlignment
                    .start, //align the button to the right side
                children: [
                  IconButton(
                      //button initialisation
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ),
              Text("Settings")
            ],
          ),
        ),
      ),
    );
  }
}
