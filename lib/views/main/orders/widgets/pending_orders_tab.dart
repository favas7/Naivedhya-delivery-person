import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'pending_order_card.dart';
import 'empty_state_widget.dart';
import 'error_widget.dart' as custom;

class PendingOrdersTab extends StatelessWidget {
  final VoidCallback onRefresh;
  final Function(String orderId, String orderNumber) onAcceptOrder;

  const PendingOrdersTab({
    super.key,
    required this.onRefresh,
    required this.onAcceptOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoadingPending) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersProvider.pendingOrdersError != null) {
          return custom.ErrorWidget(
            errorMessage: ordersProvider.pendingOrdersError!,
            onRetry: onRefresh,
          );
        }

        if (ordersProvider.pendingOrders.isEmpty) {
          return const EmptyStateWidget(message: 'No pending orders');
        }

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.pendingOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.pendingOrders[index];
              return PendingOrderCard(
                order: order,
                onAcceptOrder: onAcceptOrder,
              );
            },
          ),
        );
      },
    );
  }
}