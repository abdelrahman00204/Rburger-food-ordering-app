import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_paymob_sdk/flutter_paymob_sdk.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/login folder/primary_button.dart';
import 'package:rburger/screens/cart_screen.dart';
import 'package:rburger/services/orders/making_order.dart';
import 'package:rburger/services/orders/orders_model.dart';
import 'package:rburger/services/payment_service.dart';
import 'package:rburger/widgets/labled_form_field.dart';
import 'package:rburger/widgets/payment_method_toggle.dart';
import 'package:rburger/services/login_service/auth_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rburger/cubit/branch_selector_cubit.dart';
import 'package:rburger/services/data/branch_data.dart';

Future<void> showCheckoutDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const CheckoutDialog(),
  );
}

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  static final String _publicKey = dotenv.get('PAYMOB_PUBLIC_KEY');

  @override
  void initState() {
    _nameController.text = AuthController.instance.name;
    _mobileController.text = AuthController.instance.mobile;
    _addressController.text = AuthController.instance.address;
    super.initState();
  }

  final _paymentOptions = [
    PaymentOption(id: 'cash', label: 'payment.cash_on_delivery'.tr()),
    PaymentOption(id: 'card', label: 'payment.card_payment'.tr()),
  ];
  String _selectedPayment = 'cash';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'payment.field_required'.tr(namedArgs: {'fieldName': fieldName});
    }
    return null;
  }

  double get _amountToPay {
    final branchState = context.read<BranchSelectorCubit>().state;
    final selectedBranch = branches.firstWhere(
      (b) =>
          b.nameEn == branchState.selectedBranch ||
          b.nameAr == branchState.selectedBranch,
      orElse: () => branches.isNotEmpty
          ? branches.first
          : BranchData(
              id: 0,
              nameAr: '',
              nameEn: '',
              deliveryFee: 0,
              etaMinMinutes: 0,
              etaMaxMinutes: 0,
              estimatedDeliveryTime: '',
              hotlinePhones: '',
            ),
    );

    return CartController.instance.subtotal.toDouble() +
        selectedBranch.deliveryFee;
  }

  Future<void> _confirmOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = AuthController.instance;
      final branchId = await auth.getSavedBranchId();

      final orderItems = CartController.instance.items.map((cartItem) {
        return OrderItemPayload(
          menuItemId: int.tryParse(cartItem.id) ?? 0,
          quantity: cartItem.quantity,
          customName: LocalizedText(ar: cartItem.name, en: cartItem.name),
          customDescription: LocalizedText(
            ar: cartItem.description,
            en: cartItem.description,
          ),
          unitPrice: cartItem.unitPrice.toDouble(),
        );
      }).toList();
      final request = CreateOrderRequest(
        branchId: branchId,
        items: orderItems,
        customerName: _nameController.text.trim(),
        customerPhone: _mobileController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        notes: _notesController.text.trim(),
        paymentMethod: _selectedPayment,
        customerId: auth.customerId ?? '',
        idempotencyKey: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      final response = await MakeOrderService.createOrder(request);

      if (!mounted) return;

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'payment.failed_to_create_order_please_try_again'.tr(),
            ),
          ),
        );
        return;
      }

      if (_selectedPayment == 'cash') {
        CartController.instance.clear();
        Navigator.of(context).pop();
        showOrderConfirmationDialog(context, response);
        return;
      }

      final intent = await PaymentService.createIntent(
        response.orderId,
        idempotencyKey: response.orderId,
      );

      if (!mounted) return;

      if (intent == null || intent.clientSecret.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'payment.could_not_start_payment_please_try_again'.tr(),
            ),
          ),
        );
        return;
      }

      final paymentResult = await PaymobService().payWithPaymob(
        publicKey: _publicKey,
        clientSecret: intent.clientSecret,
        customization: PaymobCustomization(
          appName: 'Republic',
          buttonBackgroundColor: AppColors.maroon800,
          buttonTextColor: Colors.white,
        ),
      );

      if (!mounted) return;
      debugPrint('========== PAYMOB RESULT ==========');
      debugPrint('Payment status: ${paymentResult.status}');
      debugPrint('Payment successful: ${paymentResult.isSuccessful}');
      debugPrint('Payment failure: ${paymentResult.isFailure}');
      debugPrint('Payment error: ${paymentResult.errorMessage}');
      debugPrint('====================================');

      if (paymentResult.isSuccessful ||
          paymentResult.status == PaymentStatus.cancelled ||
          paymentResult.status == PaymentStatus.pending) {
        bool confirmed = false;

        for (var attempt = 0; attempt < 10; attempt++) {
          final status = await PaymentService.checkOrderPaymentStatus(
            response.orderId,
          );

          debugPrint(
            'Payment backend status - attempt ${attempt + 1}: $status',
          );

          if (status?.toLowerCase() == 'captured') {
            confirmed = true;
            break;
          }

          await Future.delayed(const Duration(seconds: 2));
        }

        if (!mounted) return;

        if (confirmed) {
          CartController.instance.clear();
          Navigator.of(context).pop();
          showOrderConfirmationDialog(context, response);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'payment.payment_received_we_ll_confirm_your_order_shortly'
                    .tr(),
              ),
            ),
          );
        }
      } else if (paymentResult.isFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('payment.payment_failed_please_try_again'.tr()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('payment.payment_is_pending_confirmation'.tr()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('payment.error_param'.tr(namedArgs: {'error': '$e'})),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountToPay = _amountToPay;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'payment.checkout'.tr(),
                    style: GoogleFonts.lalezar(
                      fontSize: 26,
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
              LabeledFormField(
                label: 'payment.name'.tr(),
                controller: _nameController,
                validator: (v) => _required(v, 'payment.name'.tr()),
              ),
              const SizedBox(height: 18),
              LabeledFormField(
                label: 'payment.mobile_number'.tr(),
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: (v) => _required(v, 'payment.mobile_number'.tr()),
              ),
              const SizedBox(height: 18),
              LabeledFormField(
                label: 'payment.delivery_address'.tr(),
                controller: _addressController,
                validator: (v) => _required(v, 'payment.delivery_address'.tr()),
              ),
              const SizedBox(height: 18),
              LabeledFormField(
                label: 'payment.order_notes_optional'.tr(),
                controller: _notesController,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              Text(
                'payment.payment_method'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.ink900,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              PaymentMethodToggle(
                options: _paymentOptions,
                selectedId: _selectedPayment,
                onChanged: (id) => setState(() => _selectedPayment = id),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.line),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'payment.amount_to_pay'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink900,
                    ),
                  ),
                  Text(
                    'payment.amounttopay_egp'.tr(
                      namedArgs: {'amountToPay': '$amountToPay'},
                    ),
                    style: GoogleFonts.lalezar(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: AppColors.maroon800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      label: 'payment.confirm_order'.tr(),
                      onPressed: _confirmOrder,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void showOrderConfirmationDialog(
    BuildContext context,
    OrderCreatedResponse order,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 80,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(top: 4, right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.green600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'payment.your_order_has_been_received'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green600,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'payment.order_no'.tr(),
                  style: TextStyle(fontSize: 15, color: AppColors.ink600),
                ),
                const SizedBox(height: 6),
                Text(
                  '#${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.maroon800,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'payment.total_amount'.tr(),
                  style: TextStyle(fontSize: 15, color: AppColors.ink600),
                ),
                const SizedBox(height: 6),
                Text(
                  '${order.total} EGP',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold500,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/orders');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon950,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'payment.ok_thanks'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
