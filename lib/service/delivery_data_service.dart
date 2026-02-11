import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get delivery personnel data for current user
  Future<Map<String, dynamic>?> getDeliveryPersonnelData(String userId) async {
    try {
      final response = await _supabase
          .from('delivery_personnel')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error fetching delivery personnel data: $e');
      return null;
    }
  }

  // Update availability status
  Future<bool> updateAvailabilityStatus(String userId, bool isAvailable) async {
    try {
      await _supabase
          .from('delivery_personnel')
          .update({'is_available': isAvailable})
          .eq('user_id', userId);
      
      return true;
    } catch (e) {
      print('Error updating availability status: $e');
      return false;
    }
  }

Future<int> getTodaysOrdersCount(String deliveryPersonId) async {
  try {
    final response = await _supabase
        .from('orders')
        .select('order_id')
        .eq('delivery_person_id', deliveryPersonId);

    return response.length; 
  } catch (e) {
    print('Error fetching orders count: $e');
    return 0;
  }
}
  // Get today's earnings for delivery person
  Future<double> getTodaysEarnings(String deliveryPersonId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final response = await _supabase
          .from('orders')
          .select('total_amount')
          .eq('delivery_person_id', deliveryPersonId)
          .eq('delivery_status', 'Delivered')
          .gte('delivery_time', startOfDay.toIso8601String())
          .lte('delivery_time', endOfDay.toIso8601String());

      double totalEarnings = 0.0;
      for (final order in response) {
        // Assuming delivery person gets a percentage of total amount
        // Adjust this calculation based on your business logic
        totalEarnings += (order['total_amount'] as num).toDouble() * 0.1; // 10% commission
      }

      return totalEarnings;
    } catch (e) {
      print('Error fetching today\'s earnings: $e');
      return 0.0;
    }
  }

  // Get recent orders for delivery person
  Future<List<Map<String, dynamic>>> getRecentOrders(String deliveryPersonId, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            order_id,
            order_number,
            customer_name,
            total_amount,
            status,
            delivery_status,
            created_at,
            pickup_time,
            delivery_time
          ''')
          .eq('delivery_person_id', deliveryPersonId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching recent orders: $e');
      return [];
    }
  }

  // Real-time subscription for delivery personnel data
  RealtimeChannel subscribeToDeliveryPersonnelData(String userId, Function(Map<String, dynamic>) onUpdate) {
    return _supabase
        .channel('delivery_personnel_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'delivery_personnel',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  // Real-time subscription for orders
  RealtimeChannel subscribeToOrders(String deliveryPersonId, Function() onOrderChange) {
    return _supabase
        .channel('orders_$deliveryPersonId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'delivery_person_id',
            value: deliveryPersonId,
          ),
          callback: (payload) {
            onOrderChange();
          },
        )
        .subscribe();
  }
}