class ArtworkSummary {
  final int id;
  final String title;
  final String artist;
  final String? imageUrl;

  const ArtworkSummary({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
  });

  factory ArtworkSummary.fromJson(Map<String, dynamic> json) {
    return ArtworkSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      artist: _artistFrom(json['creators']),
      imageUrl: _imageUrlFrom(json['images']),
    );
  }

  static String _artistFrom(Object? value) {
    if (value is List && value.isNotEmpty && value.first is Map) {
      final description = (value.first as Map)['description'];
      if (description is String && description.trim().isNotEmpty) {
        return description;
      }
    }
    return 'Unknown artist';
  }

  static String? _imageUrlFrom(Object? value) {
    if (value is Map) {
      final web = value['web'];
      if (web is Map && web['url'] is String) return web['url'] as String;
    }
    return null;
  }
}
