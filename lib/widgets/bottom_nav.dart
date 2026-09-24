import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rburger/app_theme.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home, 'navigation.home'.tr(), '/home'),
      (Icons.restaurant_menu, 'navigation.menu'.tr(), '/menu'),
      (Icons.lunch_dining, 'navigation.builder'.tr(), '/builder'),
      (Icons.receipt_long, 'navigation.orders'.tr(), '/orders'),
      (Icons.storefront, 'navigation.branches'.tr(), '/branches'),
    ];

    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = items.indexWhere((item) => item.$3 == location);

    return BottomNavigationBar(
      backgroundColor: AppColors.maroon950,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex == -1 ? 0 : currentIndex,
      onTap: (index) => context.go(items[index].$3),
      selectedItemColor: AppColors.gold500,
      unselectedItemColor: AppColors.gold300,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: items
          .map(
            (item) =>
                BottomNavigationBarItem(icon: Icon(item.$1), label: item.$2),
          )
          .toList(),
    );
  }
}
