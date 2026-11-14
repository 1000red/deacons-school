import 'package:flutter/material.dart';

/// شريط تطبيقي موحّد لكل شاشات المحتوى.
PreferredSizeWidget appBarFor(String title, {List<Widget>? actions}) {
  return AppBar(title: Text(title), actions: actions);
}
