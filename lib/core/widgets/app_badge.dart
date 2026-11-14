import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// شارة صغيرة (Badge/Chip) لعرض المستوى أو التصنيف.
class AppBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const AppBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppTypography.label.copyWith(color: foreground)),
    );
  }
}
