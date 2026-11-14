import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// الحالة الموحدة للتحميل/الخطأ/الفراغ في كل الشاشات.
///
/// قبل الـ refactor كل شاشة كانت بترسم حالاتها بطريقتها (نص في منتصف
/// الشاشة بدون ستايل، أو مؤشر تحميل فقط)، فالفرق كان باين بين الشاشات.
/// دلوقتي التحميل بيعرض مؤشر، والخطأ والفراغ بيعرضوا أيونة + رسالة
/// بنفس المسافات ونفس أسلوب النص.
class AppStateView extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? color;
  final bool _isLoading;

  const AppStateView._({
    required this.icon,
    required this.message,
    this.color,
    required bool isLoading,
  }) : _isLoading = isLoading;

  /// شاشة تحميل — مؤشر دائري بنفس لون الهوية.
  const AppStateView.loading()
      : this._(
          icon: Icons.hourglass_top_rounded,
          message: '',
          isLoading: true,
        );

  /// حالة "مفيش محتوى".
  const AppStateView.empty(String message)
      : this._(
          icon: Icons.inbox_outlined,
          message: message,
          isLoading: false,
        );

  /// حالة خطأ — الأيقونة والنص بلون التنبيه.
  const AppStateView.error(String message)
      : this._(
          icon: Icons.error_outline_rounded,
          message: message,
          color: AppColors.danger,
          isLoading: false,
        );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final tint = color ?? AppColors.textMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.block),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: tint),
            const SizedBox(height: AppSpacing.gap),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
