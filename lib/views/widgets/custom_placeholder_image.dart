import 'package:flutter/material.dart';

/// إضافة الصور الحقيقية. الضغط عليه يفتح عارض ملء الشاشة.
class PlaceholderImageTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const PlaceholderImageTile(
      {super.key,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) =>
                ImageViewerScreen(title: label, color: color, icon: icon)),
      ),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

/// شاشة عرض صورة ملء الشاشة (تجريبية - لا يوجد ملف حقيقي بعد).
class ImageViewerScreen extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  const ImageViewerScreen(
      {super.key,
      required this.title,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(title)),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 72),
              const SizedBox(height: 16),
              Text(title,
                  style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('سيتم عرض الصورة الفعلية هنا بعد رفعها',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5)),
            ],
          ),
        ),
      ),
    );
  }
}
