import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

List<OptionGroupData> optionGroups = [];

class OptionItemData {
  int id;
  String nameAr;
  String nameEn;
  double extraPrice;

  OptionItemData({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.extraPrice,
  });

  factory OptionItemData.fromJson(Map<String, dynamic> json) {
    return OptionItemData(
      id: json['id'] ?? 0,
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OptionGroupData {
  String groupKey;
  bool isSingleSelect;
  List<OptionItemData> options;

  OptionGroupData({
    required this.groupKey,
    required this.isSingleSelect,
    required this.options,
  });

  factory OptionGroupData.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    List<OptionItemData> parsedOptions = optionsList
        .map((item) => OptionItemData.fromJson(item))
        .toList();

    return OptionGroupData(
      groupKey: json['groupKey'] ?? '',
      isSingleSelect: json['isSingleSelect'] ?? true,
      options: parsedOptions,
    );
  }
}

class OptionsService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<List<OptionGroupData>> getOptionGroups() async {
    try {
      final response = await _dio.get(
        '/v1/builder/options',
      ); // Adjust route endpoint if necessary

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final List<dynamic> jsonList = responseData is List ? responseData : [];
        optionGroups = jsonList
            .map((item) => OptionGroupData.fromJson(item))
            .toList();
        debugPrint(
          'getOptionGroups success: ${response.statusCode} - ${response.data}',
        );

        return optionGroups;
      } else {
        debugPrint(
          'getOptionGroups failed: ${response.statusCode} - ${response.data}',
        );
        optionGroups = [];
        return [];
      }
    } on DioException catch (e) {
      debugPrint(
        'getOptionGroups Dio error: ${e.message} (Response: ${e.response?.statusCode})',
      );
      optionGroups = [];
      return [];
    } catch (e) {
      debugPrint('Unexpected getOptionGroups error: $e');
      optionGroups = [];
      return [];
    }
  }
}
