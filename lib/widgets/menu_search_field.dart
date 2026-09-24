import 'package:flutter/material.dart';
import 'package:rburger/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class MenuSearchField extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const MenuSearchField({super.key, this.hintText, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.ink900, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText ?? 'menu.search_for_a_burger_chicken'.tr(),
        hintStyle: const TextStyle(color: AppColors.ink600, fontSize: 15),
        prefixIcon: const Icon(Icons.search, color: AppColors.ink600),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.gold500),
        ),
      ),
    );
  }
}
