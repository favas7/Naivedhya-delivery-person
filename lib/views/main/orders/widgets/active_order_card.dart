import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'address_row_widget.dart';
import 'order_stat_widget.dart';

class ActiveOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(String phoneNumber) onCallCustomer;
  final Function(Map<String, dynamic> order) onNavigateToMap;
  final Function(String orderId, String status) onUpdateOrderStatus;
  final Function(BuildContext context, String orderId, String orderNumber) onShowDeliveryConfirmation;

  const ActiveOrderCard({
    super.key,
    required this.order,
    required this.onCallCustomer,
    required this.onNavigateToMap,
    required this.onUpdateOrderStatus,
    required this.onShowDeliveryConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.read<OrdersProvider>();
    
    final orderId = order['order_number'] ?? '#${order['order_id']?.toString().substring(0, 8)}';
    final customerName = order['customer_name'] ?? 'Unknown Customer';
    final customerPhone = ordersProvider.getCustomerPhone(order);
    final pickupAddress = ordersProvider.getPickupAddress(order);
    final deliveryAddress = ordersProvider.getDeliveryAddress(order);
    final amount = ordersProvider.formatOrderAmount(order['total_amount'] ?? 0);
    final distance = ordersProvider.calculateDistance(order);
    final estimatedTime = ordersProvider.calculateEstimatedTime(order);
    final deliveryStatus = order['delivery_status'] ?? 'Assigned';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ordersProvider.getOrderStatusDisplay(order),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Customer info
                Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (customerPhone != 'N/A')
                      InkWell(
                        onTap: () => onCallCustomer(customerPhone),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: AppColors.success,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Pickup location
                AddressRowWidget(
                  icon: Icons.restaurant,
                  iconColor: AppColors.accent,
                  title: 'Pickup',
                  address: pickupAddress,
                ),
                
                const SizedBox(height: 12),
                
                // Delivery location
                AddressRowWidget(
                  icon: Icons.location_on,
                  iconColor: AppColors.primary,
                  title: 'Delivery',
                  address: deliveryAddress,
                ),
                
                const SizedBox(height: 16),
                
                // Order stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OrderStatWidget(
                      title: 'Distance',
                      value: distance,
                      icon: Icons.straighten,
                    ),
                    OrderStatWidget(
                      title: 'Time',
                      value: estimatedTime,
                      icon: Icons.access_time,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                _buildActionButtons(context, deliveryStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String deliveryStatus) {
    final _ = context.read<AuthProvider>();
    
    switch (deliveryStatus) {
      case 'Assigned':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onNavigateToMap(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Navigate'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onUpdateOrderStatus(order['order_id'], 'Picked Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Mark Picked Up'),
              ),
            ),
          ],
        );
      
      case 'Picked Up':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onNavigateToMap(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Navigate'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onUpdateOrderStatus(order['order_id'], 'In Transit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Start Delivery'),
              ),
            ),
          ],
        );
      
      case 'In Transit':
        final orderNumber = order['order_number'] ?? '#${order['order_id']?.toString().substring(0, 8)}';
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onNavigateToMap(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Navigate'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onShowDeliveryConfirmation(
                  context,
                  order['order_id'],
                  orderNumber,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Mark Delivered'),
              ),
            ),
          ],
        );
      
      default:
        return const SizedBox.shrink();
    }
  }
}