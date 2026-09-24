import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/models/order.dart';
import 'package:rburger/services/orders/order_confirmation.dart';
import 'package:rburger/services/orders/orders_model.dart';
import 'package:rburger/services/signalR_service/signalr_service.dart';
import 'package:rburger/widgets/bottom_nav.dart';
import 'package:rburger/widgets/footer.dart';
import 'package:rburger/widgets/order_card.dart';
import 'package:rburger/widgets/order_tracking_dialog.dart';
import 'package:rburger/widgets/top_bar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Timer? _pollTimer; // NEW

  @override
  void initState() {
    super.initState();
    OrdersController.instance.startLiveUpdates(); // NEW
    OrdersController.instance.fetchOrders();
    _pollTimer = Timer.periodic(
      // NEW
      const Duration(seconds: 5),
      (_) => OrdersController.instance.fetchOrders(),
    );
  }

  @override
  void dispose() {
    // NEW
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: OrdersController.instance,
      builder: (context, _) {
        final controller = OrdersController.instance;
        final orders = controller.orders;
        final isLoading = controller.isLoading;

        return Scaffold(
          backgroundColor: AppColors.cream50,
          bottomNavigationBar: const BottomNav(),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const ColoredBox(color: AppColors.maroon950, child: TopBar()),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => OrdersController.instance.fetchOrders(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'orders.my_orders'.tr(),
                                  style: GoogleFonts.lalezar(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.maroon800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'orders.all_your_past_orders_and_you_can_track_any_order_still_on_the_way'
                                      .tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.ink600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading && orders.isEmpty)
                          const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.maroon800,
                              ),
                            ),
                          )
                        else if (orders.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            sliver: SliverList.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final summaryItem = orders[index];
                                final isReceived =
                                    summaryItem.customerReceivedAt != null;
                                final stageText = summaryItem.stage
                                    .toString()
                                    .toLowerCase()
                                    .trim();

                                OrderStatus mappedStatus =
                                    OrderStatus.confirmed;
                                if (stageText == '1' ||
                                    stageText.contains('prepar')) {
                                  mappedStatus = OrderStatus.preparing;
                                } else if (stageText == '2' ||
                                    stageText.contains('ontheway') ||
                                    stageText.contains('way')) {
                                  mappedStatus = OrderStatus.onTheWay;
                                } else if (stageText == '3' ||
                                    stageText.contains('deliver')) {
                                  mappedStatus = OrderStatus.delivered;
                                }
                                if (isReceived) {
                                  mappedStatus = OrderStatus.delivered;
                                }

                                final legacyOrder = Order(
                                  id: '#${summaryItem.orderNumber}',
                                  amount: summaryItem.total.toInt(),
                                  status: mappedStatus,
                                  etaLabel: '25–35 min',
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: OrderCard(
                                    order: legacyOrder,
                                    onTrackOrder: () {
                                      showOrderTrackingDialog(
                                        context,
                                        summaryItem,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            children: [
                              if (!isLoading && orders.isEmpty)
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 32,
                                      ),
                                      child: Text(
                                        'orders.you_haven_t_placed_any_orders_yet_once_you_order_you_ll_find_all_the_details_her'
                                            .tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.ink600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                              const Footer(),
                            ],
                          ),
                        ),
                      ],
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

class OrdersController extends ChangeNotifier {
  OrdersController._();
  static final OrdersController instance = OrdersController._();

  List<OrderSummaryItem> _orders = [];
  List<OrderSummaryItem> get orders => List.unmodifiable(_orders);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int _requestId = 0; // NEW
  bool _listening = false; // NEW
  void startLiveUpdates() {
    if (!_listening) {
      _listening = true;
      SignalRService.instance.addListener((_) => fetchOrders());
    }
    SignalRService.instance.connect(); // safe to call repeatedly
  }

  Future<void> fetchOrders() async {
    final id = ++_requestId; // NEW

    _isLoading = true;
    notifyListeners();

    try {
      final response = await OrderConfirmationService.getUserOrders();
      if (id != _requestId) return; // NEW: a newer request superseded this one

      if (response != null) {
        _orders = response.items;
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
