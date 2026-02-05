import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'active_order_card.dart';
import 'empty_state_widget.dart';
import 'error_widget.dart' as custom;

class ActiveOrdersTab extends StatelessWidget {
  final VoidCallback onRefresh;
  final Function(String phoneNumber) onCallCustomer;
  final Function(Map<String, dynamic> order) onNavigateToMap;
  final Function(String orderId, String status) onUpdateOrderStatus;
  final Function(BuildContext context, String orderId, String orderNumber) onShowDeliveryConfirmation;

  const ActiveOrdersTab({
    super.key,
    required this.onRefresh,
    required this.onCallCustomer,
    required this.onNavigateToMap,
    required this.onUpdateOrderStatus,
    required this.onShowDeliveryConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoadingActive) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersProvider.activeOrdersError != null) {
          return custom.ErrorWidget(
            errorMessage: ordersProvider.activeOrdersError!,
            onRetry: onRefresh,
          );
        }

        if (ordersProvider.activeOrders.isEmpty) {
          return const EmptyStateWidget(message: 'No active orders');
        }

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.activeOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.activeOrders[index];
              return ActiveOrderCard(
                order: order,
                onCallCustomer: onCallCustomer,
                onNavigateToMap: onNavigateToMap,
                onUpdateOrderStatus: onUpdateOrderStatus,
                onShowDeliveryConfirmation: onShowDeliveryConfirmation,
              );
            },
          ),
        );
      },
    );
  }
}