import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/services/orders/orders_model.dart';

class OrderSummaryTile extends StatelessWidget {
  final OrderSummaryItem order;

  const OrderSummaryTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final stageText = order.stage.toString().toLowerCase().trim();

    String statusLabel = 'orders.confirmed'.tr();

    if (stageText == '1' || stageText.contains('prepar')) {
      statusLabel = 'orders.preparing'.tr();
    } else if (stageText == '2' ||
        stageText.contains('ontheway') ||
        stageText.contains('way')) {
      statusLabel = 'orders.on_the_way'.tr();
    } else if (stageText == '3' || stageText.contains('deliver')) {
      statusLabel = 'orders.delivered'.tr();
    }

    if (order.customerReceivedAt != null) {
      statusLabel = 'orders.received'.tr();
    }

    final statusText = '${'orders.stage'.tr()}: $statusLabel';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'orders.order_card'.tr(
                    namedArgs: {'orderId': order.orderNumber.toString()},
                  ),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: const TextStyle(fontSize: 14, color: AppColors.ink600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'orders.amount_egp'.tr(
              namedArgs: {'amount': order.total.toStringAsFixed(2)},
            ),
            textAlign: TextAlign.end,
            style: GoogleFonts.lalezar(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: AppColors.maroon800,
            ),
          ),
        ],
      ),
    );
  }
}
