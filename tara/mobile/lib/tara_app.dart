import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/menu_input_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/profile_summary_screen.dart';
import 'screens/results_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/brand_theme.dart';

class TaraApp extends ConsumerWidget {
  const TaraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tara',
      theme: BrandTheme.light(),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        ProfileSummaryScreen.routeName: (_) => const ProfileSummaryScreen(),
        MenuInputScreen.routeName: (_) => const MenuInputScreen(),
        ResultsScreen.routeName: (_) => const ResultsScreen(),
      },
    );
  }
}
