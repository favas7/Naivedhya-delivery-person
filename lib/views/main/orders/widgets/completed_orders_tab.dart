import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'completed_order_card.dart';
import 'empty_state_widget.dart';
import 'error_widget.dart' as custom;

class CompletedOrdersTab extends StatelessWidget {
  final VoidCallback onRefresh;
  final Function(Map<String, dynamic>)? onNavigateToMap;  // Add this

  const CompletedOrdersTab({
    super.key,
    required this.onRefresh,
    this.onNavigateToMap,  // Add this
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoadingCompleted) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersProvider.completedOrdersError != null) {
          return custom.ErrorWidget(
            errorMessage: ordersProvider.completedOrdersError!,
            onRetry: onRefresh,
          );
        }

        if (ordersProvider.completedOrders.isEmpty) {
          return const EmptyStateWidget(message: 'No completed orders');
        }

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.completedOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.completedOrders[index];
              return CompletedOrderCard(
                order: order,
                onNavigateToMap: onNavigateToMap != null 
                    ? () => onNavigateToMap!(order)  // Pass callback
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}