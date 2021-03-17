import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

/// A widget to display version info about the app
class VersionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'App Version:  ' +
                    snapshot.data.version +
                    (Platform.isIOS ? ' iOS' : ' Android'),
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          );
        });
  }
}
