// lib/services/payment_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rburger/services/login_service/auth_controller.dart';

class PaymentIntentResult {
  final String clientSecret;
  final String paymentId;
  final String status;
  PaymentIntentResult({
    required this.clientSecret,
    required this.paymentId,
    required this.status,
  });
}

class PaymentService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<PaymentIntentResult?> createIntent(
    String orderId, {
    required String idempotencyKey,
  }) async {
    try {
      final token = AuthController.instance.token;

      debugPrint('Creating payment for orderId: $orderId');
      debugPrint('Payment URL: $_baseUrl/v1/payments/$orderId/charge');
      debugPrint('Idempotency-Key: $idempotencyKey');

      final response = await _dio.post(
        '/v1/payments/$orderId/charge',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );

      final dynamic data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      debugPrint('Payment response: $data');

      final clientSecret = data['clientSecret'] as String?;
      final paymentId = data['paymentId'] as String?;
      final status = data['status'] as String?;

      if (clientSecret == null || clientSecret.isEmpty) {
        debugPrint('Payment error: clientSecret is missing');
        return null;
      }

      if (paymentId == null || paymentId.isEmpty) {
        debugPrint('Payment error: paymentId is missing');
        return null;
      }

      return PaymentIntentResult(
        clientSecret: clientSecret,
        paymentId: paymentId,
        status: status ?? '',
      );
    } on DioException catch (e) {
      debugPrint('Create payment intent failed');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Request URL: ${e.requestOptions.uri}');
      debugPrint('Request headers: ${e.requestOptions.headers}');
      return null;
    } catch (e) {
      debugPrint('Create payment intent error: $e');
      return null;
    }
  }

  static Future<String?> checkOrderPaymentStatus(String orderId) async {
    try {
      final token = AuthController.instance.token;
      final response = await _dio.get(
        '/v1/orders/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final dynamic data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      return data['payment']['status'] as String?;
    } catch (e) {
      debugPrint('Check order status error: $e');
      return null;
    }
  }
}
