import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rburger/app_theme.dart';
import 'package:rburger/burger%20model/builder_section.dart';
import 'package:rburger/burger%20model/burger_art.dart';
import 'package:rburger/burger%20model/burger_selection.dart';
import 'package:rburger/models/cart_item.dart';
import 'package:rburger/screens/cart_screen.dart';
import 'package:rburger/services/data/burger_options_data.dart';
import 'package:rburger/widgets/bottom_nav.dart';
import 'package:rburger/widgets/footer.dart';
import 'package:rburger/widgets/top_bar.dart';

class BurgerBuilderScreen extends StatefulWidget {
  const BurgerBuilderScreen({super.key});

  @override
  State<BurgerBuilderScreen> createState() => _BurgerBuilderScreenState();
}

class _BurgerBuilderScreenState extends State<BurgerBuilderScreen> {
  final Map<String, String?> _selectedSingleOptions = {};
  final Map<String, Set<String>> _selectedMultiOptions = {};

  bool _isArabic(BuildContext context) {
    return context.locale.languageCode == 'ar';
  }

  String _optionGroupName(BuildContext context, OptionGroupData group) {
    final key = group.groupKey;

    switch (key.toLowerCase()) {
      case 'bun':
      case 'buns':
        return context.tr('burger_builder.bun');

      case 'patty':
      case 'patties':
      case 'meat':
        return context.tr('burger_builder.patty');

      case 'cheese':
      case 'cheeses':
        return context.tr('burger_builder.cheese');

      case 'sauce':
      case 'sauces':
        return context.tr('burger_builder.sauce');

      case 'topping':
      case 'toppings':
        return context.tr('burger_builder.toppings');

      default:
        return key;
    }
  }

  String _optionLabel(BuildContext context, OptionItemData option) {
    return _isArabic(context) ? option.nameAr : option.nameEn;
  }

  List<BurgerIngredient> _mapOptions(
    BuildContext context,
    OptionGroupData group,
  ) {
    return group.options.map((option) {
      return BurgerIngredient(
        id: option.id.toString(),
        label: _optionLabel(context, option),
        priceDelta: option.extraPrice.toInt(),
      );
    }).toList();
  }

  void _selectOption(OptionGroupData group, BurgerIngredient option) {
    setState(() {
      final key = group.groupKey;

      if (group.isSingleSelect) {
        _selectedSingleOptions[key] = option.id;
      } else {
        final selected = _selectedMultiOptions.putIfAbsent(
          key,
          () => <String>{},
        );

        if (selected.contains(option.id)) {
          selected.remove(option.id);
        } else {
          selected.add(option.id);
        }
      }
    });
  }

  bool _isOptionSelected(OptionGroupData group, BurgerIngredient option) {
    final key = group.groupKey;

    if (group.isSingleSelect) {
      return _selectedSingleOptions[key] == option.id;
    }

    return _selectedMultiOptions[key]?.contains(option.id) ?? false;
  }

  List<BurgerIngredient> _selectedOptionsForGroup(
    OptionGroupData group,
    BuildContext context,
  ) {
    final options = _mapOptions(context, group);

    if (group.isSingleSelect) {
      final selectedId = _selectedSingleOptions[group.groupKey];

      if (selectedId == null) {
        return [];
      }

      return options.where((option) => option.id == selectedId).toList();
    }

    final selectedIds = _selectedMultiOptions[group.groupKey] ?? <String>{};

    return options.where((option) => selectedIds.contains(option.id)).toList();
  }

  OptionGroupData? _findGroup(String type) {
    for (final group in optionGroups) {
      final key = group.groupKey.toLowerCase();

      if (type == 'bun' && (key.contains('bun'))) {
        return group;
      }

      if (type == 'patty' && (key.contains('patty') || key.contains('meat'))) {
        return group;
      }

      if (type == 'cheese' && key.contains('cheese')) {
        return group;
      }

      if (type == 'sauce' && key.contains('sauce')) {
        return group;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    /*
     * The API is now the source of truth.
     *
     * We do not create fake/default options anymore.
     */
    final groups = optionGroups
        .where((group) => group.options.isNotEmpty)
        .toList();

    /*
     * Keep these references because BurgerSelection currently expects
     * bun, patty, cheese and sauce separately.
     */
    final bunGroup = _findGroup('bun');
    final pattyGroup = _findGroup('patty');
    final cheeseGroup = _findGroup('cheese');
    final sauceGroup = _findGroup('sauce');

    /*
     * Get the currently selected option for the groups that are used
     * by BurgerSelection.
     */
    final bunOptions = bunGroup == null
        ? <BurgerIngredient>[]
        : _mapOptions(context, bunGroup);

    final pattyOptions = pattyGroup == null
        ? <BurgerIngredient>[]
        : _mapOptions(context, pattyGroup);

    final cheeseOptions = cheeseGroup == null
        ? <BurgerIngredient>[]
        : _mapOptions(context, cheeseGroup);

    final sauceOptions = sauceGroup == null
        ? <BurgerIngredient>[]
        : _mapOptions(context, sauceGroup);

    /*
     * Automatically select the first API option for single-select
     * groups if nothing has been selected yet.
     */
    if (bunGroup != null &&
        bunGroup.isSingleSelect &&
        _selectedSingleOptions[bunGroup.groupKey] == null &&
        bunOptions.isNotEmpty) {
      _selectedSingleOptions[bunGroup.groupKey] = bunOptions.first.id;
    }

    if (pattyGroup != null &&
        pattyGroup.isSingleSelect &&
        _selectedSingleOptions[pattyGroup.groupKey] == null &&
        pattyOptions.isNotEmpty) {
      _selectedSingleOptions[pattyGroup.groupKey] = pattyOptions.first.id;
    }

    if (cheeseGroup != null &&
        cheeseGroup.isSingleSelect &&
        _selectedSingleOptions[cheeseGroup.groupKey] == null &&
        cheeseOptions.isNotEmpty) {
      _selectedSingleOptions[cheeseGroup.groupKey] = cheeseOptions.first.id;
    }

    if (sauceGroup != null &&
        sauceGroup.isSingleSelect &&
        _selectedSingleOptions[sauceGroup.groupKey] == null &&
        sauceOptions.isNotEmpty) {
      _selectedSingleOptions[sauceGroup.groupKey] = sauceOptions.first.id;
    }

    final currentBun = bunGroup == null
        ? const BurgerIngredient(id: '', label: '', priceDelta: 0)
        : _selectedOptionsForGroup(bunGroup, context).firstOrNull ??
              (bunOptions.isNotEmpty
                  ? bunOptions.first
                  : const BurgerIngredient(id: '', label: '', priceDelta: 0));

    final currentPatty = pattyGroup == null
        ? const BurgerIngredient(id: '', label: '', priceDelta: 0)
        : _selectedOptionsForGroup(pattyGroup, context).firstOrNull ??
              (pattyOptions.isNotEmpty
                  ? pattyOptions.first
                  : const BurgerIngredient(id: '', label: '', priceDelta: 0));

    final currentCheese = cheeseGroup == null
        ? const BurgerIngredient(id: '', label: '', priceDelta: 0)
        : _selectedOptionsForGroup(cheeseGroup, context).firstOrNull ??
              (cheeseOptions.isNotEmpty
                  ? cheeseOptions.first
                  : const BurgerIngredient(id: '', label: '', priceDelta: 0));

    final currentSauce = sauceGroup == null
        ? const BurgerIngredient(id: '', label: '', priceDelta: 0)
        : _selectedOptionsForGroup(sauceGroup, context).firstOrNull ??
              (sauceOptions.isNotEmpty
                  ? sauceOptions.first
                  : const BurgerIngredient(id: '', label: '', priceDelta: 0));

    /*
     * Toppings are all groups that aren't bun/patty/cheese/sauce.
     *
     * This means the API can add another option group without requiring
     * another hardcoded Dart list.
     */
    final toppingGroups = groups.where((group) {
      final key = group.groupKey.toLowerCase();

      return !key.contains('bun') &&
          !key.contains('patty') &&
          !key.contains('meat') &&
          !key.contains('cheese') &&
          !key.contains('sauce');
    }).toList();

    final List<BurgerIngredient> selectedToppings = [];

    for (final group in toppingGroups) {
      selectedToppings.addAll(_selectedOptionsForGroup(group, context));
    }

    final selection = BurgerSelection(
      bun: currentBun,
      patty: currentPatty,
      cheese: currentCheese,
      sauce: currentSauce,
      toppings: selectedToppings,
    );

    return Scaffold(
      backgroundColor: AppColors.cream50,
      bottomNavigationBar: BottomNav(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ColoredBox(color: AppColors.maroon950, child: TopBar()),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'builder.build_your_burger'.tr(),
                            style: GoogleFonts.lalezar(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: AppColors.maroon800,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'builder.pick_your_burger_ingredients_and_watch_it_build_in_front_of_you_with_the_price_u'
                                .tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.ink600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                        decoration: BoxDecoration(
                          color: AppColors.maroon950,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BurgerPreview(selection: selection),

                            const SizedBox(height: 8),

                            Center(
                              child: Text(
                                'common.total'.tr(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Center(
                              child: Text(
                                '${selection.totalPrice} EGP',
                                style: GoogleFonts.lalezar(
                                  color: AppColors.gold400,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Divider(color: Color(0xFF4A2814), height: 1),

                            const SizedBox(height: 24),

                            /*
                             * Render EVERY group returned by the API.
                             *
                             * No hardcoded option list is created here.
                             */
                            ...groups.asMap().entries.map((entry) {
                              final index = entry.key;
                              final group = entry.value;

                              final options = _mapOptions(context, group);

                              if (options.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == groups.length - 1 ? 28 : 22,
                                ),
                                child: BuilderSection(
                                  title: _optionGroupName(context, group),
                                  hint: group.isSingleSelect
                                      ? null
                                      : 'builder.choose_more_than_one'.tr(),
                                  options: options,
                                  isSelected: (option) =>
                                      _isOptionSelected(group, option),
                                  onSelect: (option) {
                                    _selectOption(group, option);
                                  },
                                ),
                              );
                            }),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: groups.isEmpty
                                    ? null
                                    : () {
                                        final descriptionParts = [
                                          if (currentBun.label.isNotEmpty)
                                            currentBun.label,
                                          if (currentPatty.label.isNotEmpty)
                                            currentPatty.label,
                                          if (currentCheese.label.isNotEmpty)
                                            currentCheese.label,
                                          if (currentSauce.label.isNotEmpty)
                                            currentSauce.label,
                                          ...selectedToppings.map(
                                            (t) => t.label,
                                          ),
                                        ];

                                        CartController.instance.addItem(
                                          CartItem(
                                            id: 'custom_${currentBun.id}_${currentPatty.id}_${currentCheese.id}_${currentSauce.id}',
                                            name: 'builder.custom_burger'.tr(),
                                            description: descriptionParts.join(
                                              ', ',
                                            ),
                                            unitPrice: selection.totalPrice,
                                          ),
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'builder.custom_burger_added_to_cart'
                                                  .tr(),
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold500,
                                  foregroundColor: AppColors.maroon950,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'builder.add_my_burger_to_cart_param_egp'.tr(
                                    namedArgs: {
                                      'totalPrice': selection.totalPrice
                                          .toString(),
                                    },
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
