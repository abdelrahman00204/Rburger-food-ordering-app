import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'package:rburger/services/orders/orders_model.dart';

class OrderConfirmationService {
  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final validToken = await AuthController.instance
                  .getValidAccessToken();
              if (validToken != null) {
                options.headers['Authorization'] = 'Bearer $validToken';
              }
              handler.next(options);
            },
          ),
        );

  static Future<PaginatedOrdersResponse?> getUserOrders({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/orders/mine',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        return PaginatedOrdersResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Get orders error: $e');
      return null;
    }
  }

  static Future<bool> confirmOrderReceived({
    required String orderId,
    required String customerReceivedAt,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/orders/$orderId/customer-received',
        data: {'orderId': orderId, 'customerReceivedAt': customerReceivedAt},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Order delivery confirmed successfully: ${response.data}');
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint('Confirm order received failed: ${e.response?.statusCode}');
      debugPrint('Confirm order received response body: ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Confirm order received error: $e');
      return false;
    }
  }

  static Future<bool> submitOrderReview({
    required String orderId,
    required int rating,
    required String comment,
    required String customerId, 
  }) async {
    try {
      final response = await _dio.post(
        '/v1/orders/$orderId/review',
        data: {
          'rating': rating,
          'comment': comment,
          'orderId': orderId,
          'customerId': customerId,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting order review: $e');
      return false;
    }
  }
}
