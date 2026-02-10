import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_colors.dart';
import 'widgets/active_orders_tab.dart';
import 'widgets/completed_orders_tab.dart';
import 'package:geolocator/geolocator.dart';

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
    _tabController = TabController(length: 2, vsync: this);  // Changed from 3 to 2
    
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
          CompletedOrdersTab(  
            onRefresh: _refreshOrders,
            onNavigateToMap: _navigateToMap, 
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


  void _updateOrderStatusWrapper(String orderId, String status) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      _updateOrderStatus(orderId, status, context.read<OrdersProvider>(), authProvider.user!.id);
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
    double? latitude;
    double? longitude;
    
    // Get coordinates from addresses table
    final addressData = order['addresses'];
    
    if (addressData != null && addressData is Map<String, dynamic>) {
      latitude = addressData['latitude'] as double?;
      longitude = addressData['longitude'] as double?;
    }
    
    try {
      if (latitude != null && longitude != null) {
        final googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving'
        );
        
        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open Google Maps'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location not available for order ${order['order_number'] ?? 'Unknown'}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
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
) async {
  final authProvider = context.read<AuthProvider>();
  final ordersProvider = context.read<OrdersProvider>();
  
  // Fetch current location
  Position? currentPosition;
  bool isFetchingLocation = true;
  String? locationError;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Fetch location when dialog opens
          if (isFetchingLocation && currentPosition == null && locationError == null) {
            _getCurrentLocation().then((position) {
              if (position != null) {
                setState(() {
                  currentPosition = position;
                  isFetchingLocation = false;
                });
              } else {
                setState(() {
                  locationError = 'Failed to get location';
                  isFetchingLocation = false;
                });
              }
            });
          }
          
          return AlertDialog(
            title: const Text('Confirm Delivery'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to mark order $orderNumber as delivered?'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                
                // Location status
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: isFetchingLocation 
                          ? AppColors.primary 
                          : (locationError != null ? AppColors.error : AppColors.success),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: isFetchingLocation
                          ? const Text(
                              'Fetching your location...',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            )
                          : locationError != null
                              ? Text(
                                  locationError!,
                                  style: const TextStyle(fontSize: 13, color: AppColors.error),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Delivery location:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currentPosition!.latitude.toStringAsFixed(6)}, ${currentPosition!.longitude.toStringAsFixed(6)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Text(
                  'Your current location will be saved as proof of delivery.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (isFetchingLocation || locationError != null || currentPosition == null)
                    ? null
                    : () async {
                        Navigator.of(dialogContext).pop();
                        await _markAsDelivered(
                          orderId,
                          ordersProvider,
                          authProvider.user!.id,
                          currentPosition!,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  disabledBackgroundColor: AppColors.success.withOpacity(0.5),
                ),
                child: isFetchingLocation
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Confirm Delivery'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<Position?> _getCurrentLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  } catch (e) {
    print('Error getting location: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    return null;
  }
}

Future<void> _markAsDelivered(
  String orderId,
  OrdersProvider ordersProvider,
  String deliveryPersonId,
  Position position,
) async {
  try {
    final success = await ordersProvider.updateOrderStatusWithLocation(
      orderId,
      'Delivered',
      deliveryPersonId,
      position.latitude,
      position.longitude,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order marked as Delivered'),
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
}