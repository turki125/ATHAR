import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turki_mohammed_project2/screens/gallery_screen.dart';
import 'package:turki_mohammed_project2/screens/welcome_screen.dart';
import 'package:turki_mohammed_project2/theme/app_theme.dart';

void main() {
  testWidgets('moves through the guide and enters the gallery', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const WelcomeScreen(autoAdvanceDuration: Duration(days: 1)),
      ),
    );

    expect(find.text('Art leaves\na trace.'), findsOneWidget);
    expect(find.textContaining('quiet digital museum'), findsOneWidget);

    for (var page = 0; page < 3; page++) {
      await tester.tap(find.textContaining('Next'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.textContaining('Enter the gallery'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.byType(GalleryScreen), findsOneWidget);
  });

  testWidgets('fits a small phone with larger text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const WelcomeScreen(autoAdvanceDuration: Duration(days: 1)),
      ),
    );

    expect(find.textContaining('Next'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('automatically advances after the configured delay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const WelcomeScreen(
          autoAdvanceDuration: Duration(milliseconds: 10),
        ),
      ),
    );

    expect(find.text('Art leaves\na trace.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.text('Find a work\nthat stays with you.'), findsOneWidget);
  });
}
