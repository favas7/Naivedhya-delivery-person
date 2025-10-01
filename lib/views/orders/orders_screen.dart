import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize orders after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrders();
    });
  }

  void _initializeOrders() {
    final authProvider = context.read<AuthProvider>();
    final ordersProvider = context.read<OrdersProvider>();
    
    if (authProvider.user != null) {
      ordersProvider.initializeOrders(authProvider.user!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveOrders(),
          _buildPendingOrders(),
          _buildCompletedOrders(),
        ],
      ),
    );
  }

  void _refreshOrders() {
    final authProvider = context.read<AuthProvider>();
    final ordersProvider = context.read<OrdersProvider>();
    
    if (authProvider.user != null) {
      ordersProvider.refreshAllOrders(authProvider.user!.id);
    }
  }

  Widget _buildActiveOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoadingActive) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersProvider.activeOrdersError != null) {
          return _buildErrorWidget(
            ordersProvider.activeOrdersError!,
            () => _refreshOrders(),
          );
        }

        if (ordersProvider.activeOrders.isEmpty) {
          return _buildEmptyState('No active orders');
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.activeOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.activeOrders[index];
              return _buildActiveOrderCard(order, ordersProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildPendingOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoadingPending) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersProvider.pendingOrdersError != null) {
          return _buildErrorWidget(
            ordersProvider.pendingOrdersError!,
            () => _refreshOrders(),
          );
        }

        if (ordersProvider.pendingOrders.isEmpty) {
          return _buildEmptyState('No pending orders');
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.pendingOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.pendingOrders[index];
              return _buildPendingOrderCard(order, ordersProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildCompletedOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoadingCompleted) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersProvider.completedOrdersError != null) {
          return _buildErrorWidget(
            ordersProvider.completedOrdersError!,
            () => _refreshOrders(),
          );
        }

        if (ordersProvider.completedOrders.isEmpty) {
          return _buildEmptyState('No completed orders');
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.completedOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.completedOrders[index];
              return _buildCompletedOrderCard(order, ordersProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildActiveOrderCard(Map<String, dynamic> order, OrdersProvider ordersProvider) {
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
                        onTap: () => _callCustomer(customerPhone),
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
                _buildAddressRow(
                  icon: Icons.restaurant,
                  iconColor: AppColors.accent,
                  title: 'Pickup',
                  address: pickupAddress,
                ),
                
                const SizedBox(height: 12),
                
                // Delivery location
                _buildAddressRow(
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
                    _buildOrderStat('Distance', distance, Icons.straighten),
                    _buildOrderStat('Time', estimatedTime, Icons.access_time),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                _buildActionButtons(order, deliveryStatus, ordersProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order, String deliveryStatus, OrdersProvider ordersProvider) {
    final authProvider = context.read<AuthProvider>();
    
    switch (deliveryStatus) {
      case 'Assigned':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _navigateToMap(order),
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
                onPressed: () => _updateOrderStatus(
                  order['order_id'], 
                  'Picked Up', 
                  ordersProvider, 
                  authProvider.user!.id
                ),
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
                onPressed: () => _navigateToMap(order),
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
                onPressed: () => _updateOrderStatus(
                  order['order_id'], 
                  'In Transit', 
                  ordersProvider, 
                  authProvider.user!.id
                ),
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
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _navigateToMap(order),
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
                onPressed: () => _showDeliveryConfirmation(
                  context, 
                  order['order_id'], 
                  order['order_number'] ?? '#${order['order_id']?.toString().substring(0, 8)}',
                  ordersProvider,
                  authProvider.user!.id
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

  Widget _buildPendingOrderCard(Map<String, dynamic> order, OrdersProvider ordersProvider) {
    final orderId = order['order_number'] ?? '#${order['order_id']?.toString().substring(0, 8)}';
    final pickupAddress = ordersProvider.getPickupAddress(order);
    final amount = ordersProvider.formatOrderAmount(order['total_amount'] ?? 0);
    final distance = ordersProvider.calculateDistance(order);
    final timePosted = ordersProvider.getTimeAgo(order['created_at']);
    final authProvider = context.read<AuthProvider>();

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
                          onPressed: () => _acceptOrder(
                            order['order_id'], 
                            orderId,
                            ordersProvider,
                            authProvider.user!.id
                          ),
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

  Widget _buildCompletedOrderCard(Map<String, dynamic> order, OrdersProvider ordersProvider) {
    final orderId = order['order_number'] ?? '#${order['order_id']?.toString().substring(0, 8)}';
    final customerName = order['customer_name'] ?? 'Unknown Customer';
    final amount = ordersProvider.formatOrderAmount(order['total_amount'] ?? 0);
    final deliveredTime = ordersProvider.getTimeAgo(order['delivery_time']);
    final rating = ordersProvider.getOrderRating(order);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivered $deliveredTime',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStat(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String errorMessage, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Missing action methods implementation
  Future<void> _acceptOrder(String orderId, String orderNumber, OrdersProvider ordersProvider, String deliveryPersonId) async {
    try {
      final success = await ordersProvider.acceptOrder(orderId, deliveryPersonId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderNumber accepted!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept order. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status, OrdersProvider ordersProvider, String deliveryPersonId) async {
    try {
      final success = await ordersProvider.updateOrderStatus(orderId, status, deliveryPersonId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order marked as $status'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update order status. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _callCustomer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch phone dialer'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _navigateToMap(Map<String, dynamic> order) async {
    // Extract coordinates for navigation
    final _ = _getPickupLatitude(order);
    final _ = _getPickupLongitude(order);
    final deliveryAddress = order['delivery_location'] ?? 'Unknown Location';
    
    try {
      // Try to open Google Maps first
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$deliveryAddress&travelmode=driving'
      );
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to showing coordinates in a snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigate to: $deliveryAddress'),
              backgroundColor: AppColors.primary,
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  // You could implement clipboard copy here
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeliveryConfirmation(
    BuildContext context,
    String orderId,
    String orderNumber,
    OrdersProvider ordersProvider,
    String deliveryPersonId
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delivery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to mark order $orderNumber as delivered?'),
              const SizedBox(height: 16),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatus(orderId, 'Delivered', ordersProvider, deliveryPersonId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Confirm Delivery'),
            ),
          ],
        );
      },
    );
  }

  // Helper methods to safely extract coordinates
  double? _getPickupLatitude(Map<String, dynamic> order) {
    try {
      if (order['hotels'] != null && 
          order['hotels'] is List && 
          order['hotels'].isNotEmpty) {
        return order['hotels'][0]['latitude']?.toDouble();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  double? _getPickupLongitude(Map<String, dynamic> order) {
    try {
      if (order['hotels'] != null && 
          order['hotels'] is List && 
          order['hotels'].isNotEmpty) {
        return order['hotels'][0]['longitude']?.toDouble();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}