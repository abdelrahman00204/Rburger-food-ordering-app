import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

List<MenuCategoryData> menuCategories = [];

class MenuItemData {
  int id;
  String nameAr;
  String nameEn;
  String descriptionAr;
  String descriptionEn;
  double price;
  String imageUrl;

  MenuItemData({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    required this.imageUrl,
  });

  factory MenuItemData.fromJson(Map<String, dynamic> json) {
    return MenuItemData(
      id: json['id'] ?? 0,
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      descriptionAr: json['descriptionAr'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class MenuCategoryData {
  String categoryKey;
  String labelAr;
  String labelEn;
  List<MenuItemData> items;

  MenuCategoryData({
    required this.categoryKey,
    required this.labelAr,
    required this.labelEn,
    required this.items,
  });

  factory MenuCategoryData.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<MenuItemData> parsedItems = itemsList
        .map((item) => MenuItemData.fromJson(item))
        .toList();

    return MenuCategoryData(
      categoryKey: json['categoryKey'] ?? '',
      labelAr: json['labelAr'] ?? '',
      labelEn: json['labelEn'] ?? '',
      items: parsedItems,
    );
  }
}

class MenuService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // CHANGED: Added branchId parameter to send query parameters to the backend endpoint
  static Future<List<MenuCategoryData>> getMenu(int branchId) async {
    try {
      final response = await _dio.get(
        '/v1/menu',
        queryParameters: {'branchId': branchId},
        options: Options(
          // Tells Dio: "Don't throw an exception for 404, let me handle the status code manually"
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final List<dynamic> jsonList = responseData is List ? responseData : [];
        menuCategories = jsonList
            .map((item) => MenuCategoryData.fromJson(item))
            .toList();
        debugPrint(
          'getMenu success: ${response.statusCode} - ${response.data}',
        );
        debugPrint('- branchId: $branchId');

        return menuCategories;
      } else {
        debugPrint(
          'getMenu failed: ${response.statusCode} - ${response.data} ',
        );
        debugPrint('- branchId: $branchId');

        menuCategories = [];
        return [];
      }
    } on DioException catch (e) {
      debugPrint(
        'getMenu Dio error: ${e.message} (Response: ${e.response?.statusCode})',
      );
      menuCategories = [];
      return [];
    } catch (e) {
      debugPrint('Unexpected getMenu error: $e');
      menuCategories = [];
      return [];
    }
  }
}
