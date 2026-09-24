import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rburger/screens/driver_screen.dart';
import 'package:rburger/screens/branch_screen.dart';
import 'package:rburger/screens/builder_screen.dart';
import 'package:rburger/screens/cart_screen.dart';
import 'package:rburger/screens/home_screen.dart';
import 'package:rburger/screens/menu_screen.dart';
import 'package:rburger/screens/orders_screen.dart';
import 'package:rburger/services/login_service/auth_controller.dart';

class Routing {
  final GoRouter router = GoRouter(
    initialLocation: "/home",
    routes: [
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/menu',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MenuScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      GoRoute(
        path: '/builder',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BurgerBuilderScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      GoRoute(
        path: '/orders',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OrdersScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      GoRoute(
        path: '/branches',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BranchesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      GoRoute(
        path: '/cart',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CartScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      GoRoute(
        path: '/driver',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: DriverScreen(
            driverName: AuthController.instance.name,
            onLogout: () async {
              // CHANGED: Properly clear local session tokens and driver state before navigating away
              await AuthController.instance.logout();
              if (!context.mounted) return;
              context.go('/home');
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
    ],
  );
}
