import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'driver_order_dto.dart';

class DriverOrdersService {
  static final token = AuthController.instance.token;

  static final String _baseUrl = dotenv.get('API_URL');

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ),
  );

  // Get new/unassigned orders available for pickup at driver's branch
  static Future<List<DriverNewOrderDto>?> getNewOrders() async {
    try {
      final response = await _dio.get('/v1/driver/orders/new');
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data;
        return list.map((json) => DriverNewOrderDto.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching new driver orders: $e');
    }
    return null;
  }

  // Get orders currently assigned to the logged-in driver
  static Future<List<DriverOrderMineDto>?> getMyOrders({
    String? status = 'active',
  }) async {
    try {
      final response = await _dio.get(
        '/v1/driver/orders/mine',
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data;
        return list.map((json) => DriverOrderMineDto.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching my driver orders: $e');
    }
    return null;
  }

  // Driver accepts/receives an order
  static Future<bool> receiveOrder(String orderId) async {
    try {
      final response = await _dio.post('/v1/driver/orders/$orderId/receive');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error receiving order: $e');
      return false;
    }
  }

  // Mark order as shipped / on the way
  static Future<bool> shipOrder(String orderId) async {
    try {
      final response = await _dio.post('/v1/driver/orders/$orderId/ship');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error shipping order: $e');
      return false;
    }
  }

  // Mark order as delivered
  static Future<bool> deliverOrder(String orderId) async {
    try {
      final response = await _dio.post('/v1/driver/orders/$orderId/deliver');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error delivering order: $e');
      return false;
    }
  }
}
