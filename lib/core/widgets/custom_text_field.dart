import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// حقل نصي عام (اسم المستخدم / البريد الإلكتروني).
///
/// الشكل (الحشو، الحدود، نصف القطر، لون الحد عند التركيز) كله جاي من
/// `inputDecorationTheme` في [AppTheme]، فالموقع بس بيضيف الأيقونة والنص.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: "أدخل اسم المستخدم",
        prefixIcon: Icon(Icons.person_2_outlined),
      ),
    );
  }
}

/// حقل كلمة المرور مع زر إظهار/إخفاء النص.
class CustomPasswordField extends StatefulWidget {
  final TextEditingController? controller;

  const CustomPasswordField({
    super.key,
    this.controller,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _showPass = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _showPass,
      decoration: InputDecoration(
        hintText: "أدخل كلمة المرور",
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _showPass
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          tooltip: _showPass ? "إظهار كلمة المرور" : "إخفاء كلمة المرور",
          onPressed: () {
            setState(() {
              _showPass = !_showPass;
            });
          },
        ),
      ),
    );
  }
}
