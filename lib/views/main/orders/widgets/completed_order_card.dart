import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:provider/provider.dart';

class CompletedOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onNavigateToMap;  // Add this

  const CompletedOrderCard({
    super.key,
    required this.order,
    this.onNavigateToMap,  // Add this
  });

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.read<OrdersProvider>();
    
    final orderId = order['order_number'] ?? '#${order['order_id']?.toString().substring(0, 8)}';
    final customerName = order['customer_name'] ?? 'Unknown Customer';
    final amount = ordersProvider.formatOrderAmount(order['total_amount'] ?? 0);
    final deliveredTime = ordersProvider.getTimeAgo(order['delivery_time']);
    final rating = ordersProvider.getOrderRating(order);
    
    // Get delivery address
    final addressData = order['addresses'];
    String deliveryAddress = 'Address not available';
    bool hasCoordinates = false;

    if (addressData != null && addressData is Map<String, dynamic>) {
      final fullAddress = addressData['fulladdress'] as String?;
      final label = addressData['label'] as String?;
      
      if (fullAddress != null && fullAddress.isNotEmpty) {
        deliveryAddress = label != null && label.isNotEmpty 
              ? '$label - $fullAddress' 
            : fullAddress;
      }
      
      // Check if coordinates exist
      hasCoordinates = addressData['latitude'] != null && addressData['longitude'] != null;
    }
    
    // Calculate delivery duration if both created_at and delivery_time are available
    String? deliveryDuration;
    if (order['created_at'] != null && order['delivery_time'] != null) {
      try {
        final createdAt = DateTime.parse(order['created_at']);
        final deliveredAt = DateTime.parse(order['delivery_time']);
        final duration = deliveredAt.difference(createdAt);
        
        if (duration.inHours > 0) {
          deliveryDuration = '${duration.inHours}h ${duration.inMinutes % 60}m';
        } else {
          deliveryDuration = '${duration.inMinutes}m';
        }
      } catch (e) {
        deliveryDuration = null;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
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
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          amount,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          
          
          const SizedBox(height: 12),
          
          // Delivery Location
          _buildDetailRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: 'Delivery',
            value: deliveryAddress,
            maxLines: 2,
          ),
          
          // Navigate Button
          if (hasCoordinates && onNavigateToMap != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onNavigateToMap,
                icon: const Icon(Icons.navigation, size: 16),
                label: const Text('Navigate to Delivery Location'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          
          // Bottom Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Delivered time
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Delivered $deliveredTime',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Duration if available
              if (deliveryDuration != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deliveryDuration,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Rating
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}