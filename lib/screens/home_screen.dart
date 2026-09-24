import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/models/product.dart';
import 'package:rburger/services/data/menu_data.dart';
import 'package:rburger/widgets/bottom_nav.dart';
import 'package:rburger/widgets/floating_burger.dart';
import 'package:rburger/widgets/footer.dart';
import 'package:rburger/widgets/product_tile.dart';
import 'package:rburger/widgets/top_bar.dart';
import '/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.cream50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              expandedHeight: 80,
              toolbarHeight: 80,
              flexibleSpace: FlexibleSpaceBar(background: TopBar()),
            ),
            const SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.maroon700, AppColors.maroon950],
                  ),
                ),
                child: Column(children: [_HeroSection()]),
              ),
            ),

            // Dynamically expand backend categories directly into the slivers list
            if (menuCategories.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.maroon800),
                ),
              )
            else
              ...menuCategories.asMap().entries.expand((entry) {
                final catIndex = entry.key;
                final category = entry.value;
                final categoryLabel = isArabic
                    ? category.labelAr
                    : category.labelEn;
                final categoryBgColor = catIndex % 2 == 0
                    ? AppColors.cream50
                    : AppColors.gold200;

                final mappedProducts = category.items
                    .map(
                      (item) => Product(
                        id: item.id.toString(),
                        name: isArabic ? item.nameAr : item.nameEn,
                        description: isArabic
                            ? item.descriptionAr
                            : item.descriptionEn,
                        price: item.price,
                        imageUrl: item.imageUrl,
                        category: category.categoryKey,
                      ),
                    )
                    .toList();

                return [
                  SliverToBoxAdapter(
                    child: Container(
                      color: categoryBgColor,
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                      child: _SectionHeader(title: categoryLabel.toUpperCase()),
                    ),
                  ),
                  DecoratedSliver(
                    decoration: BoxDecoration(color: categoryBgColor),
                    sliver: SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.separated(
                        itemCount: mappedProducts.length,
                        itemBuilder: (context, index) =>
                            ProductTile(product: mappedProducts[index]),
                        separatorBuilder: (context, index) =>
                            const Divider(color: AppColors.line, height: 1),
                      ),
                    ),
                  ),
                ];
              }),

            const SliverToBoxAdapter(child: Footer()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.a_burger_bite'.tr(),
            style: GoogleFonts.lalezar(
              color: AppColors.cream50,
              fontWeight: FontWeight.w500,
              fontSize: 43,
              height: 1.05,
            ),
          ),
          Text(
            'home.your_way'.tr(),
            style: GoogleFonts.lalezar(
              color: AppColors.gold500,
              fontWeight: FontWeight.w500,
              fontSize: 43,
              height: 1.05,
            ),
          ),
          Text(
            'home.delivered_while'.tr(),
            style: GoogleFonts.lalezar(
              color: AppColors.cream50,
              fontWeight: FontWeight.w500,
              fontSize: 43,
              height: 1.05,
            ),
          ),
          Text(
            'home.you_track_it'.tr(),
            style: GoogleFonts.lalezar(
              color: AppColors.cream50,
              fontWeight: FontWeight.w500,
              fontSize: 43,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'home.description'.tr(),
            style: TextStyle(
              color: AppColors.gold200.withValues(alpha: 0.75),
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/builder');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold500,
                    foregroundColor: AppColors.maroon950,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'home.build_your_burger_now'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/menu');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold400,
                    side: const BorderSide(
                      color: AppColors.gold400,
                      width: 1.4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'home.view_menu'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const AspectRatio(aspectRatio: 1, child: FloatingBurger()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lalezar(
            color: AppColors.maroon800,
            fontWeight: FontWeight.w700,
            fontSize: 30,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(height: 2, color: AppColors.maroon800),
      ],
    );
  }
}
