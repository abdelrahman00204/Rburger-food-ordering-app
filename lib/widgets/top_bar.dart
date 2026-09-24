import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/cubit/badge_cubit.dart';
import 'package:rburger/cubit/branch_selector_cubit.dart';
import 'package:rburger/cubit/branch_selector_state.dart';
import 'package:rburger/login folder/account_dialog.dart';
import 'package:rburger/services/data/branch_data.dart';
import 'package:rburger/services/data/menu_data.dart';
import 'package:rburger/services/login_service/auth_controller.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    void showBranchDialog(BuildContext context, String currentSelectedValue) {
      final availableBranches = branches.isNotEmpty
          ? branches
          : [
              BranchData(
                id: 0,
                nameAr: 'سوهاج',
                nameEn: 'Sohag',
                deliveryFee: 0,
                etaMinMinutes: 0,
                etaMaxMinutes: 0,
                estimatedDeliveryTime: '',
                hotlinePhones: '',
              ),
            ];

      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: const Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < availableBranches.length; i++) ...[
                    RadioListTile<String>(
                      title: Text(
                        isArabic
                            ? availableBranches[i].nameAr
                            : availableBranches[i].nameEn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      value: availableBranches[i].nameEn,
                      groupValue: currentSelectedValue,
                      activeColor: const Color(0xFFA5B4FC),
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (String? newValue) async {
                        if (newValue != null) {
                          context.read<BranchSelectorCubit>().changeBranch(
                            newValue,
                          );

                          final selectedBranchObj = availableBranches
                              .firstWhere(
                                (b) =>
                                    b.nameEn == newValue ||
                                    b.nameAr == newValue,
                                orElse: () => availableBranches.first,
                              );

                          // Save branch ID securely and fetch the updated menu immediately
                          await AuthController.instance.saveBranchId(
                            selectedBranchObj.id,
                          );
                          await MenuService.getMenu(selectedBranchObj.id);
                        }
                        Navigator.pop(dialogContext);
                      },
                    ),
                    if (i < availableBranches.length - 1)
                      const Divider(
                        color: Color(0xFF4A4A4A),
                        height: 1,
                        thickness: 1,
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.gold500,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.asset(
                'assets/app_icon_master.png',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(width: 12),

          BlocBuilder<BranchSelectorCubit, BranchSelectorState>(
            builder: (context, state) {
              final matchedBranch = branches.firstWhere(
                (b) =>
                    b.nameEn == state.selectedBranch ||
                    b.nameAr == state.selectedBranch,
                orElse: () => branches.isNotEmpty
                    ? branches.first
                    : BranchData(
                        id: 0,
                        nameAr: 'سوهاج',
                        nameEn: 'Sohag',
                        deliveryFee: 0,
                        etaMinMinutes: 0,
                        etaMaxMinutes: 0,
                        estimatedDeliveryTime: '',
                        hotlinePhones: '',
                      ),
              );

              final displayBranchName = isArabic
                  ? matchedBranch.nameAr
                  : matchedBranch.nameEn;

              return Expanded(
                child: InkWell(
                  onTap: () => showBranchDialog(context, matchedBranch.nameEn),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.gold300, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayBranchName,
                          style: const TextStyle(
                            color: AppColors.gold200,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.gold200,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 10),
          CircleIconButton(
            icon: Icons.public,
            filled: false,
            onPressed: () {
              final newLocale = context.locale.languageCode == 'en'
                  ? const Locale('ar')
                  : const Locale('en');
              context.setLocale(newLocale);
            },
          ),
          const SizedBox(width: 10),
          BlocBuilder<CartCountCubit, int>(
            bloc: CartCountCubit.instance,
            builder: (context, count) {
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                backgroundColor: AppColors.gold500,
                textColor: AppColors.maroon950,
                child: CircleIconButton(
                  icon: Icons.shopping_cart,
                  filled: true,
                  onPressed: () {
                    context.push('/cart');
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          CircleIconButton(
            icon: Icons.person,
            filled: false,
            onPressed: () {
              if (AuthController.instance.isDriverLoggedIn) {
                context.push('/driver');
              } else {
                showAccountDialog(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onPressed;
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: filled
            ? AppColors.gold500
            : Colors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: filled ? AppColors.maroon950 : AppColors.gold200,
      ),
    );
  }
}
