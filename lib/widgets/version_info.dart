import 'dart:io';

import 'package:flutter/material.dart';

class VersionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'App Version: 1.0.0 ' + (Platform.isIOS ? ' iOS' : ' Android'),
          style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
