import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MuseumLoader extends StatefulWidget {
  final bool compact;

  const MuseumLoader({super.key, this.compact = false});

  @override
  State<MuseumLoader> createState() => _MuseumLoaderState();
}

class _MuseumLoaderState extends State<MuseumLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Curating the gallery',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.compact)
            const SizedBox(
              width: 54,
              child: LinearProgressIndicator(
                minHeight: 1.5,
                color: AppTheme.accent,
                backgroundColor: Color(0xFFD8CFC4),
              ),
            )
          else
            SizedBox.square(
              dimension: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD8CFC4),
                        width: 1,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOutCubic,
                    ),
                    child: const SizedBox.square(
                      dimension: 58,
                      child: CircularProgressIndicator(
                        value: 0.24,
                        strokeWidth: 2.5,
                        strokeCap: StrokeCap.round,
                        color: AppTheme.accent,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          if (!widget.compact) ...[
            const SizedBox(height: 18),
            const Text(
              'CURATING THE GALLERY',
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: 10,
                letterSpacing: 2.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
