import 'package:flutter_test/flutter_test.dart';

import 'package:simple_app/app.dart';

void main() {
  testWidgets('Calculator app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text('AC'), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('='), findsOneWidget);
  });
}
