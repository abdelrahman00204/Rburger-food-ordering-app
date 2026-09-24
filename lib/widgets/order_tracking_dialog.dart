import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'package:rburger/services/orders/order_confirmation.dart';
import 'package:rburger/services/orders/orders_model.dart';
import 'package:rburger/services/signalR_service/signalr_service.dart';
import 'package:rburger/widgets/order_rating_dialog.dart';
import 'dart:async'; // NEW

Future<void> showOrderTrackingDialog(
  BuildContext context,
  OrderSummaryItem order,
) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => OrderTrackingDialog(
      orderId: order.orderId,
      orderNumber: order.orderNumber,
      initialOrder: order,
    ),
  );
}

class OrderTrackingDialog extends StatefulWidget {
  final String orderId;
  final int orderNumber;
  final OrderSummaryItem initialOrder;

  const OrderTrackingDialog({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.initialOrder,
  });

  @override
  State<OrderTrackingDialog> createState() => _OrderTrackingDialogState();
}

class _OrderTrackingDialogState extends State<OrderTrackingDialog> {
  late OrderSummaryItem _currentOrder;
  bool _isLoading = false;
  Timer? _pollTimer; // NEW

  @override
  @override
  void initState() {
    super.initState();
    _currentOrder = widget.initialOrder;
    SignalRService.instance.addListener(_onOrderUpdated); // CHANGED
    SignalRService.instance.connect(); // CHANGED
    _pollTimer = Timer.periodic(
      // NEW
      const Duration(seconds: 5),
      (_) => _fetchLatestOrderDetails(),
    );
  }

  void _onOrderUpdated(List<Object?>? _) => _fetchLatestOrderDetails();
  @override
  void dispose() {
    SignalRService.instance.removeListener(_onOrderUpdated);
    _pollTimer?.cancel(); // NEW

    super.dispose();
  }

  Future<void> _fetchLatestOrderDetails() async {
    try {
      final response = await OrderConfirmationService.getUserOrders(
        page: 0,
        pageSize: 20,
      );
      if (response != null && mounted) {
        final found = response.items.firstWhere(
          (o) => o.orderId == widget.orderId,
          orElse: () => _currentOrder,
        );
        setState(() {
          _currentOrder = found;
        });
      }
    } catch (e) {
      debugPrint('Error fetching tracking order: $e');
    }
  }

  final customerId = AuthController.instance.customerId;
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.maroon800),
              SizedBox(height: 16),
              Text('tracking.loading_order_status'.tr()),
            ],
          ),
        ),
      );
    }

    final order = _currentOrder;
    final isReceived = order.customerReceivedAt != null;
    final rawStage = order.stage;
    final stageText = rawStage.toString().toLowerCase().trim();

    int stageIndex = 0;
    if (stageText == '1' || stageText.contains('prepar')) {
      stageIndex = 1;
    } else if (stageText == '2' ||
        stageText.contains('ontheway') ||
        stageText.contains('on the way') ||
        stageText.contains('way')) {
      stageIndex = 2;
    } else if (stageText == '3' || stageText.contains('deliver')) {
      stageIndex = 3;
    } else {
      stageIndex = 0; // '0' or contains('confirm')
    }

    String displayStage = 'orders.confirmed'.tr();
    if (stageIndex == 1) {
      displayStage = 'orders.preparing'.tr();
    } else if (stageIndex == 2) {
      displayStage = 'orders.on_the_way'.tr();
    } else if (stageIndex == 3) {
      displayStage = 'orders.delivered'.tr();
    }

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'tracking.order_number'.tr(
                    namedArgs: {'orderNumber': widget.orderNumber.toString()},
                  ),
                  style: GoogleFonts.lalezar(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: AppColors.maroon700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            OrderTrackingStepper(
              completedCount: isReceived ? 4 : stageIndex,
              activeIndex: isReceived ? -1 : stageIndex,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                isReceived
                    ? 'tracking.order_completed_confirmed'.tr()
                    : 'tracking.current_stage_param'.tr(
                        namedArgs: {'stage': displayStage},
                      ),
                style: const TextStyle(fontSize: 16, color: AppColors.ink600),
              ),
            ),
            if (!isReceived && stageIndex == 3) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    final success =
                        await OrderConfirmationService.confirmOrderReceived(
                          orderId: widget.orderId,
                          customerReceivedAt: DateTime.now().toIso8601String(),
                        );
                    if (success && mounted) {
                      Navigator.of(context).pop();
                      showOrderRatingDialog(
                        context,
                        widget.orderId,
                        customerId!,
                      );
                    } else if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'tracking.i_received_my_order'.tr(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OrderTrackingStepper extends StatelessWidget {
  static const List<String> stageLabels = [
    'orders.confirmed',
    'orders.preparing',
    'orders.on_the_way',
    'orders.delivered',
  ];

  final int completedCount;
  final int activeIndex;

  const OrderTrackingStepper({
    super.key,
    required this.completedCount,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < stageLabels.length; i++)
          _buildStep(stepIndex: i, label: stageLabels[i].tr()),
      ],
    );
  }

  Widget _buildStep({required int stepIndex, required String label}) {
    final isDone = stepIndex < completedCount;
    final isActive = stepIndex == activeIndex;
    final isReached = isDone || isActive;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isReached ? AppColors.green600 : const Color(0xFFEFE1C9),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 24)
              : Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.ink600,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.maroon800,
          ),
        ),
      ],
    );
  }
}
