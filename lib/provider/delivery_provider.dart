import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/service/delivery_data_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryProvider with ChangeNotifier {
  final DeliveryDataService _dataService = DeliveryDataService();
  
  // Delivery personnel data
  Map<String, dynamic>? _deliveryPersonnelData;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Stats data
  int _todaysOrdersCount = 0;
  double _todaysEarnings = 0.0;
  List<Map<String, dynamic>> _recentOrders = [];
  
  // Real-time subscriptions
  RealtimeChannel? _personnelSubscription;
  RealtimeChannel? _ordersSubscription;
  
  // Getters
  Map<String, dynamic>? get deliveryPersonnelData => _deliveryPersonnelData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get todaysOrdersCount => _todaysOrdersCount;
  double get todaysEarnings => _todaysEarnings;
  List<Map<String, dynamic>> get recentOrders => _recentOrders;
  bool get isAvailable => _deliveryPersonnelData?['is_available'] ?? false;
  String get deliveryPersonName => _deliveryPersonnelData?['full_name'] ?? 'Delivery Partner';
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  // Initialize delivery data for current user
  Future<void> initializeDeliveryData(String userId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      // Fetch delivery personnel data
      final personnelData = await _dataService.getDeliveryPersonnelData(userId);
      if (personnelData != null) {
        _deliveryPersonnelData = personnelData;
        
        // Fetch stats data
        await _fetchStatsData(userId);
        
        // Setup real-time subscriptions
        _setupRealtimeSubscriptions(userId);
      } else {
        _setError('Delivery personnel data not found');
      }
    } catch (e) {
      _setError('Error initializing delivery data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch stats data (orders count, earnings, recent orders)
  Future<void> _fetchStatsData(String userId) async {
    try {
      // Get today's orders count
      _todaysOrdersCount = await _dataService.getTodaysOrdersCount(userId);
      
      // Get today's earnings
      _todaysEarnings = await _dataService.getTodaysEarnings(userId);
      
      // Get recent orders
      _recentOrders = await _dataService.getRecentOrders(userId, limit: 5);
      
      notifyListeners();
    } catch (e) {
      print('Error fetching stats data: $e');
    }
  }
  
  // Setup real-time subscriptions
  void _setupRealtimeSubscriptions(String userId) {
    // Subscribe to delivery personnel data changes
    _personnelSubscription = _dataService.subscribeToDeliveryPersonnelData(
      userId,
      (updatedData) {
        _deliveryPersonnelData = {..._deliveryPersonnelData!, ...updatedData};
        notifyListeners();
      },
    );
    
    // Subscribe to orders changes
    _ordersSubscription = _dataService.subscribeToOrders(
      userId,
      () {
        // Refresh stats when orders change
        _fetchStatsData(userId);
      },
    );
  }
  
  // Toggle availability status
  Future<bool> toggleAvailability(String userId) async {
    try {
      final newStatus = !isAvailable;
      final success = await _dataService.updateAvailabilityStatus(userId, newStatus);
      
      if (success && _deliveryPersonnelData != null) {
        _deliveryPersonnelData!['is_available'] = newStatus;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error updating availability: $e');
      return false;
    }
  }
  
  // Refresh all data
  Future<void> refreshData(String userId) async {
    await _fetchStatsData(userId);
  }
  
  // Method to be called when orders are updated from OrdersProvider
  Future<void> syncWithOrdersProvider(String userId) async {
    await _fetchStatsData(userId);
  }
  
  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Dispose subscriptions
  @override
  void dispose() {
    _personnelSubscription?.unsubscribe();
    _ordersSubscription?.unsubscribe();
    super.dispose();
  }
  
  // Get formatted order status
  String getOrderStatusDisplay(String? status, String? deliveryStatus) {
    if (deliveryStatus == 'Delivered') return 'Delivered';
    if (deliveryStatus == 'In Transit') return 'In Progress';
    if (deliveryStatus == 'Picked Up') return 'Picked Up';
    if (deliveryStatus == 'Assigned') return 'Assigned';
    return status ?? 'Unknown';
  }
  
  // Get time ago string
  String getTimeAgo(String? createdAt) {
    if (createdAt == null) return 'Unknown time';
    
    final created = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(created);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}