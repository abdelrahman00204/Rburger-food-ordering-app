import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/models/product.dart';
import 'package:rburger/services/data/menu_data.dart';
import 'package:rburger/widgets/bottom_nav.dart';
import 'package:rburger/widgets/category_chip.dart';
import 'package:rburger/widgets/footer.dart';
import 'package:rburger/widgets/menu_search_field.dart';
import 'package:rburger/widgets/product_card.dart';
import 'package:rburger/widgets/top_bar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? _selectedCategory;
  String _query = '';

  List<Product> _getVisibleProducts(bool isArabic) {
    List<Product> allProducts = [];
    for (var cat in menuCategories) {
      for (var item in cat.items) {
        allProducts.add(
          Product(
            id: item.id.toString(),
            name: isArabic ? item.nameAr : item.nameEn,
            description: isArabic ? item.descriptionAr : item.descriptionEn,
            price: item.price,
            imageUrl: item.imageUrl,
            category: cat.categoryKey,
          ),
        );
      }
    }

    return allProducts.where((p) {
      final matchesCategory =
          _selectedCategory == null || p.category == _selectedCategory;
      final matchesQuery =
          _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    if (_selectedCategory == null && menuCategories.isNotEmpty) {
      _selectedCategory = menuCategories.first.categoryKey;
    }

    final visibleProducts = _getVisibleProducts(isArabic);

    return Scaffold(
      backgroundColor: AppColors.cream50,
      bottomNavigationBar: BottomNav(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ColoredBox(color: AppColors.maroon950, child: TopBar()),

            Expanded(
              child: menuCategories.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.maroon800,
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'menu.menu'.tr(),
                                  style: GoogleFonts.lalezar(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.maroon800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'menu.prices_vary_based_on_the_branch_selected_above'
                                      .tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.ink600,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                MenuSearchField(
                                  onChanged: (v) => setState(() => _query = v),
                                ),
                                const SizedBox(height: 16),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (
                                        int i = 0;
                                        i < menuCategories.length;
                                        i++
                                      ) ...[
                                        CategoryChip(
                                          label: isArabic
                                              ? menuCategories[i].labelAr
                                              : menuCategories[i].labelEn,
                                          selected:
                                              _selectedCategory ==
                                              menuCategories[i].categoryKey,
                                          onTap: () => setState(
                                            () => _selectedCategory =
                                                menuCategories[i].categoryKey,
                                          ),
                                        ),
                                        if (i < menuCategories.length - 1)
                                          const SizedBox(width: 10),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.45,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = visibleProducts[index];
                              return ProductCard(
                                product: product,
                                onAddToCart: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'menu.param_added_to_cart'.tr(
                                          namedArgs: {
                                            'productName': product.name,
                                          },
                                        ),
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              );
                            }, childCount: visibleProducts.length),
                          ),
                        ),

                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [SizedBox(height: 32), Footer()],
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
