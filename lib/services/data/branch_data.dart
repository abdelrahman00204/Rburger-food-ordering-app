import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

List<BranchData> branches = [];

class BranchData {
  int id;
  String nameAr;
  String nameEn;
  double deliveryFee;
  int etaMinMinutes;
  int etaMaxMinutes;
  String hotlinePhones;
  String estimatedDeliveryTime;

  BranchData({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.deliveryFee,
    required this.etaMinMinutes,
    required this.etaMaxMinutes,
    required this.hotlinePhones,
    required this.estimatedDeliveryTime,
  });

  factory BranchData.fromJson(Map<String, dynamic> json) {
    return BranchData(
      id: json['id'] ?? 0,
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      etaMinMinutes: json['etaMinMinutes'] ?? 0,
      etaMaxMinutes: json['etaMaxMinutes'] ?? 0,
      hotlinePhones: json['hotlinePhones'] ?? '',
      estimatedDeliveryTime: json['estimatedDeliveryTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'deliveryFee': deliveryFee,
      'etaMinMinutes': etaMinMinutes,
      'etaMaxMinutes': etaMaxMinutes,
      'hotlinePhones': hotlinePhones,
      'estimatedDeliveryTime': estimatedDeliveryTime,
    };
  }
}

class BranchService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<List<BranchData>> getBranch() async {
    try {
      final response = await _dio.get('/v1/branches');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        if (responseData is! List) {
          debugPrint(
            'getBranch failed: Expected a List but received '
            '${responseData.runtimeType}',
          );

          branches = [];
          return [];
        }

        branches = responseData
            .map(
              (item) =>
                  BranchData.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();

        debugPrint(
          'getBranch success: ${response.statusCode} - ${response.data}',
        );

        return branches;
      }

      debugPrint('getBranch failed: ${response.statusCode} - ${response.data}');

      branches = [];
      return [];
    } on DioException catch (e) {
      debugPrint(
        'getBranch Dio error: ${e.message} '
        '(Response: ${e.response?.statusCode})',
      );

      branches = [];
      return [];
    } catch (e) {
      debugPrint('Unexpected getBranch error: $e');

      branches = [];
      return [];
    }
  }
}
