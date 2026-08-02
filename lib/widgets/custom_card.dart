import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

/// بطاقة تُستخدم لعرض مستوى / سنة / ترم / مادة في قوائم التنقل.
/// لو [filled] = true: كارت بتدرج لوني بارز (يُستخدم للعنصر الرئيسي).
/// لو [filled] = false: كارت أبيض بحدود خفيفة (يُستخدم للعناصر الفرعية).
class NavCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const NavCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = filled ? Colors.white : Colors.grey.shade900;
    final Color subtitleColor =
        filled ? Colors.white.withValues(alpha: 0.85) : Colors.grey.shade600;
    final Color iconColor = filled ? Colors.white : color;
    final Color iconBgColor = filled
        ? Colors.white.withValues(alpha: 0.22)
        : color.withValues(alpha: 0.12);
    final Color trailingColor =
        filled ? Colors.white.withValues(alpha: 0.85) : Colors.grey.shade400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: filled
                ? LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [color, color.withValues(alpha: 0.75)],
                  )
                : null,
            color: filled ? null : Colors.white,
            border: filled
                ? null
                : Border.all(color: color.withValues(alpha: 0.22)),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.32),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_left, color: trailingColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة كبيرة بتدرج لوني تُستخدم لعرض مستوى / سنة / ترم / مادة في شبكات التنقل.
class CustomCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CustomCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              color,
              color.withValues(alpha: 0.75),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
