import 'package:flutter/material.dart';
import 'package:rburger/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

enum OrderStatus {
  confirmed,
  preparing,
  onTheWay,
  arrived,
  delivered,
  cancelled,
}

extension OrderStatusDisplay on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.confirmed:
        return 'orders.confirmed'.tr();
      case OrderStatus.preparing:
        return 'orders.preparing'.tr();
      case OrderStatus.onTheWay:
        return 'orders.on_the_way'.tr();
      case OrderStatus.arrived:
        return 'orders.arrived'.tr();
      case OrderStatus.delivered:
        return 'orders.delivered'.tr();
      case OrderStatus.cancelled:
        return 'orders.cancelled'.tr();
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.confirmed:
        return const Color(0xFF8A6FB0);
      case OrderStatus.preparing:
        return AppColors.gold500;
      case OrderStatus.onTheWay:
        return const Color(0xFF2F6FEB);
      case OrderStatus.arrived:
        return const Color(0xFFDDA24C);
      case OrderStatus.delivered:
        return AppColors.green600;
      case OrderStatus.cancelled:
        return Colors.redAccent;
    }
  }

  /// Index (0-3) into the 4-step tracker: Confirmed, Preparing, On the
  /// way, Arrived. 'delivered' maps to the same final index as 'arrived'
  /// — the difference is whether that step shows a checkmark (delivered)
  /// or its step number (arrived, still awaiting customer confirmation).
  int? get trackerStageIndex {
    switch (this) {
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.onTheWay:
        return 2;
      case OrderStatus.arrived:
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return null;
    }
  }
}

class Order {
  final String id;
  final int amount;
  final OrderStatus status;
  final String etaLabel;

  const Order({
    required this.id,
    required this.amount,
    required this.status,
    required this.etaLabel,
  });
}
