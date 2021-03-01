import 'dart:io';

import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/downloadall_state.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:data_offloading_app/Screens/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  var path = Directory.current.path;
  Hive.init(path + '/hive_testing_path');
  await Hive.openBox('storage');

  testWidgets(' checks if all widgets have loaded on this page ',
      (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BoxConnectionState()),
        ChangeNotifierProvider(create: (_) => DownloadAllState()),
      ],
      builder: (context, child) => MediaQuery(
        data: new MediaQueryData(),
        child: MaterialApp(
          home: SettingsPage(),
        ),
      ),
    ));
    final dataLimitButton = find.byKey(ValueKey('Set Data Limit'));
    expect(find.byIcon(Icons.equalizer_rounded), findsOneWidget);
    await tester.tap(dataLimitButton);
    await tester.pump(); //rebuilds the widget
    expect(find.byType(Text), findsWidgets);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
    expect(find.byType(FlatButton), findsWidgets);
  });
}
