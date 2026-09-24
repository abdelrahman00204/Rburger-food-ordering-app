import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/driver folder/driver_orders_controller.dart';
import 'package:rburger/services/driver_orders_service/driver_order_dto.dart';
import 'package:url_launcher/url_launcher.dart';

class OngoingOrderCard extends StatefulWidget {
  final DriverOrderMineDto order;

  const OngoingOrderCard({super.key, required this.order});

  @override
  State<OngoingOrderCard> createState() => _OngoingOrderCardState();
}

class _OngoingOrderCardState extends State<OngoingOrderCard> {
  bool _isLoading = false;

  Future<void> _handleAction(Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.order.stage;
    debugPrint('stage is $stage (order #${widget.order.orderNumber})');

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
            InkWell(
              onTap: () => _makePhoneCall(widget.order.customerPhone!),
              child: Row(
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
            ),
          ],

          const SizedBox(height: 16),
          if (stage == 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _handleAction(() => DriverOrdersController.instance
                        .receiveOrder(widget.order.orderId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon800,
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
            )
          else if (stage == 1)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _handleAction(() => DriverOrdersController.instance
                        .shipOrder(widget.order.orderId)),
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
                        'في الطريق',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            )
          else if (stage == 2)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _handleAction(() => DriverOrdersController.instance
                        .deliverOrder(widget.order.orderId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green600,
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
                        'تم الوصول',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            )
          else if (stage == 3)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'في انتظار تأكيد العميل استلام الطلب...',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.ink600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else if (stage == 4)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.green600.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 18, color: AppColors.green600),
                  SizedBox(width: 8),
                  Text(
                    'تم توصيل الطلب بنجاح',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.green600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

Future _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    // Handle the error (e.g., show a SnackBar)
    throw Exception('Could not launch $launchUri');
  }
}