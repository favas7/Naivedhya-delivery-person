import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/service/orders_data_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersProvider with ChangeNotifier {
  final OrdersDataService _ordersService = OrdersDataService();
  
  // Orders data
  List<Map<String, dynamic>> _activeOrders = [];
  List<Map<String, dynamic>> _pendingOrders = [];
  List<Map<String, dynamic>> _completedOrders = [];
  
  // Loading states
  bool _isLoadingActive = false;
  bool _isLoadingPending = false;
  bool _isLoadingCompleted = false;
  
  // Error states
  String? _activeOrdersError;
  String? _pendingOrdersError;
  String? _completedOrdersError;
  
  // Real-time subscriptions
  RealtimeChannel? _deliveryPersonOrdersSubscription;
  RealtimeChannel? _pendingOrdersSubscription;
  
  // Callback for syncing with DeliveryProvider
  Function(String)? _onOrdersChanged;
  
  // Getters
  List<Map<String, dynamic>> get activeOrders => _activeOrders;
  List<Map<String, dynamic>> get pendingOrders => _pendingOrders;
  List<Map<String, dynamic>> get completedOrders => _completedOrders;
  
  bool get isLoadingActive => _isLoadingActive;
  bool get isLoadingPending => _isLoadingPending;
  bool get isLoadingCompleted => _isLoadingCompleted;
  
  String? get activeOrdersError => _activeOrdersError;
  String? get pendingOrdersError => _pendingOrdersError;
  String? get completedOrdersError => _completedOrdersError;
  
  // Set callback for syncing with DeliveryProvider
  void setSyncCallback(Function(String) callback) {
    _onOrdersChanged = callback;
  }
  
  // Initialize orders for delivery person
  Future<void> initializeOrders(String deliveryPersonId) async {
    await Future.wait([
      fetchActiveOrders(deliveryPersonId),
      fetchPendingOrders(),
      fetchCompletedOrders(deliveryPersonId),
    ]);
    
    _setupRealtimeSubscriptions(deliveryPersonId);
  }
  
  // Fetch active orders
  Future<void> fetchActiveOrders(String deliveryPersonId) async {
    _isLoadingActive = true;
    _activeOrdersError = null;
    notifyListeners();
    
    try {
      _activeOrders = await _ordersService.getActiveOrders(deliveryPersonId);
    } catch (e) {
      _activeOrdersError = 'Failed to load active orders: $e';
    } finally {
      _isLoadingActive = false;
      notifyListeners();
    }
  }
  
  // Fetch pending orders
  Future<void> fetchPendingOrders() async {
    _isLoadingPending = true;
    _pendingOrdersError = null;
    notifyListeners();
    
    try {
      _pendingOrders = await _ordersService.getPendingOrders();
    } catch (e) {
      _pendingOrdersError = 'Failed to load pending orders: $e';
    } finally {
      _isLoadingPending = false;
      notifyListeners();
    }
  }
  
  // Fetch completed orders
  Future<void> fetchCompletedOrders(String deliveryPersonId) async {
    _isLoadingCompleted = true;
    _completedOrdersError = null;
    notifyListeners();
    
    try {
      _completedOrders = await _ordersService.getCompletedOrders(deliveryPersonId);
    } catch (e) {
      _completedOrdersError = 'Failed to load completed orders: $e';
    } finally {
      _isLoadingCompleted = false;
      notifyListeners();
    }
  }
  
  // Accept a pending order
  Future<bool> acceptOrder(String orderId, String deliveryPersonId) async {
    try {
      final success = await _ordersService.acceptOrder(orderId, deliveryPersonId);
      if (success) {
        // Remove from pending orders and refresh active orders
        _pendingOrders.removeWhere((order) => order['order_id'] == orderId);
        await fetchActiveOrders(deliveryPersonId);
        
        // Notify DeliveryProvider to sync
        _onOrdersChanged?.call(deliveryPersonId);
      }
      return success;
    } catch (e) {
      print('Error accepting order: $e');
      return false;
    }
  }
  
  // Update order status
  Future<bool> updateOrderStatus(String orderId, String deliveryStatus, String deliveryPersonId) async {
    try {
      final success = await _ordersService.updateOrderStatus(orderId, deliveryStatus);
      if (success) {
        // Refresh active and completed orders based on the status
        if (deliveryStatus == 'Delivered') {
          await Future.wait([
            fetchActiveOrders(deliveryPersonId),
            fetchCompletedOrders(deliveryPersonId),
          ]);
        } else {
          await fetchActiveOrders(deliveryPersonId);
        }
        
        // Notify DeliveryProvider to sync
        _onOrdersChanged?.call(deliveryPersonId);
      }
      return success;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
  
  // Setup real-time subscriptions
  void _setupRealtimeSubscriptions(String deliveryPersonId) {
    // Subscribe to changes in orders assigned to this delivery person
    _deliveryPersonOrdersSubscription = _ordersService.subscribeToDeliveryPersonOrders(
      deliveryPersonId,
      () {
        // Refresh active and completed orders when changes occur
        fetchActiveOrders(deliveryPersonId);
        fetchCompletedOrders(deliveryPersonId);
        
        // Notify DeliveryProvider to sync
        _onOrdersChanged?.call(deliveryPersonId);
      },
    );
    
    // Subscribe to changes in pending orders
    _pendingOrdersSubscription = _ordersService.subscribeToPendingOrders(() {
      fetchPendingOrders();
    });
  }
  
  // Refresh all orders
  Future<void> refreshAllOrders(String deliveryPersonId) async {
    await Future.wait([
      fetchActiveOrders(deliveryPersonId),
      fetchPendingOrders(),
      fetchCompletedOrders(deliveryPersonId),
    ]);
    
    // Notify DeliveryProvider to sync
    _onOrdersChanged?.call(deliveryPersonId);
  }
  
  // Get order by ID from any list
  Map<String, dynamic>? getOrderById(String orderId) {
    // Search in active orders
    for (final order in _activeOrders) {
      if (order['order_id'] == orderId) return order;
    }
    
    // Search in pending orders
    for (final order in _pendingOrders) {
      if (order['order_id'] == orderId) return order;
    }
    
    // Search in completed orders
    for (final order in _completedOrders) {
      if (order['order_id'] == orderId) return order;
    }
    
    return null;
  }
  
  // Clear error messages
  void clearErrors() {
    _activeOrdersError = null;
    _pendingOrdersError = null;
    _completedOrdersError = null;
    notifyListeners();
  }
  
  // Helper methods for UI
  String formatOrderAmount(num amount) {
    return _ordersService.formatAmount(amount);
  }
  
  String getTimeAgo(String? dateString) {
    return _ordersService.formatTimeAgo(dateString);
  }
  
  String getCustomerPhone(Map<String, dynamic> orderData) {
    return _ordersService.getCustomerPhone(orderData);
  }
  
  String getPickupAddress(Map<String, dynamic> orderData) {
    return _ordersService.getPickupAddress(orderData);
  }
  
  String getDeliveryAddress(Map<String, dynamic> orderData) {
    return _ordersService.getDeliveryAddress(orderData);
  }
  
  String calculateDistance(Map<String, dynamic> orderData) {
    // You can implement distance calculation logic here
    // For now, return a placeholder
    return '2.5 km';
  }
  
  String calculateEstimatedTime(Map<String, dynamic> orderData) {
    final proposedTimeStr = orderData['proposed_delivery_time'] as String?;
    if (proposedTimeStr == null) return 'N/A';
    
    try {
      final proposedTime = DateTime.parse(proposedTimeStr);
      return _ordersService.calculateEstimatedTime(proposedTime);
    } catch (e) {
      return 'N/A';
    }
  }
  
  // Get order status display text
  String getOrderStatusDisplay(Map<String, dynamic> orderData) {
    final deliveryStatus = orderData['delivery_status'] as String?;
    final status = orderData['status'] as String?;
    
    switch (deliveryStatus) {
      case 'Delivered':
        return 'Delivered';
      case 'In Transit':
        return 'In Transit';
      case 'Picked Up':
        return 'Picked Up';
      case 'Assigned':
        return 'Assigned';
      default:
        return status ?? 'Unknown';
    }
  }

  // Update order status with delivery location
Future<bool> updateOrderStatusWithLocation(
  String orderId, 
  String deliveryStatus, 
  String deliveryPersonId,
  double latitude,
  double longitude,
) async {
  try {
    final success = await _ordersService.updateOrderStatusWithLocation(
      orderId, 
      deliveryStatus,
      latitude,
      longitude,
    );
    
    if (success) {
      // Refresh active and completed orders based on the status
      if (deliveryStatus == 'Delivered') {
        await Future.wait([
          fetchActiveOrders(deliveryPersonId),
          fetchCompletedOrders(deliveryPersonId),
        ]);
      } else {
        await fetchActiveOrders(deliveryPersonId);
      }
      
      // Notify DeliveryProvider to sync
      _onOrdersChanged?.call(deliveryPersonId);
    }
    return success;
  } catch (e) {
    print('Error updating order status with location: $e');
    return false;
  }
}
  
  // Get rating for completed orders (placeholder)
  double getOrderRating(Map<String, dynamic> orderData) {
    // This is a placeholder. You might want to add a ratings table
    // and fetch the rating for completed orders
    return 4.5;
  }
  // Parse PostGIS geography location to lat/lng
Map<String, double>? parseLocationCoordinates(dynamic location) {
  return _ordersService.parseLocationCoordinates(location);
}
  @override
  void dispose() {
    _deliveryPersonOrdersSubscription?.unsubscribe();
    _pendingOrdersSubscription?.unsubscribe();
    super.dispose();
  }
}