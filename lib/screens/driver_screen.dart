import 'package:flutter/material.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/driver folder/driver_header.dart';
import 'package:rburger/driver folder/driver_order_tab.dart';
import 'package:rburger/driver folder/driver_order_tabs.dart';
import 'package:rburger/driver folder/driver_orders_controller.dart';
import 'package:rburger/driver folder/driver_stat_card.dart';
import 'package:rburger/driver folder/new_order_card.dart';
import 'package:rburger/driver folder/ongoing_order_card.dart';
import 'package:rburger/driver folder/completed_order_card.dart';
import 'package:rburger/services/driver_orders_service/driver_order_dto.dart';

class DriverScreen extends StatefulWidget {
  final String driverName;
  final VoidCallback onLogout;

  const DriverScreen({
    super.key,
    required this.driverName,
    required this.onLogout,
  });

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  DriverOrderTab _selectedTab = DriverOrderTab.newOrders;

  @override
  void initState() {
    super.initState();
    DriverOrdersController.instance.fetchAllOrders();
  }

  String get _emptyMessageForSelectedTab {
    switch (_selectedTab) {
      case DriverOrderTab.newOrders:
        return 'مفيش طلبات جديدة دلوقتي, تابع من هنا اول ما يوصلك طلب.';
      case DriverOrderTab.ongoing:
        return 'مفيش طلبات جارية دلوقتي.';
      case DriverOrderTab.completed:
        return 'لسه معملتش أي طلب النهاردة.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DriverOrdersController.instance,
      builder: (context, _) {
        final controller = DriverOrdersController.instance;

        List itemsToDisplay = [];
        if (_selectedTab == DriverOrderTab.newOrders) {
          itemsToDisplay = controller.newOrders;
        } else if (_selectedTab == DriverOrderTab.ongoing) {
          itemsToDisplay = controller.ongoingOrders;
        } else {
          itemsToDisplay = controller.completedToday;
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.cream50,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchAllOrders(),
                color: AppColors.maroon800,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DriverHeader(
                            driverName: widget.driverName,
                            onLogout: widget.onLogout,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DriverStatCard(
                                    count: controller.newOrders.length,
                                    label: 'طلبات جديدة',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DriverStatCard(
                                    count: controller.ongoingOrders.length,
                                    label: 'طلبات جارية',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DriverStatCard(
                                    count: controller.completedToday.length,
                                    label: 'مكتملة اليوم',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                            child: DriverOrderTabs(
                              selected: _selectedTab,
                              onChanged: (tab) => setState(() => _selectedTab = tab),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.isLoading && itemsToDisplay.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.maroon800),
                        ),
                      )
                    else if (itemsToDisplay.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList.builder(
                          itemCount: itemsToDisplay.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCardForTab(itemsToDisplay[index]),
                            );
                          },
                        ),
                      )
                    else
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 28),
                            child: Text(
                              _emptyMessageForSelectedTab,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.ink600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardForTab(dynamic item) {
    if (_selectedTab == DriverOrderTab.newOrders) {
      return NewOrderCard(order: item as DriverNewOrderDto);
    } else if (_selectedTab == DriverOrderTab.ongoing) {
      return OngoingOrderCard(order: item as DriverOrderMineDto);
    } else {
      return CompletedOrderCard(order: item as DriverOrderMineDto);
    }
  }
}