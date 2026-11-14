import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BreadcrumbBar extends StatelessWidget {
  final String text;
  const BreadcrumbBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screen,
        vertical: 10,
      ),
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
