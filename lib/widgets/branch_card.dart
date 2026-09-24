import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:rburger/app_theme.dart';
import 'package:rburger/services/data/branch_data.dart';

class BranchCard extends StatelessWidget {
  final BranchData branch;
  final VoidCallback? onTap;

  const BranchCard({super.key, required this.branch, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.locale.languageCode == 'ar';

    final String branchName = isArabic ? branch.nameAr : branch.nameEn;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branchName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.maroon800,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'branches.hotline_param'.tr(
                  namedArgs: {'hotline': branch.hotlinePhones},
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.ink600),
              ),

              const SizedBox(height: 10),

              Text(
                'branches.delivery_fee_param'.tr(
                  namedArgs: {'deliveryFee': branch.deliveryFee.toString()},
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.ink600),
              ),

              const SizedBox(height: 10),

              Text(
                'branches.delivery_time_param'.tr(
                  namedArgs: {
                    'deliveryTime': branch.estimatedDeliveryTime.toString(),
                  },
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.ink600),
              ),

              const SizedBox(height: 10),

              Text(
                'branches.eta_param'.tr(
                  namedArgs: {
                    'min': branch.etaMinMinutes.toString(),
                    'max': branch.etaMaxMinutes.toString(),
                  },
                ),
                style: const TextStyle(fontSize: 14, color: AppColors.ink600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
