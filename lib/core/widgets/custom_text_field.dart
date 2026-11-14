import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// حقل نصي عام (اسم المستخدم / البريد الإلكتروني).
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
      decoration: InputDecoration(
        hintText: "أدخل اسم المستخدم",
        prefixIcon:
            const Icon(Icons.person_2_outlined, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
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
        prefixIcon:
            const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _showPass
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _showPass = !_showPass;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
}
