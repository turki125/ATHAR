import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 3400),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    _timer = Timer(widget.duration, _openWelcome);
  }

  void _openWelcome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: Text(
                  'EST. 2026',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AnimatedWordmark(progress: _controller.value),
                      const SizedBox(height: 25),
                      _LineReveal(progress: _controller.value),
                      const SizedBox(height: 23),
                      Opacity(
                        opacity: _interval(
                          _controller.value,
                          0.68,
                          1,
                          Curves.easeOut,
                        ),
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            8 *
                                (1 -
                                    _interval(
                                      _controller.value,
                                      0.68,
                                      1,
                                      Curves.easeOutCubic,
                                    )),
                          ),
                          child: Text(
                            'ART LEAVES A TRACE',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 11,
                              letterSpacing: 3.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.75, 1, curve: Curves.easeOut),
                ),
                child: const Text(
                  'A CURATED DIGITAL MUSEUM',
                  style: TextStyle(fontSize: 10, letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedWordmark extends StatelessWidget {
  static const _letters = ['A', 'T', 'H', 'A', 'R'];
  final double progress;

  const _AnimatedWordmark({required this.progress});

  @override
  Widget build(BuildContext context) {
    final lightSweep = _interval(progress, 0.32, 0.96, Curves.easeInOutCubic);
    return Semantics(
      label: 'ATHAR',
      child: ExcludeSemantics(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-2.5 + (5 * lightSweep), 0),
            end: Alignment(-1.5 + (5 * lightSweep), 0),
            colors: const [
              AppTheme.ink,
              AppTheme.ink,
              Color(0xFFFFE9C9),
              Color(0xFFD79B67),
              AppTheme.ink,
              AppTheme.ink,
            ],
            stops: const [0, 0.34, 0.46, 0.54, 0.66, 1],
          ).createShader(bounds),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_letters.length, (index) {
              final start = index * 0.055;
              final value = _interval(
                progress,
                start,
                start + 0.24,
                Curves.easeOutCubic,
              );
              return Transform.translate(
                offset: Offset(0, 34 * (1 - value)),
                child: Transform.scale(
                  scale: 0.92 + (0.08 * value),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == _letters.length - 1 ? 0 : 12,
                      ),
                      child: Text(
                        _letters[index],
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontFamily: 'Georgia',
                          fontFamilyFallback: ['serif'],
                          fontSize: 54,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _LineReveal extends StatelessWidget {
  final double progress;

  const _LineReveal({required this.progress});

  @override
  Widget build(BuildContext context) {
    final value = _interval(progress, 0.5, 0.8, Curves.easeInOutCubic);
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(width: 112, height: 2, color: AppTheme.accent),
      ),
    );
  }
}

double _interval(double progress, double begin, double end, Curve curve) {
  final normalized = ((progress - begin) / (end - begin)).clamp(0.0, 1.0);
  return curve.transform(normalized);
}
