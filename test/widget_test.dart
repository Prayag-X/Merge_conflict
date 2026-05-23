import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_app/main.dart';

void main() {
  testWidgets('Calculator basic addition test', (WidgetTester tester) async {
    // Build our calculator app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the calculator starts at 0.
    expect(find.text('0'), findsOneWidget);

    // Tap '7'
    await tester.tap(find.text('7'));
    await tester.pump();

    // Tap '+'
    await tester.tap(find.text('+'));
    await tester.pump();

    // Tap '5'
    await tester.tap(find.text('5'));
    await tester.pump();

    // Tap '='
    await tester.tap(find.text('='));
    await tester.pump(const Duration(milliseconds: 300)); // allow fade transition to complete

    // Verify that the result display output has evaluated to '12'.
    expect(find.text('12'), findsOneWidget);
  });
}
