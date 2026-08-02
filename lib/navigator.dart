import 'package:flutter/material.dart';

import 'screens/levels_screen.dart';

class AppNavigation {
  static void navigateToLevelScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LevelsScreen()),
    );
  }

  // static void navigateToYearsScreen(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LevelsScreen()),
  //   );
  // }
}
