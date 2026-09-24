import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/login%20folder/account_dialog.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'package:rburger/models/cart_item.dart';
import 'package:rburger/widgets/cart_item_tile.dart';
import 'package:rburger/widgets/cart_summery.dart';
import 'package:rburger/widgets/checkout_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rburger/cubit/branch_selector_cubit.dart';
import 'package:rburger/cubit/branch_selector_state.dart';
import 'package:rburger/services/data/branch_data.dart';

/// Shared cart state. Call CartController.instance.addItem(...) from the
/// Menu screen's "Add to cart" button (or the Builder screen) so items
/// pushed from anywhere in the app show up here automatically.
class CartController extends ChangeNotifier {
  CartController._() {
    loadCartFromStorage();
  }
  static final CartController instance = CartController._();

  final _storage = const FlutterSecureStorage();
  static const String _storageKey = 'saved_cart_items';

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Load saved cart items from local storage on startup
  Future<void> loadCartFromStorage() async {
    try {
      final String? jsonString = await _storage.read(key: _storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        _items.clear();
        for (var itemJson in decodedList) {
          _items.add(CartItem.fromJson(itemJson));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart from storage: $e');
      await _storage.delete(key: _storageKey);
    }
  }

  // Save current cart items to local storage
  Future<void> _saveCartToStorage() async {
    try {
      final List<Map<String, dynamic>> jsonList = _items
          .map((item) => item.toJson())
          .toList();
      await _storage.write(key: _storageKey, value: jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving cart to storage: $e');
    }
  }

  void addItem(CartItem newItem) {
    final index = _items.indexWhere((i) => i.id == newItem.id);
    if (index == -1) {
      _items.add(newItem);
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
    }
    _saveCartToStorage();
    notifyListeners();
  }

  void increment(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
    );
    _saveCartToStorage();
    notifyListeners();
  }

  void decrement(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final current = _items[index];
    if (current.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = current.copyWith(quantity: current.quantity - 1);
    }
    _saveCartToStorage();
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.id == id);
    _saveCartToStorage();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _storage.delete(key: _storageKey);
    notifyListeners();
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartController.instance,
      builder: (context, _) {
        final items = CartController.instance.items;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: AppColors.maroon950,
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'cart.your_cart'.tr(),
                        style: GoogleFonts.lalezar(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold400,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close, color: AppColors.gold200),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'cart.your_cart_is_empty'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.ink600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return CartItemTile(
                              key: ValueKey(item.id),
                              item: item,
                              onIncrement: () =>
                                  CartController.instance.increment(item.id),
                              onDecrement: () =>
                                  CartController.instance.decrement(item.id),
                              onRemove: () =>
                                  CartController.instance.remove(item.id),
                            );
                          },
                        ),
                ),
                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.line)),
                    ),
                    child: Column(
                      children: [
                        BlocBuilder<BranchSelectorCubit, BranchSelectorState>(
                          builder: (context, branchState) {
                            final selectedBranch = branches.firstWhere(
                              (b) =>
                                  b.nameEn == branchState.selectedBranch ||
                                  b.nameAr == branchState.selectedBranch,
                              orElse: () => branches.isNotEmpty
                                  ? branches.first
                                  : BranchData(
                                      id: 0,
                                      nameAr: '',
                                      nameEn: '',
                                      deliveryFee: 0,
                                      etaMinMinutes: 0,
                                      etaMaxMinutes: 0,
                                      estimatedDeliveryTime: '',
                                      hotlinePhones: '',
                                    ),
                            );

                            return CartSummary(
                              subtotal: CartController.instance.subtotal,
                              deliveryFee: selectedBranch.deliveryFee.round(),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (AuthController.instance.isLoggedIn) {
                                showCheckoutDialog(context);
                              } else {
                                showAccountDialog(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.maroon950,
                              foregroundColor: AppColors.gold400,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'cart.checkout_pay'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
