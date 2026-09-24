import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';

class CartSummary extends StatelessWidget {
  final int subtotal;
  final int deliveryFee;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
  });

  int get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('cart.subtotal'.tr(), subtotal),
        const SizedBox(height: 6),
        _row('cart.delivery_fee'.tr(), deliveryFee),
        const SizedBox(height: 14),
        _row('common.total'.tr(), total, isTotal: true),
      ],
    );
  }

  Widget _row(String label, int amount, {bool isTotal = false}) {
    final style = GoogleFonts.lalezar(
      fontSize: isTotal ? 22 : 17,
      fontWeight: isTotal ? FontWeight.w900 : FontWeight.w400,
      color: isTotal ? AppColors.maroon800 : AppColors.ink900,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('$amount EGP', style: style),
      ],
    );
  }
}