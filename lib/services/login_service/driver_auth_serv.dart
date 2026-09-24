import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rburger/services/login_service/auth_controller.dart';

class DriverAuthService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // CHANGED: Added interceptor to handle automatic token refreshing on 401 Unauthorized errors for drivers
  static void initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          if (e.response?.statusCode == 401 &&
              e.requestOptions.extra['isRetried'] != true) {
            e.requestOptions.extra['isRetried'] = true;

            try {
              // CHANGED: Reusing the centralized TokenAuthService method here
              final success = await TokenAuthService.refreshToken();
              if (success) {
                final newToken = AuthController.instance.token;
                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

                final cloneReq = await _dio.fetch(e.requestOptions);
                return handler.resolve(cloneReq);
              }
            } catch (err) {
              debugPrint('Token refresh interceptor error: $err');
            }

            await AuthController.instance.logout();
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<Map<String, dynamic>> loginDriver({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/auth/driver/login',
        data: {'phone': phone, 'password': password},
      );

      debugPrint('Driver login status: ${response.statusCode}');
      debugPrint('Driver login body: ${response.data}');

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      await AuthController.instance.loginDriver(
        driverId: data['driverId'] ?? '',
        fullName: data['fullName'] ?? '',
        branchId: data['branchId'] ?? 0,
        accessToken: data['accessToken'] ?? '',
        refreshTokenValue: data['refreshToken'] ?? '',
      );

      return data;
    } on DioException catch (e) {
      debugPrint(
        'Driver login failed: ${e.response?.statusCode} - ${e.response?.data}',
      );
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw 'invalid_credentials';
      } else {
        throw 'driver_login_error';
      }
    }
  }
}
