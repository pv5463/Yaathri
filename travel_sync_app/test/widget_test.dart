// This is a basic Flutter widget test for TravelSync app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Yaathri/main.dart';

void main() {
  group('TravelSync App Tests', () {
    testWidgets('App should load without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const TravelSyncApp());

      // Verify that our app loads correctly
      expect(find.text('TravelSync'), findsOneWidget);
      expect(find.text('Travel Data Collection App'), findsOneWidget);
      expect(find.byIcon(Icons.travel_explore), findsOneWidget);
    });

    testWidgets('App should display correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TravelSyncApp(),
        ),
      );

      // Verify that the app builds successfully
      expect(find.text('TravelSync'), findsOneWidget);
      expect(find.text('Travel Data Collection App'), findsOneWidget);
    });

    testWidgets('Basic widget components should render', (WidgetTester tester) async {
      // Test basic Flutter widgets work in our app context
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test App Bar'),
            ),
            body: const Column(
              children: [
                Text('Test Text'),
                Icon(Icons.home),
                SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Test Card'),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Verify all components render correctly
      expect(find.text('Test App Bar'), findsOneWidget);
      expect(find.text('Test Text'), findsOneWidget);
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
