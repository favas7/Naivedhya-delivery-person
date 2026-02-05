import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_colors.dart';
import 'widgets/active_orders_tab.dart';
import 'widgets/pending_orders_tab.dart';
import 'widgets/completed_orders_tab.dart';

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
          ActiveOrdersTab(
            onRefresh: _refreshOrders,
            onCallCustomer: _callCustomer,
            onNavigateToMap: _navigateToMap,
            onUpdateOrderStatus: _updateOrderStatusWrapper,
            onShowDeliveryConfirmation: _showDeliveryConfirmation,
          ),
          PendingOrdersTab(
            onRefresh: _refreshOrders,
            onAcceptOrder: _acceptOrderWrapper,
          ),
          CompletedOrdersTab(
            onRefresh: _refreshOrders,
          ),
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

  // Wrapper methods to add deliveryPersonId
  void _acceptOrderWrapper(String orderId, String orderNumber) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      _acceptOrder(orderId, orderNumber, context.read<OrdersProvider>(), authProvider.user!.id);
    }
  }

  void _updateOrderStatusWrapper(String orderId, String status) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      _updateOrderStatus(orderId, status, context.read<OrdersProvider>(), authProvider.user!.id);
    }
  }

  // Action methods
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
    final deliveryAddress = order['delivery_location'] ?? 'Unknown Location';
    
    try {
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$deliveryAddress&travelmode=driving'
      );
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigate to: $deliveryAddress'),
              backgroundColor: AppColors.primary,
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {},
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
  ) {
    final authProvider = context.read<AuthProvider>();
    final ordersProvider = context.read<OrdersProvider>();
    
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
                _updateOrderStatus(orderId, 'Delivered', ordersProvider, authProvider.user!.id);
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
}