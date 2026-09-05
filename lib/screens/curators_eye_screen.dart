import 'dart:math';

import 'package:flutter/material.dart';

import '../models/artwork_summary.dart';
import '../services/artwork_service.dart';
import '../theme/app_theme.dart';
import '../widgets/museum_loader.dart';
import 'artwork_details_screen.dart';

class CuratorsEyeScreen extends StatefulWidget {
  final ArtworkService service;

  const CuratorsEyeScreen({super.key, required this.service});

  @override
  State<CuratorsEyeScreen> createState() => _CuratorsEyeScreenState();
}

class _CuratorsEyeScreenState extends State<CuratorsEyeScreen> {
  final Random _random = Random();
  late Future<_ArtRound> _round;
  ArtworkSummary? _selected;
  int _score = 0;
  int _roundNumber = 1;

  @override
  void initState() {
    super.initState();
    _round = _loadRound();
  }

  Future<_ArtRound> _loadRound() async {
    final artworks = await widget.service.fetchArtworks(limit: 100);
    final usable =
        artworks.where((artwork) => artwork.imageUrl != null).toList()
          ..shuffle(_random);
    if (usable.length < 3) {
      throw const ArtworkApiException('Not enough artworks for this round.');
    }
    final options = usable.take(3).toList()..shuffle(_random);
    return _ArtRound(
      answer: options[_random.nextInt(options.length)],
      options: options,
    );
  }

  void _choose(ArtworkSummary choice, _ArtRound round) {
    if (_selected != null) return;
    setState(() {
      _selected = choice;
      if (choice.id == round.answer.id) _score++;
    });
  }

  void _nextRound() {
    setState(() {
      _selected = null;
      _roundNumber++;
      _round = _loadRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CURATOR'S EYE", style: TextStyle(letterSpacing: 2)),
      ),
      body: FutureBuilder<_ArtRound>(
        future: _round,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: MuseumLoader());
          }
          if (snapshot.hasError) {
            return _RoundError(onRetry: _nextRound);
          }
          return _RoundView(
            round: snapshot.requireData,
            selected: _selected,
            score: _score,
            roundNumber: _roundNumber,
            onChoose: _choose,
            onNext: _nextRound,
            service: widget.service,
          );
        },
      ),
    );
  }
}

class _ArtRound {
  final ArtworkSummary answer;
  final List<ArtworkSummary> options;

  const _ArtRound({required this.answer, required this.options});
}

class _RoundView extends StatelessWidget {
  final _ArtRound round;
  final ArtworkSummary? selected;
  final int score;
  final int roundNumber;
  final void Function(ArtworkSummary, _ArtRound) onChoose;
  final VoidCallback onNext;
  final ArtworkService service;

  const _RoundView({
    required this.round,
    required this.selected,
    required this.score,
    required this.roundNumber,
    required this.onChoose,
    required this.onNext,
    required this.service,
  });

  bool get revealed => selected != null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LOOK CLOSER',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'ROUND $roundNumber  ·  SCORE $score',
                  style: const TextStyle(fontSize: 10, letterSpacing: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              revealed ? 'The full story.' : 'Can you read\nthe fragment?',
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: ['serif'],
                fontSize: 40,
                height: 1.06,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeOutCubic,
              child: AspectRatio(
                key: ValueKey(revealed),
                aspectRatio: 1,
                child: ClipRect(
                  child: ColoredBox(
                    color: const Color(0xFFEAE4DB),
                    child: Padding(
                      padding: EdgeInsets.all(revealed ? 18 : 0),
                      child: Transform.scale(
                        scale: revealed ? 1 : 2.5,
                        alignment: const Alignment(0.45, -0.25),
                        child: Image.network(
                          round.answer.imageUrl!,
                          fit: BoxFit.contain,
                          semanticLabel: revealed
                              ? round.answer.title
                              : 'Artwork fragment',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!revealed) ...[
              const Text(
                'CHOOSE THE ARTWORK',
                style: TextStyle(fontSize: 10, letterSpacing: 1.8),
              ),
              const SizedBox(height: 12),
              ...round.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    onPressed: () => onChoose(option, round),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                    child: Text(option.title),
                  ),
                ),
              ),
            ] else ...[
              _RevealLabel(
                correct: selected!.id == round.answer.id,
                artwork: round.answer,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ArtworkDetailsScreen(
                            artworkId: round.answer.id,
                            service: service,
                          ),
                        ),
                      ),
                      child: const Text('Read its story'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onNext,
                      child: const Text('Next fragment'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RevealLabel extends StatelessWidget {
  final bool correct;
  final ArtworkSummary artwork;

  const _RevealLabel({required this.correct, required this.artwork});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        correct ? 'A CURATORIAL EYE' : 'A NEW DISCOVERY',
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 10,
          letterSpacing: 1.8,
        ),
      ),
      const SizedBox(height: 9),
      Text(
        artwork.title,
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontFamilyFallback: ['serif'],
          fontSize: 27,
        ),
      ),
      const SizedBox(height: 7),
      Text(artwork.artist, style: const TextStyle(height: 1.45)),
    ],
  );
}

class _RoundError extends StatelessWidget {
  final VoidCallback onRetry;

  const _RoundError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.visibility_off_outlined,
            size: 42,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 16),
          const Text('The next fragment is not ready.'),
          const SizedBox(height: 22),
          FilledButton(onPressed: onRetry, child: const Text('Try another')),
        ],
      ),
    ),
  );
}
