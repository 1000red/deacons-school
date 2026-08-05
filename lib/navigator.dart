import 'package:deacons_school_mobile/models/models.dart';
import 'package:flutter/material.dart';

import 'screens/levels_screen.dart';
import 'screens/years_screen.dart';
import 'screens/terms_screen.dart';

class AppNavigation {
  static void navigateToLevelScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LevelsScreen()),
    );
  }

  static void navigateToYearsScreen(BuildContext context, Level level) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => YearsScreen(level: level)));
  }

  static void navigateToTermsScreen(
      BuildContext context, Level level, final year) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TermsScreen(level: level, year: year)));
  }
}
