import 'package:flutter/material.dart';

import 'screens/artwork_details_screen.dart';
import 'screens/curators_eye_screen.dart';
import 'screens/splash_screen.dart';
import 'services/artwork_service.dart';
import 'theme/app_theme.dart';

void main() {
  const screen = String.fromEnvironment('SCREEN', defaultValue: 'splash');
  final service = ArtworkService();
  final home = switch (screen) {
    'details' => ArtworkDetailsScreen(artworkId: 152006, service: service),
    'curators-eye' => CuratorsEyeScreen(service: service),
    _ => const SplashScreen(duration: Duration(minutes: 1)),
  };
  runApp(
    MaterialApp(
      title: 'ATHAR Screenshots',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: home,
    ),
  );
}
