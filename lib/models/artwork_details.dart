class ArtworkDetails {
  final int id;
  final String title;
  final String artist;
  final String? imageUrl;
  final String date;
  final String medium;
  // The museum may return HTML here. Format it when building the details UI.
  final String? description;

  const ArtworkDetails({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.date,
    required this.medium,
    required this.description,
  });

  factory ArtworkDetails.fromJson(Map<String, dynamic> json) {
    return ArtworkDetails(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      artist: _artistFrom(json['creators']),
      imageUrl: _imageUrlFrom(json['images']),
      date: json['creation_date'] as String? ?? 'Date unavailable',
      medium: json['technique'] as String? ?? 'Medium unavailable',
      description: json['description'] as String?,
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
