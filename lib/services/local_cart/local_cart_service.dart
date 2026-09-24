import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCartService {
  static const String _cartKey = 'saved_cart_items';

  // Save cart items list
  static Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(items);
    await prefs.setString(_cartKey, encodedData);
  }

  // Retrieve saved cart items
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_cartKey);

    if (encodedData == null || encodedData.isEmpty) return [];

    try {
      final List decodedList = jsonDecode(encodedData);
      return decodedList
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Clear cart storage
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
