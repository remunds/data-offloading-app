import 'package:flutter/material.dart';

class Software extends StatelessWidget {
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
                    '   Software',
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
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.0),
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Folgende Software und Abhängigkeiten wurden in diesem Projekt verwendet:',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Card(
                          child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  ' Flutter und Abhängigkeiten',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.0),
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Version: 1.22.6 Stable',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        showLicensePage(
                                          context: context,
                                          applicationName: 'Data Offloading',
                                          applicationVersion: '1.0.0',
                                        );
                                      },
                                      child: Text(
                                        'Lizenzen',
                                        style:
                                            TextStyle(color: Colors.lightGreen),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
