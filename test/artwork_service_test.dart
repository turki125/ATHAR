import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:turki_mohammed_project2/services/artwork_service.dart';

void main() {
  ArtworkService serviceWith(
    Future<http.Response> Function(http.Request) handler,
  ) {
    final service = ArtworkService(client: MockClient(handler));
    addTearDown(service.close);
    return service;
  }

  test(
    'list fetches the curated candidate set and preserves missing values',
    () async {
      final service = serviceWith((request) async {
        expect(request.url.host, 'openaccess-api.clevelandart.org');
        expect(request.url.path, '/api/artworks/');
        expect(request.url.queryParameters['skip'], '0');
        expect(request.url.queryParameters['limit'], '100');
        expect(request.url.queryParameters['q'], 'landscape');
        expect(request.url.queryParameters['has_image'], '1');
        return http.Response(
          jsonEncode({
            'data': [
              {'id': 171296},
            ],
          }),
          200,
        );
      });
      final artworks = await service.fetchArtworks();
      expect(artworks.single.id, 171296);
      expect(artworks.single.title, 'Untitled');
      expect(artworks.single.artist, 'Unknown artist');
      expect(artworks.single.imageUrl, isNull);
    },
  );

  test('empty list is a valid result', () async {
    final service = serviceWith((_) async => http.Response('{"data":[]}', 200));
    expect(await service.fetchArtworks(), isEmpty);
  });

  test('list excludes adult and religious artwork metadata', () async {
    final service = serviceWith(
      (_) async => http.Response(
        jsonEncode({
          'data': [
            {'id': 171296, 'title': 'Quiet Landscape'},
            {'id': 152006, 'title': 'Study of a Nude Figure'},
            {'id': 151298, 'title': 'Saint in a Cathedral'},
          ],
        }),
        200,
      ),
    );
    final artworks = await service.fetchArtworks();
    expect(artworks.map((artwork) => artwork.id), [171296]);
  });

  test('details blocks restricted artwork metadata', () async {
    final service = serviceWith(
      (_) async => http.Response(
        '{"data":{"id":152006,"title":"Religious altar painting"}}',
        200,
      ),
    );
    await expectLater(
      service.fetchArtworkDetails(152006),
      throwsA(isA<ArtworkApiException>()),
    );
  });

  test('details requests selected ID and parses its own response', () async {
    final service = serviceWith((request) async {
      expect(request.url.path, '/api/artworks/171296');
      return http.Response(
        jsonEncode({
          'data': {
            'id': 171296,
            'title': 'A painting',
            'creation_date': '1900',
            'technique': 'Oil',
            'description': null,
          },
        }),
        200,
      );
    });
    final artwork = await service.fetchArtworkDetails(171296);
    expect(artwork.id, 171296);
    expect(artwork.date, '1900');
    expect(artwork.medium, 'Oil');
    expect(artwork.description, isNull);
  });

  for (final status in [404, 429, 500]) {
    test('HTTP $status becomes a readable API error', () async {
      final service = serviceWith(
        (_) async => http.Response('failure', status),
      );
      await expectLater(
        service.fetchArtworks(),
        throwsA(
          isA<ArtworkApiException>().having(
            (e) => e.statusCode,
            'status',
            status,
          ),
        ),
      );
    });
  }

  for (final body in [
    'not json',
    '[]',
    '{"data":null}',
    '{"data":[{"id":"bad"}]}',
  ]) {
    test('invalid list response is handled: $body', () async {
      final service = serviceWith((_) async => http.Response(body, 200));
      await expectLater(
        service.fetchArtworks(),
        throwsA(isA<ArtworkApiException>()),
      );
    });
  }

  test('connection failure is handled', () async {
    final service = serviceWith(
      (_) async => throw http.ClientException('offline'),
    );
    await expectLater(
      service.fetchArtworks(),
      throwsA(isA<ArtworkApiException>()),
    );
  });

  test('slow request times out', () async {
    final response = Completer<http.Response>();
    final service = ArtworkService(
      client: MockClient((_) => response.future),
      timeout: const Duration(milliseconds: 1),
    );
    addTearDown(() {
      response.complete(http.Response('{"data":[]}', 200));
      service.close();
    });
    await expectLater(
      service.fetchArtworks(),
      throwsA(
        isA<ArtworkApiException>().having(
          (e) => e.message,
          'message',
          contains('too long'),
        ),
      ),
    );
  });
}
