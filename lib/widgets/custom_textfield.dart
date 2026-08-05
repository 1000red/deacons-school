import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextFeld extends StatelessWidget {
  final TextEditingController? controller;

  const CustomTextFeld({
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

class CustomTextPass extends StatefulWidget {
  final TextEditingController? controller;

  const CustomTextPass({
    super.key,
    this.controller,
  });

  @override
  State<CustomTextPass> createState() => _CustomTextPassState();
}

class _CustomTextPassState extends State<CustomTextPass> {
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
