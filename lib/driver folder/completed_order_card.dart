import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/services/driver_orders_service/driver_order_dto.dart';

class CompletedOrderCard extends StatelessWidget {
  final DriverOrderMineDto order;

  const CompletedOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب #${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink900,
                ),
              ),
              Text(
                '${order.total} EGP',
                style: GoogleFonts.lalezar(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.maroon800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle, size: 16, color: AppColors.green600),
              const SizedBox(width: 6),
              const Text(
                'مكتمل وتم تسليمه بنجاح',
                style: TextStyle(fontSize: 14, color: AppColors.green600, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}