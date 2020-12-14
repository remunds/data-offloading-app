// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data_offloading_app/main.dart';

void main() {
  testWidgets('Test bottom navigation bar', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that all components exist
    expect(find.text('Übersicht'), findsOneWidget);
    expect(find.text('Karte'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);

    expect(find.byIcon(Icons.settings), findsOneWidget);

    //verify that app starts at homepage
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Map'), findsNothing);

    // Tap the map icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.map));
    await tester.pump();

    //Verify that page has been switched to map page.
    expect(find.text('Home'), findsNothing);
    expect(find.text('Map'), findsOneWidget);
  });

  // you can also use: findsWidgets, findsNWidgets

  group('unit tests for some function', ()
  {
    test('this is a unit test', () {
      //instantiate some class
      // call a function of that class
      expect(1, 1);
    });
    test('another test', (){
      expect(1, 1);
    });
  });
}
