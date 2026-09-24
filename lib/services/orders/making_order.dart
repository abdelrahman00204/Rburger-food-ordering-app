import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'package:rburger/services/orders/orders_model.dart';

class MakeOrderService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<OrderCreatedResponse?> createOrder(
    CreateOrderRequest request,
  ) async {
    try {
      final token = AuthController.instance.token;
      final response = await _dio.post(
        '/v1/orders',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Idempotency-Key': request.idempotencyKey,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        return OrderCreatedResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint('❌ Server Validation Error: ${e.response?.data}');
      } else {
        debugPrint('❌ Create order error: $e');
      }
      return null;
    }
  }
}
