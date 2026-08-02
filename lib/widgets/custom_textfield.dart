import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextFeld extends StatelessWidget {
  final String text;
  final IconData icon;
  final TextEditingController? controller;

  const CustomTextFeld({
    super.key,
    required this.text,
    required this.icon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: text,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
}

class CustomTextPass extends StatefulWidget {
  final String text;
  final IconData icon;
  final IconData? fixIcon;
  final TextEditingController? controller;

  const CustomTextPass({
    super.key,
    required this.text,
    required this.icon,
    this.fixIcon,
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
        hintText: widget.text,
        prefixIcon: Icon(widget.icon, color: AppColors.primary),
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
