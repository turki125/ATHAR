import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/onboarding_artwork_visual.dart';
import 'gallery_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final Duration autoAdvanceDuration;

  const WelcomeScreen({
    super.key,
    this.autoAdvanceDuration = const Duration(seconds: 3),
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const _pages = [
    _OnboardingPage(
      eyebrow: 'WELCOME TO ATHAR',
      title: 'Art leaves\na trace.',
      description: 'ATHAR is a quiet digital museum for discovering remarkable artwork and the stories behind it.',
      visual: OnboardingVisual.introduction,
    ),
    _OnboardingPage(
      eyebrow: '01 · EXPLORE',
      title: 'Find a work\nthat stays with you.',
      description: 'Swipe through the collection or search for an artwork by its title or artist.',
      visual: OnboardingVisual.browse,
    ),
    _OnboardingPage(
      eyebrow: '02 · DISCOVER',
      title: 'Look beyond\nthe frame.',
      description: 'Tap an artwork to reveal its artist, date, medium, and museum story.',
      visual: OnboardingVisual.details,
    ),
    _OnboardingPage(
      eyebrow: "03 · CURATOR'S EYE",
      title: 'Notice what\nothers miss.',
      description: 'Choose the focus icon, study a close-up fragment, and identify the full artwork.',
      visual: OnboardingVisual.curatorsEye,
    ),
  ];

  final PageController _pageController = PageController();
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scheduleAutoAdvance();
  }

  void _scheduleAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    if (_currentPage == _pages.length - 1) return;
    _autoAdvanceTimer = Timer(widget.autoAdvanceDuration, _nextPage);
  }

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _enterGallery();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  void _enterGallery() {
    _autoAdvanceTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, secondaryAnimation) =>
            const GalleryScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  _WelcomeHeader(onSkip: _enterGallery),
                  const SizedBox(height: 20),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification) {
                          _autoAdvanceTimer?.cancel();
                        } else if (notification is ScrollEndNotification) {
                          _scheduleAutoAdvance();
                        }
                        return false;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                          _scheduleAutoAdvance();
                        },
                        itemBuilder: (context, index) =>
                            _OnboardingSlide(page: _pages[index]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _PageIndicator(
                          count: _pages.length,
                          current: _currentPage,
                        ),
                      ),
                      const Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'SWIPE TO EXPLORE',
                            maxLines: 1,
                            style: TextStyle(fontSize: 9, letterSpacing: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLastPage ? _enterGallery : _nextPage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        isLastPage ? 'Enter the gallery  →' : 'Next  →',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final VoidCallback onSkip;

  const _WelcomeHeader({required this.onSkip});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Text(
          'ATHAR',
          maxLines: 1,
          style: TextStyle(letterSpacing: 5, fontSize: 18),
        ),
      ),
      TextButton(
        onPressed: onSkip,
        child: const Text(
          'SKIP',
          style: TextStyle(fontSize: 10, letterSpacing: 2),
        ),
      ),
    ],
  );
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingSlide({required this.page});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingArtworkVisual(type: page.visual),
        const SizedBox(height: 25),
        Text(
          page.eyebrow,
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          page.title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontFamilyFallback: ['serif'],
            fontSize: 39,
            height: 1.04,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          page.description,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ],
    ),
  );
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _PageIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(
      count,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        width: index == current ? 28 : 7,
        height: 3,
        margin: const EdgeInsets.only(right: 6),
        color: index == current ? AppTheme.accent : const Color(0xFFD8CFC5),
      ),
    ),
  );
}

class _OnboardingPage {
  final String eyebrow;
  final String title;
  final String description;
  final OnboardingVisual visual;

  const _OnboardingPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.visual,
  });
}
