import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentra/main.dart';
import 'package:momentra/providers/theme_provider.dart';

void main() {
  testWidgets('Momentra smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MomentraApp(themeProvider: ThemeProvider()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

