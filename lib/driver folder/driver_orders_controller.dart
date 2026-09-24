import 'package:flutter/foundation.dart';
import 'package:rburger/services/driver_orders_service/driver_order_dto.dart';
import 'package:rburger/services/driver_orders_service/driver_orders_service.dart';

class DriverOrdersController extends ChangeNotifier {
  DriverOrdersController._();
  static final DriverOrdersController instance = DriverOrdersController._();

  List<DriverNewOrderDto> _newOrders = [];
  List<DriverOrderMineDto> _ongoingOrders = [];
  List<DriverOrderMineDto> _completedToday = [];
  bool _isLoading = false;

  List<DriverNewOrderDto> get newOrders => List.unmodifiable(_newOrders);
  List<DriverOrderMineDto> get ongoingOrders =>
      List.unmodifiable(_ongoingOrders);
  List<DriverOrderMineDto> get completedToday =>
      List.unmodifiable(_completedToday);
  bool get isLoading => _isLoading;

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newOrdersResult = await DriverOrdersService.getNewOrders();
      if (newOrdersResult != null) {
        _newOrders = newOrdersResult;
      }

      final activeOrdersResult = await DriverOrdersService.getMyOrders(
        status: 'active',
      );
      if (activeOrdersResult != null) {
        _ongoingOrders = activeOrdersResult;
      }

      final completedOrdersResult = await DriverOrdersService.getMyOrders(
        status: 'completed',
      );
      if (completedOrdersResult != null) {
        _completedToday = completedOrdersResult;
      }
      debugPrint(
        'active: ${_ongoingOrders.map((o) => "#${o.orderNumber}:${o.stage}").toList()} | '
        'completed: ${_completedToday.map((o) => "#${o.orderNumber}:${o.stage}").toList()}',
      );
    } catch (e) {
      debugPrint('Error fetching driver orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> receiveOrder(String orderId) async {
    final success = await DriverOrdersService.receiveOrder(orderId);
    if (success) {
      await fetchAllOrders();
    }
    return success;
  }

  Future<bool> shipOrder(String orderId) async {
    final success = await DriverOrdersService.shipOrder(orderId);
    if (success) {
      await fetchAllOrders();
    }
    return success;
  }

  Future<bool> deliverOrder(String orderId) async {
    final success = await DriverOrdersService.deliverOrder(orderId);
    if (success) {
      await fetchAllOrders();
    }
    return success;
  }
}
