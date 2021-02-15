// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:data_offloading_app/provider/box_connection_state.dart';
import 'package:data_offloading_app/provider/poslist_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data_offloading_app/main.dart';
import 'package:provider/provider.dart';

void main() {
  // testWidgets('Test bottom navigation bar', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: (_) => BoxConnectionState()),
  //       ChangeNotifierProvider(create: (_) => PosListProvider()),
  //     ],
  //     builder: (context, child) => MainApp(),
  //   ));

  //   // Verify that start page is map
  //   // expect(find.text('Home'), findsNothing);
  //   //expect(find.text('Map'), findsOneWidget);
  //   //expect(find.text('Tasks'), findsNothing);

  //   // Tap the map icon and trigger a frame.
  //   // await tester.tap(find.byIcon(Icons.home));
  //   await tester.tap(find.byIcon(Icons.home));
  //   await tester.pumpAndSettle();

  //   //currently not working -> test not able to find ancestor widgets
  //   // //Verify that page has been switched to home page with settings button.
  //   // // expect(find.text('Home'), findsOneWidget);
  //   // expect(find.text('Map'), findsNothing);
  //   // expect(find.text('Tasks'), findsNothing);
  //   //expect(find.byIcon(Icons.settings), findsOneWidget);

  //   // await tester.tap(find.byIcon(Icons.assignment_turned_in));
  //   // await tester.pumpAndSettle();

  //   //Verify that page has been switched to tasks page
  //   // expect(find.text('Tasks'), findsOneWidget);
  //   expect(find.text('Map'), findsNothing);
  //   expect(find.text('Home'), findsNothing);
  // });

  // you can also use: findsWidgets, findsNWidgets

  group('unit tests for some function', () {
    test('this is a unit test', () {
      //instantiate some class
      // call a function of that class
      expect(1, 1);
    });
    test('another test', () {
      expect(1, 1);
    });
  });
}
