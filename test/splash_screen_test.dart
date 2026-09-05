import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turki_mohammed_project2/screens/splash_screen.dart';
import 'package:turki_mohammed_project2/screens/welcome_screen.dart';
import 'package:turki_mohammed_project2/theme/app_theme.dart';

void main() {
  testWidgets('shows ATHAR identity then opens the welcome screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const SplashScreen(duration: Duration(milliseconds: 10)),
      ),
    );

    expect(find.bySemanticsLabel('ATHAR'), findsOneWidget);
    expect(find.text('ART LEAVES A TRACE'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.textContaining('Next'), findsOneWidget);
  });
}
