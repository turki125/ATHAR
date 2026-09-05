import 'package:flutter/material.dart';

import '../models/artwork_summary.dart';
import '../theme/app_theme.dart';
import 'museum_loader.dart';

class ArtworkCard extends StatelessWidget {
  final ArtworkSummary artwork;
  final VoidCallback? onTap;

  const ArtworkCard({super.key, required this.artwork, this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = artwork.imageUrl;
    return Semantics(
      button: onTap != null,
      label: 'Open ${artwork.title}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.15,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFEAE4DB),
                child: imageUrl == null || imageUrl.isEmpty
                    ? const _ImageUnavailable()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        semanticLabel: artwork.title,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: MuseumLoader(compact: true),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const _ImageUnavailable(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              artwork.title,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['serif'],
                fontSize: 23,
                height: 1.2,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artwork.artist,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _ImageUnavailable extends StatelessWidget {
  const _ImageUnavailable();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 32),
        SizedBox(height: 10),
        Text('Image unavailable'),
      ],
    ),
  );
}
