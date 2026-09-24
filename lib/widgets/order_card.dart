import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTrackOrder;

  const OrderCard({super.key, required this.order, this.onTrackOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cream50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'orders.order_card'.tr(namedArgs: {'orderId': order.id}),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink900,
                ),
              ),
              Text(
                'orders.amount_egp'.tr(
                  namedArgs: {'amount': '${order.amount}'},
                ),
                style: GoogleFonts.lalezar(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OrderStatusBadge(status: order.status),
              OutlinedButton(
                onPressed: onTrackOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.maroon800,
                  side: const BorderSide(color: AppColors.maroon800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('orders.track_order'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
