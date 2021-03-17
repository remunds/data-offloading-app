import 'package:data_offloading_app/widgets/how_to_connect.dart';
import 'package:data_offloading_app/widgets/how_to_use.dart';
import 'package:data_offloading_app/widgets/important_info.dart';

import 'package:flutter/material.dart';

/// This page displays the manual page with all the information on how to use the map
class ManualPage extends StatelessWidget {
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
                  horizontalPadding), //set a padding of 1% of screen size on all sides
          child: Column(
            children: [
              // This row displays the appbar on the top of the screen
              Row(
                //Make a Row with a back button on the left side
                mainAxisAlignment:
                    MainAxisAlignment.start, //align the button to the left side
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
                  Text(
                    '   Anleitung',
                    style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black45),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Divider(
                thickness: 2,
              ),
              Expanded(
                // The manual instructions are displayed in the following list
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    ImportantInfo(),
                    SizedBox(
                      height: 5,
                    ),
                    HowToConnect(),
                    SizedBox(
                      height: 5,
                    ),
                    HowToUse()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
