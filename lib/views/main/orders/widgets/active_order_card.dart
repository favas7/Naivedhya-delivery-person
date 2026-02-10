import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'address_row_widget.dart';

class ActiveOrderCard extends StatefulWidget {
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
  State<ActiveOrderCard> createState() => _ActiveOrderCardState();
}

class _ActiveOrderCardState extends State<ActiveOrderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.read<OrdersProvider>();
    
    final orderId = widget.order['order_number'] ?? '#${widget.order['order_id']?.toString().substring(0, 8)}';
    final customerName = widget.order['customer_name'] ?? 'Unknown Customer';
    final customerPhone = ordersProvider.getCustomerPhone(widget.order);
    final deliveryAddress = ordersProvider.getDeliveryAddress(widget.order);
    final amount = ordersProvider.formatOrderAmount(widget.order['total_amount'] ?? 0);
    final deliveryStatus = widget.order['delivery_status'] ?? 'Assigned';
    
    // Get order items
    final orderItems = widget.order['order_items'] as List<dynamic>? ?? [];
    final totalItems = orderItems.length;
    
    // Check if coordinates exist
    final addressData = widget.order['addresses'];
    bool hasCoordinates = false;
    if (addressData != null && addressData is Map<String, dynamic>) {
      hasCoordinates = addressData['latitude'] != null && addressData['longitude'] != null;
    }

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
                        ordersProvider.getOrderStatusDisplay(widget.order),
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
                        onTap: () => widget.onCallCustomer(customerPhone),
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
                
                // Order Items Section
                if (totalItems > 0) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$totalItems ${totalItems == 1 ? 'Item' : 'Items'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Expandable Items List
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderItems.length > 4 ? 4 : orderItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = orderItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${item['quantity']}x',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'Unknown Item',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (item['category'] != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item['category'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${item['total'] ?? item['price'] * item['quantity']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (orderItems.length > 4) ...[
                      const SizedBox(height: 8),
                      Text(
                        '+${orderItems.length - 4} more ${orderItems.length - 4 == 1 ? 'item' : 'items'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                  
                  const SizedBox(height: 16),
                ],
                


                // Delivery location
                AddressRowWidget(
                  icon: Icons.location_on,
                  iconColor: AppColors.primary,
                  title: 'Delivery',
                  address: deliveryAddress,
                ),
                

                
                const SizedBox(height: 16),
                
                // Navigate Button (if coordinates available)
                if (hasCoordinates) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onNavigateToMap(widget.order),
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navigate to Delivery Location'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
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
        return ElevatedButton(
          onPressed: () => widget.onUpdateOrderStatus(widget.order['order_id'], 'Picked Up'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Mark Picked Up'),
        );
      
      case 'Picked Up':
        return ElevatedButton(
          onPressed: () => widget.onUpdateOrderStatus(widget.order['order_id'], 'In Transit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Start Delivery'),
        );
      
      case 'In Transit':
        final orderNumber = widget.order['order_number'] ?? '#${widget.order['order_id']?.toString().substring(0, 8)}';
        return ElevatedButton(
          onPressed: () => widget.onShowDeliveryConfirmation(
            context,
            widget.order['order_id'],
            orderNumber,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Mark Delivered'),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }
}