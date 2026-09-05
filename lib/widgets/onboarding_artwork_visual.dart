import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum OnboardingVisual { introduction, browse, details, curatorsEye }

class OnboardingArtworkVisual extends StatelessWidget {
  static const _imageUrl =
      'https://openaccess-cdn.clevelandart.org/1984.59/1984.59_web.jpg';

  final OnboardingVisual type;

  const OnboardingArtworkVisual({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.48,
      child: ClipRect(
        child: ColoredBox(
          color: const Color(0xFFE9E3DA),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRect(
                  child: Transform.scale(
                    scale: type == OnboardingVisual.curatorsEye ? 2.35 : 1,
                    alignment: const Alignment(0.35, -0.2),
                    child: Image.network(
                      _imageUrl,
                      fit: BoxFit.cover,
                      semanticLabel: 'Rocky wooded landscape artwork',
                      errorBuilder: (_, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.landscape_outlined,
                          size: 54,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (type == OnboardingVisual.introduction)
                const _MuseumLabel(label: 'A CURATED DIGITAL MUSEUM'),
              if (type == OnboardingVisual.browse) const _BrowseOverlay(),
              if (type == OnboardingVisual.details) const _DetailsOverlay(),
              if (type == OnboardingVisual.curatorsEye) const _FocusOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MuseumLabel extends StatelessWidget {
  final String label;

  const _MuseumLabel({required this.label});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomLeft,
    child: Container(
      margin: const EdgeInsets.all(28),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      color: AppTheme.background,
      child: Text(
        label,
        style: const TextStyle(fontSize: 8, letterSpacing: 1.4),
      ),
    ),
  );
}

class _BrowseOverlay extends StatelessWidget {
  const _BrowseOverlay();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: Container(
      margin: const EdgeInsets.fromLTRB(30, 28, 30, 0),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.94),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16)],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 16),
          SizedBox(width: 9),
          Text('Search title or artist', style: TextStyle(fontSize: 11)),
        ],
      ),
    ),
  );
}

class _DetailsOverlay extends StatelessWidget {
  const _DetailsOverlay();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.all(28),
      padding: const EdgeInsets.all(13),
      color: AppTheme.background.withValues(alpha: 0.95),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROCKY, WOODED LANDSCAPE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9, letterSpacing: 1.2),
          ),
          SizedBox(height: 5),
          Text(
            'Thomas Gainsborough · 1783',
            style: TextStyle(color: AppTheme.accent, fontSize: 9),
          ),
        ],
      ),
    ),
  );
}

class _FocusOverlay extends StatelessWidget {
  const _FocusOverlay();

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Center(
        child: Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
      const _MuseumLabel(label: 'CAN YOU READ THE FRAGMENT?'),
    ],
  );
}
