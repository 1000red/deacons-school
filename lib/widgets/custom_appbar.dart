import 'package:flutter/material.dart';

/// شارة صغيرة (Badge/Chip) لعرض المستوى أو التصنيف.
class AppBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const AppBadge(
      {super.key,
      required this.label,
      required this.background,
      required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w600, color: foreground)),
    );
  }
}

/// شريط علوي موحّد للشاشات الداخلية.
PreferredSizeWidget appBarFor(String title, {List<Widget>? actions}) {
  return AppBar(title: Text(title), actions: actions);
}
