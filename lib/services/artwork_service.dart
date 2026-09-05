import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/artwork_details.dart';
import '../models/artwork_summary.dart';

class ArtworkApiException implements Exception {
  final String message;
  final int? statusCode;

  const ArtworkApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ArtworkService {
  // Manually reviewed landscape records. Only these IDs can enter ATHAR.
  static const Set<int> _approvedArtworkIds = {
    171296,
    152006,
    151298,
    139454,
    148739,
    79932,
    143234,
    143602,
    83635,
    149417,
    141639,
    142642,
    172785,
    150165,
    148853,
    97604,
    132908,
    111059,
    154086,
    159739,
  };

  static final List<RegExp> _blockedContentPatterns = [
    RegExp(
      r'\b(nude|nudity|naked|erotic|sexual|genitals?|breasts?|brothel|prostitut\w*|orgy)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(behead\w*|decapitat\w*|massacre|torture|execution|dismember\w*|graphic violence|death|suicide|murder|sacrifice)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(religious|sacred|holy|divine|deit(?:y|ies)|gods?|goddess(?:es)?|angel|apostle|saints?|martyr|altar|crucifix\w*|cross|nativity|annunciation|baptism|resurrection|church|cathedral|chapel|monastery|priest|bishop|pope|monk|nun)\b',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(christ|jesus|madonna|virgin mary|bible|biblical|christian\w*|catholic\w*|judaism|jewish|torah|synagogue|islam\w*|muslim\w*|qur.?an|koran|mosque|prophet|muhammad|buddh\w*|hindu\w*|shiva|vishnu|krishna|temple|mytholog\w*)\b',
      caseSensitive: false,
    ),
  ];

  final http.Client _client;
  final Duration timeout;

  // An injected client lets tests simulate failures without using the internet.
  ArtworkService({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  Future<List<ArtworkSummary>> fetchArtworks({int limit = 100}) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError('Limit must be 1–100.');
    }
    final json = await _getJson('/api/artworks/', {
      // Fetch the candidate set before applying ATHAR's reviewed allowlist.
      // API pagination after filtering would otherwise hide approved works.
      'skip': '0',
      'limit': '100',
      'q': 'landscape',
      'cc0': '',
      'has_image': '1',
      'fields': 'id,title,creators,images,description,did_you_know,department,type,technique,culture,tombstone',
    });
    try {
      final data = json['data'] as List<dynamic>;
      return data
          .cast<Map<String, dynamic>>()
          .where(_isSuitableArtwork)
          .map(ArtworkSummary.fromJson)
          .take(limit)
          .toList();
    } on TypeError {
      throw const ArtworkApiException('The artwork list could not be read.');
    }
  }

  Future<ArtworkDetails> fetchArtworkDetails(int id) async {
    if (id < 1) throw ArgumentError.value(id, 'id', 'Must be positive');
    final json = await _getJson('/api/artworks/$id', const {});
    try {
      final data = json['data'] as Map<String, dynamic>;
      if (!_isSuitableArtwork(data)) {
        throw const ArtworkApiException(
          'This artwork is not available in ATHAR.',
        );
      }
      return ArtworkDetails.fromJson(data);
    } on TypeError {
      throw const ArtworkApiException('The artwork details could not be read.');
    }
  }

  static bool _isSuitableArtwork(Map<String, dynamic> artwork) {
    final id = artwork['id'] as int;
    if (!_approvedArtworkIds.contains(id)) return false;
    final searchableText = [
      artwork['title'],
      artwork['description'],
      artwork['did_you_know'],
      artwork['department'],
      artwork['type'],
      artwork['technique'],
      artwork['culture'],
      artwork['tombstone'],
    ].map(_asText).join(' ');
    return !_blockedContentPatterns.any(
      (pattern) => pattern.hasMatch(searchableText),
    );
  }

  static String _asText(Object? value) {
    if (value is String) return value;
    if (value is Iterable) return value.map(_asText).join(' ');
    return '';
  }

  Future<Map<String, dynamic>> _getJson(
    String path,
    Map<String, String> query,
  ) async {
    final uri = Uri.https('openaccess-api.clevelandart.org', path, query);
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw ArtworkApiException(
          response.statusCode == 404
              ? 'This artwork is no longer available.'
              : 'The museum could not load the data. Please try again.',
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object');
      }
      return decoded;
    } on TimeoutException {
      throw const ArtworkApiException(
        'The request took too long. Please try again.',
      );
    } on http.ClientException {
      throw const ArtworkApiException(
        'Could not connect. Check your internet and try again.',
      );
    } on FormatException {
      throw const ArtworkApiException('The museum returned unreadable data.');
    }
  }

  // Call when the owner of this service is disposed. Also closes injected clients.
  void close() => _client.close();
}
