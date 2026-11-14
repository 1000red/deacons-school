import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// زر أساسي موحّد (عرض كامل + ارتفاع مريح للمس).
///
/// الشكل والألوان والخط جايين من `ThemeData.elevatedButtonTheme`
/// في [AppTheme]، فال.widget بس بيحدد النص والضغط.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
