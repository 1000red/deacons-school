import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigator.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../viewmodels/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'deacon@church.com');
  final _passCtrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final authViewModel = context.read<AuthViewModel>();
    final loggedIn = authViewModel.login(_emailCtrl.text, _passCtrl.text);

    if (loggedIn) {
      AppNavigation.navigateToLevelScreen(context);
    }
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
                  const SizedBox(height: AppSpacing.card),
                  SizedBox(
                    width: 180,
                    height: 110,
                    child: Image.asset(
                      'assets/image/logo-removebg-preview.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  Text(
                    "أهلاً بعودتك",
                    style: AppTypography.display.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stack),
                  const Text(
                    "سجّل الدخول للمتابعة",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xCCFFFFFF), // أبيض 80% — تباين 7.3:1
                      fontWeight: FontWeight.w500,
                      height: 1.4,
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
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // النموذج بيتوسّط رأسيًا في اللوح الأبيض لما يكون أقصر
                  // منه (بدل ما يفضل ملتصق بالأعلى ويسيب فراغ ضخم تحته)،
                  // ولما يبقى أطول منه بيتملّي عادي.
                  const verticalPadding = 32 + AppSpacing.block;
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.block,
                        32,
                        AppSpacing.block,
                        AppSpacing.block,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              constraints.maxHeight - verticalPadding,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(
                                text: "اسم المستخدم / البريد الإلكتروني"),
                            const SizedBox(height: AppSpacing.tight),
                            CustomTextField(
                              controller: _emailCtrl,
                            ),
                            const SizedBox(height: AppSpacing.block),
                            const CustomText(text: "كلمة المرور"),
                            const SizedBox(height: AppSpacing.tight),
                            CustomPasswordField(
                              controller: _passCtrl,
                            ),
                            Consumer<AuthViewModel>(
                              builder: (context, authViewModel, _) {
                                final error = authViewModel.errorMessage;
                                if (error == null) return const SizedBox.shrink();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: AppSpacing.tight),
                                    Text(
                                      error,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.block),
                            CustomButton(
                                text: 'تسجيل الدخول', onPressed: _submit),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
