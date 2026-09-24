import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/driver folder/driver_orders_controller.dart';
import 'package:rburger/services/driver_orders_service/driver_order_dto.dart';

class NewOrderCard extends StatefulWidget {
  final DriverNewOrderDto order;

  const NewOrderCard({super.key, required this.order});

  @override
  State<NewOrderCard> createState() => _NewOrderCardState();
}

class _NewOrderCardState extends State<NewOrderCard> {
  bool _isLoading = false;

  Future<void> _handleReceiveOrder() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final success = await DriverOrdersController.instance.receiveOrder(
        widget.order.orderId,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم استلام الطلب بنجاح')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
                'طلب #${widget.order.orderNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink900,
                ),
              ),
              Text(
                '${widget.order.total} EGP',
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
              const Icon(Icons.location_on, size: 16, color: AppColors.ink600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.order.customerAddress ?? 'عنوان غير متوفر',
                  style: const TextStyle(fontSize: 14, color: AppColors.ink600),
                ),
              ),
            ],
          ),
          if (widget.order.customerPhone != null &&
              widget.order.customerPhone!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: AppColors.green600),
                const SizedBox(width: 6),
                Text(
                  widget.order.customerPhone!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink900,
                  ),
                ),
              ],
            ),
          ],
          if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'ملاحظات: ${widget.order.notes}',
              style: const TextStyle(fontSize: 13, color: AppColors.maroon800),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleReceiveOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon950,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'استلام الطلب',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
