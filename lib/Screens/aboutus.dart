import 'package:data_offloading_app/widgets/about_app.dart';
import 'package:data_offloading_app/widgets/about_nature40.dart';
import 'package:data_offloading_app/widgets/version_info.dart';
import 'package:flutter/material.dart';

/// This page displays the "about us" page with information about the project
class AboutUsPage extends StatelessWidget {
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
              //This describes the appbar on the top of the screen
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
                    '   Über Uns',
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

              //The following list lists the content of the "about us" page
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    AboutNature40(),
                    AboutApp(),
                    VersionInfo()
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
