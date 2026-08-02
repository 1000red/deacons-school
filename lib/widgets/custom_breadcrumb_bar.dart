import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BreadcrumbBar extends StatelessWidget {
  final String text;
  const BreadcrumbBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.primaryDark.withValues(alpha: 0.04),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
