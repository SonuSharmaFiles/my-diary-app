// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_diary/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyDiaryApp());

    // Verify that the app title is displayed
    expect(find.text('My Diary'), findsOneWidget);
    
    // Verify that the new entry section is present
    expect(find.text('New Entry'), findsOneWidget);
    
    // Verify that the write about your day hint is present
    expect(find.text('Write about your day...'), findsOneWidget);
  });
}
