import 'package:flutter/material.dart';
import 'package:rburger/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthTabSwitcher extends StatelessWidget {
  final int selectedIndex; // 0 = Login, 1 = New Account
  final ValueChanged<int> onChanged;

  const AuthTabSwitcher({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _tab('common.login'.tr(), 0)),
        Expanded(child: _tab('login.new_account'.tr(), 1)),
      ],
    );
  }

  Widget _tab(String label, int index) {
    final selected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.maroon800 : AppColors.ink600,
              ),
            ),
          ),
          Container(
            height: 3,
            color: selected ? AppColors.maroon800 : AppColors.line,
          ),
        ],
      ),
    );
  }
}
