import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/login folder/labeled_text_field.dart';
import 'package:rburger/login folder/primary_button.dart';

class LoginForm extends StatefulWidget {
  // Updated signature to pass both mobile and password
  final void Function(String mobile, String password) onLogin;
  final VoidCallback onToggleRole;
  final bool isDriverMode;

  const LoginForm({
    super.key,
    required this.onLogin,
    required this.onToggleRole,
    this.isDriverMode = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(
        _mobileController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledTextField(
            label: 'common.phone_label'.tr(),
            keyboardType: TextInputType.phone,
            controller: _mobileController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'common.validators.phone_required'.tr();
              }
              if (value.trim().length != 11) {
                return 'login.mobile_number_exact_digits'.tr();
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                return 'login.mobile_number_digits_only'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          LabeledTextField(
            label: 'common.password'.tr(),
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'common.validators.password_required'.tr();
              }
              if (value.length < 4) {
                return 'login.password_min_length_4'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'common.login'.tr(), onPressed: _submitLogin),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: widget.onToggleRole,
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.maroon800,
                  ),
                  children: [
                    TextSpan(text: 'login.login_as_a'.tr()),
                    TextSpan(
                      // Swaps the colored text based on the mode
                      text: widget.isDriverMode
                          ? 'login.customer'.tr()
                          : 'login.driver'.tr(),
                      style: const TextStyle(color: AppColors.gold500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
