import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// نص تسمية موحّد (عناوين حقول نموذج الدخول).
class CustomText extends StatelessWidget {
  final String text;
  const CustomText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.subtitle);
  }
}
