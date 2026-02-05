import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:provider/provider.dart';

class PendingOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(String orderId, String orderNumber) onAcceptOrder;

  const PendingOrderCard({
    super.key,
    required this.order,
    required this.onAcceptOrder,
  });

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.read<OrdersProvider>();
    
    final orderId = order['order_number'] ?? '#${order['order_id']?.toString().substring(0, 8)}';
    final pickupAddress = ordersProvider.getPickupAddress(order);
    final amount = ordersProvider.formatOrderAmount(order['total_amount'] ?? 0);
    final distance = ordersProvider.calculateDistance(order);
    final timePosted = ordersProvider.getTimeAgo(order['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          orderId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          amount,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pickupAddress,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$distance • $timePosted',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => onAcceptOrder(order['order_id'], orderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}