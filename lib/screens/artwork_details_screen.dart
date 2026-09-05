import 'package:flutter/material.dart';

import '../models/artwork_details.dart';
import '../services/artwork_service.dart';
import '../theme/app_theme.dart';
import '../widgets/museum_loader.dart';

class ArtworkDetailsScreen extends StatefulWidget {
  final int artworkId;
  final ArtworkService service;

  const ArtworkDetailsScreen({
    super.key,
    required this.artworkId,
    required this.service,
  });

  @override
  State<ArtworkDetailsScreen> createState() => _ArtworkDetailsScreenState();
}

class _ArtworkDetailsScreenState extends State<ArtworkDetailsScreen> {
  late Future<ArtworkDetails> _details;

  @override
  void initState() {
    super.initState();
    _details = widget.service.fetchArtworkDetails(widget.artworkId);
  }

  void _retry() {
    setState(() {
      _details = widget.service.fetchArtworkDetails(widget.artworkId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARTWORK', style: TextStyle(letterSpacing: 3)),
      ),
      body: FutureBuilder<ArtworkDetails>(
        future: _details,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: MuseumLoader());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            return _DetailsError(
              message: error is ArtworkApiException
                  ? error.message
                  : 'Something went wrong. Please try again.',
              onRetry: _retry,
            );
          }
          return _DetailsContent(details: snapshot.requireData);
        },
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final ArtworkDetails details;

  const _DetailsContent({required this.details});

  @override
  Widget build(BuildContext context) {
    final imageUrl = details.imageUrl;
    final description = _plainText(details.description);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          children: [
            Hero(
              tag: 'artwork-${details.id}',
              child: AspectRatio(
                aspectRatio: 1,
                child: ColoredBox(
                  color: const Color(0xFFEAE4DB),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: imageUrl == null
                        ? const Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            semanticLabel: details.title,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'FROM THE COLLECTION',
              style: TextStyle(
                color: AppTheme.accent,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              details.title,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['serif'],
                fontSize: 38,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              details.artist,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 28),
            const Divider(),
            _MuseumFact(label: 'DATE', value: details.date),
            _MuseumFact(label: 'MEDIUM', value: details.medium),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'ABOUT THIS WORK',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: AppTheme.accent, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 16, height: 1.65),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _plainText(String? html) {
    if (html == null) return '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}

class _MuseumFact extends StatelessWidget {
  final String label;
  final String value;

  const _MuseumFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(height: 1.45))),
      ],
    ),
  );
}

class _DetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 42,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}
