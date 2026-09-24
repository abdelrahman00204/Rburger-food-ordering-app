import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/login folder/labeled_text_field.dart';
import 'package:rburger/login folder/primary_button.dart';

class NewAccountForm extends StatefulWidget {
  // Updated to include password in the callback parameters
  final void Function(
    String name,
    String mobile,
    String address,
    String password,
  )
  onCreateAccount;
  final VoidCallback onToggleRole;
  final bool isDriverMode;

  const NewAccountForm({
    super.key,
    required this.onCreateAccount,
    required this.onToggleRole,
    required this.isDriverMode,
  });

  @override
  State<NewAccountForm> createState() => _NewAccountFormState();
}

class _NewAccountFormState extends State<NewAccountForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitAccount() {
    if (_formKey.currentState!.validate()) {
      widget.onCreateAccount(
        _nameController.text.trim(),
        _mobileController.text.trim(),
        _addressController.text.trim(),
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
            label: 'login.full_name'.tr(),
            hintText: 'login.name_hint'.tr(),
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'login.full_name_required'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          LabeledTextField(
            label: 'login.mobile_number'.tr(),
            keyboardType: TextInputType.phone,
            controller: _mobileController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'login.mobile_number_required'.tr();
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
            label: 'login.delivery_address_optional'.tr(),
            controller: _addressController,
            validator: (value) => null,
          ),
          const SizedBox(height: 18),
          LabeledTextField(
            label: 'common.password'.tr(),
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'login.password_required'.tr();
              }
              if (value.length < 4) {
                return 'login.password_min_length_8'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          LabeledTextField(
            label: 'login.confirm_password'.tr(),
            obscureText: true,
            controller: _confirmPasswordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'login.confirm_password_required'.tr();
              }
              if (value != _passwordController.text) {
                return 'login.passwords_not_match'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'login.create_account'.tr(),
            onPressed: _submitAccount,
          ),
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
                    TextSpan(text: '${'login.login_as'.tr()} '),
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
