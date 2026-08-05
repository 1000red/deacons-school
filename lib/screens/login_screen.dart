import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

import '../navigator.dart';

import '../widgets/custom_text.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'deacon@church.com');
  final _passCtrl = TextEditingController(text: '123456');
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final error = AppState.instance.login(
      _emailCtrl.text,
      _passCtrl.text,
    );
    if (error.isNotEmpty) {
      setState(() => _error = error);
      return;
    }
    AppNavigation.navigateToLevelScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 180,
                    height: 110,
                    child: Image.asset(
                      'assets/logo-removebg-preview.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "أهلاً بعودتك",
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "سجّل الدخول للمتابعة",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Color.fromARGB(122, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 25.0,
                  right: 25.0,
                  top: 35.0,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                    top: 35.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                          text: "اسم المستخدم / البريد الإلكتروني"),
                      const SizedBox(height: 8.0),
                      CustomTextFeld(
                        controller: _emailCtrl,
                      ),
                      const SizedBox(height: 25.0),
                      const CustomText(text: "كلمة المرور"),
                      const SizedBox(height: 8.0),
                      CustomTextPass(
                        controller: _passCtrl,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10.0),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 35.0),
                      CustomButton(text: 'تسجيل الدخول', onPressed: _submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
