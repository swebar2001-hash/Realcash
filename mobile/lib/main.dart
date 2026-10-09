import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RealCashApp(),
    ),
  );
}

class RealCashApp extends StatelessWidget {
  const RealCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RealCash — Gaming & Sports Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
