// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';

/// بطاقة إحصائية تُستخدم في الشاشة الرئيسية (تطابق StatCard في نسخة الويب).
// class StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String icon;
//   final Color background;
//   final Color foreground;
//   final VoidCallback? onTap;

//   const StatCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.background,
//     required this.foreground,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: background,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: foreground.withValues(alpha: 0.25)),
//         ),
//         child: Row(
//           children: [
//             Text(icon, style: const TextStyle(fontSize: 32)),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: const TextStyle(
//                           fontSize: 12, color: AppColors.textSecondary)),
//                   const SizedBox(height: 2),
//                   Text(value,
//                       style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: foreground)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// رابط سريع (Quick Link) في الشاشة الرئيسية.
// class QuickLinkTile extends StatelessWidget {
//   final String label;
//   final String icon;
//   final VoidCallback onTap;

//   const QuickLinkTile({super.key, required this.label, required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.border),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(icon, style: const TextStyle(fontSize: 26)),
//             const SizedBox(height: 6),
//             Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// حالة فارغة (Empty State) موحّدة لكل الشاشات.
// class EmptyState extends StatelessWidget {
//   final String message;
//   const EmptyState({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 48),
//       child: Center(
//         child: Text(message,
//             style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
//       ),
//     );
//   }
// }

/// عنصر يمثل صورة (مذكرة/سبورة) داخل التطبيق - بديل تجريبي (placeholder) لحين
