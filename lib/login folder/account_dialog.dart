import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/login%20folder/auth_tab_switcher.dart';
import 'package:rburger/login%20folder/login_form.dart';
import 'package:rburger/login%20folder/new_account_form.dart';
import 'package:rburger/login%20folder/profile_dialog.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'package:rburger/services/login_service/customer_auth_serv.dart';
import 'package:rburger/services/login_service/driver_auth_serv.dart';

Future<void> showAccountDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) =>
        AuthController.instance.isLoggedIn ||
            AuthController.instance.isDriverLoggedIn
        ? const ProfileDialog()
        : const AccountDialog(),
  );
}

class AccountDialog extends StatefulWidget {
  const AccountDialog({super.key});

  @override
  State<AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<AccountDialog> {
  int _tabIndex = 0;
  bool _isDriverMode = false;
  bool _isLoading = false;

  void _toggleDriverMode() {
    setState(() {
      _isDriverMode = !_isDriverMode;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:  Text('common.error'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('common.ok'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCustomerLogin(String phone, String password) async {
    setState(() => _isLoading = true);
    try {
      await CustomerAuthService.loginWithPhone(
        phone: phone,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      // CHANGED: Improved error messaging to display the actual exception text if connection/timeout occurs
      String errorMessage = 'login.login_failed'.tr();
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('connection timeout')) {
        errorMessage =
            'login.connection_timeout_login'.tr();
      } else if (e.toString() == 'wrong_password') {
        errorMessage = 'login.wrong_password_entered'.tr();
      } else if (e.toString() == 'user_not_found') {
        errorMessage = 'login.user_not_found_phone'.tr();
      } else if (e.toString() != 'error' && e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDriverLogin(String phone, String password) async {
    setState(() => _isLoading = true);
    try {
      await DriverAuthService.loginDriver(phone: phone, password: password);
      if (!mounted) return;
      context.push('/driver');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      // CHANGED: Handled timeout and connection failure descriptions explicitly for drivers
      String errorMessage =
          'login.driver_login_failed'.tr();
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('connection timeout')) {
        errorMessage =
            'login.connection_timeout_driver'.tr();
      } else if (e.toString() != 'driver_login_error' &&
          e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister({
    required String fullName,
    required String phone,
    required String password,
    required String address,
  }) async {
    setState(() => _isLoading = true);
    try {
      await CustomerAuthService.registerWithPhone(
        fullName: fullName,
        phone: phone,
        password: password,
        address: address,
        preferredLanguage: 'en',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      // CHANGED: Added detailed catch mapping for registration dropouts and timeouts
      String errorMessage = 'login.registration_failed'.tr();
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('connection timeout')) {
        errorMessage = 'login.connection_timeout_registration'.tr();
      } else if (e.toString() == 'password_requirements_failed') {
        errorMessage = 'login.password_security_failed'.tr();
      } else if (e.toString() != 'registration_failed' &&
          e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'login.my_account'.tr(),
                        style: GoogleFonts.lalezar(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: AppColors.maroon700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_isDriverMode)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                         Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'login.driver_login'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.maroon800,
                            ),
                          ),
                        ),
                        Container(height: 3, color: AppColors.maroon800),
                      ],
                    )
                  else
                    AuthTabSwitcher(
                      selectedIndex: _tabIndex,
                      onChanged: (i) => setState(() => _tabIndex = i),
                    ),

                  const SizedBox(height: 24),

                  if (_isDriverMode)
                    LoginForm(
                      isDriverMode: true,
                      onToggleRole: _toggleDriverMode,
                      onLogin: (mobile, password) {
                        _handleDriverLogin(mobile, password);
                      },
                    )
                  else if (_tabIndex == 0)
                    LoginForm(
                      isDriverMode: false,
                      onToggleRole: _toggleDriverMode,
                      onLogin: (mobile, password) {
                        _handleCustomerLogin(mobile, password);
                      },
                    )
                  else
                    NewAccountForm(
                      onToggleRole: _toggleDriverMode,
                      onCreateAccount: (name, mobile, address, password) {
                        _handleRegister(
                          fullName: name,
                          phone: mobile,
                          password: password,
                          address: address,
                        );
                      },
                      isDriverMode: _isDriverMode,
                    ),
                ],
              ),
      ),
    );
  }
}
