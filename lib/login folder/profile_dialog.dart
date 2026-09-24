import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'package:rburger/services/orders/order_confirmation.dart';
import 'package:rburger/login folder/order_summary_tile.dart';
import 'package:rburger/services/orders/orders_model.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  OrderSummaryItem? _latestOrder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestOrder();
  }

  Future<void> _fetchLatestOrder() async {
    try {
      final response = await OrderConfirmationService.getUserOrders(
        page: 0,
        pageSize: 1,
      );
      if (response != null && response.items.isNotEmpty) {
        setState(() {
          _latestOrder = response.items.first;
        });
      }
    } catch (e) {
      debugPrint('Error fetching latest order in profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'login.my_account'.tr(),
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
            const SizedBox(height: 12),
            ProfileField(label: 'common.name'.tr(), value: auth.name),
            const SizedBox(height: 16),
            ProfileField(label: 'login.mobile_number'.tr(), value: auth.mobile),
            const SizedBox(height: 16),
            ProfileField(label: 'common.address'.tr(), value: auth.address),
            const SizedBox(height: 24),
            Text(
              'login.order_history'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.maroon700,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: AppColors.maroon800),
                ),
              )
            else if (_latestOrder != null)
              OrderSummaryTile(order: _latestOrder!)
            else
              Text(
                'login.no_orders_yet'.tr(),
                style: TextStyle(fontSize: 14, color: AppColors.ink600),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  AuthController.instance.logout();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.maroon800,
                  side: const BorderSide(
                    color: AppColors.maroon800,
                    width: 1.4,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'common.logout'.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.ink600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink900,
          ),
        ),
      ],
    );
  }
}
