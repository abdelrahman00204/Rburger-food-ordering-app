import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/services/data/branch_data.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not call $phoneNumber')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      width: double.infinity,
      color: AppColors.maroon950,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'footer.r_burger_2'.tr(),
            style: GoogleFonts.lalezar(
              color: AppColors.gold400,
              fontWeight: FontWeight.w400,
              fontSize: 24,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'footer.republic_restaurant'.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'footer.2026_all_rights_reserved'.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'common.contact_us'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          // Branches from API
          if (branches.isEmpty)
            Text(
              'footer.no_branch_phone_numbers_available'.tr(),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            )
          else
            ...branches.map((branch) {
              final branchName = isArabic ? branch.nameAr : branch.nameEn;

              final phone = branch.hotlinePhones.trim();

              if (phone.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: () => _makePhoneCall(context, phone),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '$branchName: $phone',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
