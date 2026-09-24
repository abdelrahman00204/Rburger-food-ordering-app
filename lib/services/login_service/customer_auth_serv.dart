import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rburger/services/login_service/auth_controller.dart';

class CustomerAuthService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            // CHANGED: Added explicit timeouts so connection issues fail immediately instead of hanging
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          // CHANGED: Added LogInterceptor to print complete request/response details to the console
          LogInterceptor(
            request: true,
            requestBody: true,
            responseBody: true,
            error: true,
          ),
        );

  // CHANGED: Added an interceptor to handle token refresh automatically on 401 Unauthorized errors
  static void initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          if (e.response?.statusCode == 401 &&
              e.requestOptions.extra['isRetried'] != true) {
            e.requestOptions.extra['isRetried'] = true;

            try {
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

  static Future<Map<String, dynamic>> loginWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/auth/customer/login',
        data: {'phone': phone, 'password': password},
      );

      debugPrint('Login status: ${response.statusCode}');
      debugPrint('Login body: ${response.data}');

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      await AuthController.instance.loginCustomer(
        customerId: data['customerId'] ?? '',
        fullName: data['fullName'] ?? '',
        accessToken: data['accessToken'] ?? '',
        refreshTokenValue: data['refreshToken'] ?? '',
        mobile: phone,
      );

      return data;
    } on DioException catch (e) {
      // CHANGED: Improved error logging to catch connection drops and timeouts where response is null
      debugPrint('Login failed type: ${e.type}');
      debugPrint('Login failed message: ${e.message}');
      debugPrint(
        'Login failed response: ${e.response?.statusCode} - ${e.response?.data}',
      );

      if (e.response == null) {
        throw 'Network error: Unable to connect to server. Check your API_URL in .env.';
      } else if (e.response?.statusCode == 404) {
        throw 'user_not_found';
      } else if (e.response?.statusCode == 401) {
        throw 'wrong_password';
      } else {
        throw 'error';
      }
    }
  }

  static Future<void> registerWithPhone({
    required String fullName,
    required String phone,
    required String password,
    required String address,
    required String preferredLanguage,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/auth/customer/signup',
        data: {
          'fullName': fullName,
          'phone': phone,
          'password': password,
          'address': address,
          'preferredLanguage': preferredLanguage,
        },
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      await AuthController.instance.loginCustomer(
        customerId: data['customerId'] ?? '',
        fullName: data['fullName'] ?? '',
        accessToken: data['accessToken'] ?? '',
        refreshTokenValue: data['refreshToken'] ?? '',
        mobile: phone,
        address: address,
      );
    } on DioException catch (e) {
      // CHANGED: Improved error logging for signup network failures
      debugPrint('Registration failed type: ${e.type}');
      debugPrint('Registration failed message: ${e.message}');
      debugPrint(
        'Registration failed response: ${e.response?.statusCode} - ${e.response?.data}',
      );

      if (e.response == null) {
        throw 'Network error: Unable to connect to server. Check your API_URL in .env.';
      } else if (e.response?.statusCode == 400) {
        throw 'password_requirements_failed';
      }
      throw 'registration_failed';
    }
  }
}
