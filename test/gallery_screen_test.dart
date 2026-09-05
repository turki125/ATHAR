import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:turki_mohammed_project2/screens/gallery_screen.dart';
import 'package:turki_mohammed_project2/services/artwork_service.dart';
import 'package:turki_mohammed_project2/theme/app_theme.dart';

void main() {
  Future<void> openGallery(WidgetTester tester, MockClient client) async {
    final service = ArtworkService(client: client);
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: GalleryScreen(service: service),
      ),
    );
  }

  testWidgets('loading becomes content without refetching on rebuild', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    var requests = 0;
    await openGallery(
      tester,
      MockClient((_) {
        requests++;
        return pending.future;
      }),
    );
    expect(find.text('CURATING THE GALLERY'), findsOneWidget);
    pending.complete(
      http.Response(
        jsonEncode({
          'data': [
            {
              'id': 171296,
              'title': 'Test artwork',
              'creators': [
                {'description': 'Test artist'},
              ],
            },
          ],
        }),
        200,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test artwork'), findsOneWidget);
    expect(find.text('Image unavailable'), findsOneWidget);
    tester.element(find.byType(GalleryScreen)).markNeedsBuild();
    await tester.pump();
    expect(requests, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retry recovers after server failure', (tester) async {
    var requests = 0;
    await openGallery(
      tester,
      MockClient((_) async {
        requests++;
        return requests == 1
            ? http.Response('Unavailable', 503)
            : http.Response('{"data":[]}', 200);
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('The gallery is taking a pause'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No artworks here yet'), findsOneWidget);
    expect(requests, 2);
  });

  testWidgets('long artwork text fits a small phone at larger text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openGallery(
      tester,
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'data': [
              {
                'id': 171296,
                'title': 'An unusually long artwork title that wraps across several lines',
                'creators': [
                  {
                    'description':
                        'An artist with a long name and a detailed biography',
                  },
                ],
              },
            ],
          }),
          200,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
