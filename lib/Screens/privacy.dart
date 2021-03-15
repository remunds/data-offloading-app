import 'package:flutter/material.dart';

class Privacy extends StatelessWidget {
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
                    '   Datenschutz',
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
              Card(
                  child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        ' Datenschutzinformationen ',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.0),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Für technische Informationen zur Applikation, besuchen sie das GitHub Repository oder wenden Sie sich per E-Mail an das Entwicklerteam.',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
