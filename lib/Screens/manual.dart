import 'package:data_offloading_app/widgets/how_to_connect.dart';
import 'package:data_offloading_app/widgets/how_to_use.dart';

import 'package:flutter/material.dart';

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
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
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
