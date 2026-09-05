import 'package:flutter/material.dart';

import '../models/artwork_summary.dart';
import '../services/artwork_service.dart';
import '../theme/app_theme.dart';
import '../widgets/artwork_card.dart';
import '../widgets/museum_loader.dart';
import 'artwork_details_screen.dart';
import 'curators_eye_screen.dart';

class GalleryScreen extends StatefulWidget {
  // Tests can supply a service. Its owner remains responsible for closing it.
  final ArtworkService? service;

  const GalleryScreen({super.key, this.service});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final ArtworkService _service;
  late Future<List<ArtworkSummary>> _artworks;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ArtworkService();
    _artworks = _service.fetchArtworks();
  }

  // Keep the future outside build so rebuilding does not repeat the request.
  void _reload() {
    setState(() {
      _artworks = _service.fetchArtworks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.service == null) _service.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ATHAR',
          style: TextStyle(letterSpacing: 5, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: "Curator's Eye",
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CuratorsEyeScreen(service: _service),
              ),
            ),
            icon: const Icon(Icons.center_focus_strong_outlined),
          ),
          IconButton(
            tooltip: 'Refresh gallery',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<ArtworkSummary>>(
          future: _artworks,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: MuseumLoader());
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              return _GalleryMessage(
                icon: Icons.cloud_off_outlined,
                title: 'The gallery is taking a pause',
                message: error is ArtworkApiException
                    ? error.message
                    : 'Something went wrong. Please try again.',
                buttonLabel: 'Try again',
                onPressed: _reload,
              );
            }
            final artworks = snapshot.data ?? [];
            if (artworks.isEmpty) {
              return _GalleryMessage(
                icon: Icons.collections_outlined,
                title: 'No artworks here yet',
                message: 'Try refreshing the collection in a moment.',
                buttonLabel: 'Refresh',
                onPressed: _reload,
              );
            }
            final normalizedQuery = _query.trim().toLowerCase();
            final visibleArtworks = normalizedQuery.isEmpty
                ? artworks
                : artworks.where((artwork) {
                    return artwork.title.toLowerCase().contains(
                          normalizedQuery,
                        ) ||
                        artwork.artist.toLowerCase().contains(normalizedQuery);
                  }).toList();
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  itemCount: visibleArtworks.length + 3,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 28),
                  itemBuilder: (context, index) {
                    if (index == 0) return const _GalleryHeading();
                    if (index == 1) {
                      return _CollectionSearch(
                        controller: _searchController,
                        count: visibleArtworks.length,
                        onChanged: (value) => setState(() => _query = value),
                        onClear: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      );
                    }
                    if (index == 2 && visibleArtworks.isEmpty) {
                      return _NoSearchResults(
                        onClear: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      );
                    }
                    if (index == visibleArtworks.length + 2) {
                      return Text(
                        '${artworks.length} works · selected and reviewed for ATHAR',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF756B67),
                          fontSize: 11,
                          letterSpacing: 0.7,
                        ),
                      );
                    }
                    final artwork = visibleArtworks[index - 2];
                    return ArtworkCard(
                      artwork: artwork,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ArtworkDetailsScreen(
                            artworkId: artwork.id,
                            service: _service,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CollectionSearch extends StatelessWidget {
  final TextEditingController controller;
  final int count;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _CollectionSearch({
    required this.controller,
    required this.count,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search title or artist',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 19),
                ),
          filled: true,
          fillColor: const Color(0xFFEDE7DE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        '$count ${count == 1 ? 'WORK' : 'WORKS'} ON VIEW',
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    ],
  );
}

class _NoSearchResults extends StatelessWidget {
  final VoidCallback onClear;

  const _NoSearchResults({required this.onClear});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: [
        const Icon(Icons.manage_search, size: 38, color: AppTheme.accent),
        const SizedBox(height: 14),
        Text(
          'No match in this collection',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text('Try another title or artist.'),
        const SizedBox(height: 18),
        TextButton(onPressed: onClear, child: const Text('Clear search')),
      ],
    ),
  );
}

class _GalleryHeading extends StatelessWidget {
  const _GalleryHeading();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'THE OPEN COLLECTION',
        style: TextStyle(
          color: AppTheme.accent,
          letterSpacing: 2,
          fontSize: 11,
        ),
      ),
      SizedBox(height: 14),
      Text(
        'A moment\nwith art.',
        style: TextStyle(
          fontFamily: 'Georgia',
          fontFamilyFallback: ['serif'],
          fontSize: 46,
          height: 1.05,
          color: AppTheme.ink,
        ),
      ),
      SizedBox(height: 16),
      Text(
        'Discover highlights from the Cleveland Museum of Art.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      SizedBox(height: 24),
      Divider(height: 1),
    ],
  );
}

class _GalleryMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _GalleryMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: AppTheme.accent),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    ),
  );
}
