import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:profaritashion/map_page.dart';
import 'package:profaritashion/places_list_page.dart';

void main() {
  group('Map Page Tests', () {
    testWidgets('Map page should render with all buttons', (WidgetTester tester) async {
      // This is a basic test to ensure the widget renders
      await tester.pumpWidget(
        MaterialApp(
          home: MapPage(userId: 'test-user'),
        ),
      );
      
      // Verify the page loads
      expect(find.text('Карта колледжей и мест'), findsOneWidget);
      expect(find.text('Удмуртская Республика'), findsOneWidget);
    });
  });

  group('Places List Page Tests', () {
    testWidgets('Places list page should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlacesListPage(userId: 'test-user'),
        ),
      );
      
      // Verify the page loads
      expect(find.text('Интересные места'), findsOneWidget);
      expect(find.text('Удмуртская Республика'), findsOneWidget);
    });
  });
}