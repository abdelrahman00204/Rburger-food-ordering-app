import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rburger/services/login_service/auth_controller.dart';

class ProfielService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Map<String, dynamic>> getProfile({
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/customers/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      // CHANGED: Replaced non-existent AuthController.instance.login call with existing loginCustomer method to match auth state architecture
      await AuthController.instance.loginCustomer(
        customerId: data['customerId']?.toString() ?? '',
        fullName: data['fullName'] ?? '',
        accessToken: token,
        refreshTokenValue: AuthController.instance.refreshToken ?? '',
        mobile: data['phone'],
        address: data['address'],
      );

      return data;
    } on DioException catch (e) {
      debugPrint(
        'Get profile failed: ${e.response?.statusCode} - ${e.response?.data}',
      );
      throw 'something went wrong, please try again';
    }
  }
}


  // static Future<void> updateLogProfile({
  //   required String token,
  //   required String fullName,
  //   required String phone,
  //   required String address,
  // }) async {
  //   await AuthController.instance.loginCustomer(
  //     customerId: AuthController.instance.customerId ?? '',
  //     fullName: fullName,
  //     accessToken: token,
  //     refreshTokenValue: AuthController.instance.refreshToken ?? '',
  //     mobile: phone,
  //     address: address,
  //   );
  // }

