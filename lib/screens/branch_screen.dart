import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/services/data/branch_data.dart';
import 'package:rburger/widgets/bottom_nav.dart';
import 'package:rburger/widgets/branch_card.dart';
import 'package:rburger/widgets/footer.dart';
import 'package:rburger/widgets/top_bar.dart';
import 'package:easy_localization/easy_localization.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream50,
      bottomNavigationBar: BottomNav(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ColoredBox(color: AppColors.maroon950, child: TopBar()),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'branches.our_branches'.tr(),
                            style: GoogleFonts.lalezar(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: AppColors.maroon800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'branches.choose_the_closest_one_to_you'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.ink600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              for (final branch in branches) ...[
                                BranchCard(branch: branch),
                                const SizedBox(height: 18),
                              ],
                            ],
                          ),
                        ),
                        Spacer(),
                        const Footer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
