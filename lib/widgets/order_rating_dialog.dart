import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/login%20folder/primary_button.dart';
import 'package:rburger/services/orders/order_confirmation.dart';

Future<void> showOrderRatingDialog(
  BuildContext context,
  String orderId,
  String customerId,
) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (_) => OrderRatingDialog(orderId: orderId, customerId: customerId),
  );
}

class OrderRatingDialog extends StatefulWidget {
  final String orderId;
  final String customerId;

  const OrderRatingDialog({
    super.key,
    required this.orderId,
    required this.customerId,
  });

  @override
  State<OrderRatingDialog> createState() => _OrderRatingDialogState();
}

class _OrderRatingDialogState extends State<OrderRatingDialog> {
  int _rating = 0;
  bool _isSubmitting = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('reviews.please_select_a_star_rating'.tr())),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await OrderConfirmationService.submitOrderReview(
      orderId: widget.orderId,
      rating: _rating,
      comment: _commentController.text,
      customerId: widget.customerId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('reviews.thanks_for_your_review'.tr())),
      );
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('reviews.failed_to_submit_review_try_again'.tr()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'reviews.rate_your_order'.tr(),
              style: GoogleFonts.lalezar(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.maroon800,
              ),
            ),
            const SizedBox(height: 24),
            StarRating(
              rating: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'reviews.anything_you_want_to_say_about_the_order_optional'
                        .tr(),
                hintStyle: const TextStyle(
                  color: AppColors.ink600,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold500),
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: _isSubmitting
                  ? 'reviews.submitting'.tr()
                  : 'reviews.submit_review'.tr(),
              onPressed: _isSubmitting ? null : () => _submit(),
            ),
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final int rating; // 0-5
  final ValueChanged<int> onChanged;

  const StarRating({super.key, required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.star,
                size: 40,
                color: i <= rating ? AppColors.gold500 : Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}
