import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersDataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Define enum constants to match your PostgreSQL enum values
  static const String deliveryStatusAssigned = 'Assigned';
  static const String deliveryStatusPickedUp = 'Picked Up';
  static const String deliveryStatusInTransit = 'In Transit';
  static const String deliveryStatusDelivered = 'Delivered';
  
  static const String orderStatusPending = 'Pending';
  static const String orderStatusConfirmed = 'Confirmed';
  static const String orderStatusPreparing = 'Preparing';
  static const String orderStatusReady = 'Ready';
  static const String orderStatusDelivered = 'Delivered';

  // Get active orders for delivery person
  Future<List<Map<String, dynamic>>> getActiveOrders(String deliveryPersonId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            order_id,
            order_number,
            customer_name,
            customer_id,
            total_amount,
            status,
            delivery_status,
            delivery_location,
            proposed_delivery_time,
            pickup_time,
            delivery_time,
            created_at,
            updated_at,
            order_items,
            delivery_address,
            restaurant!inner(
              name,
              address
            ),
            profiles!inner(
              name,
              phone
            ),
            addresses!orders_delivery_address_fkey(
              addressid,
              fulladdress,
              label
            )
          ''')
          .eq('delivery_person_id', deliveryPersonId)
          .inFilter('delivery_status', [deliveryStatusAssigned, deliveryStatusPickedUp, deliveryStatusInTransit])
          .order('created_at', ascending: false);

      print('===== ACTIVE ORDERS RESPONSE =====');
      print('Response: $response');
      
      // Post-process to add location coordinates using RPC
      final List<Map<String, dynamic>> ordersWithCoords = [];
      
      for (final order in response) {
        final orderMap = Map<String, dynamic>.from(order);
        print('Processing order: ${orderMap['order_number']}');
        print('Delivery address: ${orderMap['delivery_address']}');
        
        // Get coordinates using PostGIS ST_AsText function
        if (orderMap['delivery_address'] != null) {
          try {
            print('Calling RPC for address: ${orderMap['delivery_address']}');
            final coordResponse = await _supabase
                .rpc('get_address_coordinates', 
                  params: {'address_id': orderMap['delivery_address']});
            
            print('RPC Response: $coordResponse');
            
            if (coordResponse != null) {
              // Add coordinates to addresses object
              if (orderMap['addresses'] != null && orderMap['addresses'] is Map) {
                final addressMap = Map<String, dynamic>.from(orderMap['addresses']);
                addressMap['latitude'] = coordResponse['latitude'];
                addressMap['longitude'] = coordResponse['longitude'];
                orderMap['addresses'] = addressMap;
                print('Updated addresses: ${orderMap['addresses']}');
              }
            }
          } catch (e) {
            print('Error fetching coordinates for order ${orderMap['order_number']}: $e');
          }
        }
        
        ordersWithCoords.add(orderMap);
      }
      
      print('Final orders with coords: $ordersWithCoords');
      print('=====================================');

      return ordersWithCoords;
    } catch (e) {
      print('Error fetching active orders: $e');
      return [];
    }
  }

  // Get pending orders (not assigned to anyone or available for pickup)
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            order_id,
            order_number,
            customer_name,
            customer_id,
            total_amount,
            status,
            delivery_status,
            delivery_location,
            proposed_delivery_time,
            created_at,
            restaurant!inner(
              name,
              address
            )
          ''')
          .eq('delivery_status', deliveryStatusAssigned)
          .isFilter('delivery_person_id', null)
          .inFilter('status', [orderStatusConfirmed, orderStatusPreparing])
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching pending orders: $e');
      return [];
    }
  }


// Get completed orders for delivery person
Future<List<Map<String, dynamic>>> getCompletedOrders(String deliveryPersonId) async {
  try {
    final response = await _supabase
        .from('orders')
        .select('''
          order_id,
          order_number,
          customer_name,
          total_amount,
          delivery_status,
          delivery_time,
          created_at,
          delivery_address,
          restaurant!inner(
            name,
            address
          ),
          addresses!orders_delivery_address_fkey(
            addressid,
            fulladdress,
            label
          )
        ''')
        .eq('delivery_person_id', deliveryPersonId)
        .eq('delivery_status', deliveryStatusDelivered)
        .order('delivery_time', ascending: false)
        .limit(50);

    print('===== COMPLETED ORDERS RESPONSE =====');
    print('Response: $response');
    
    // Post-process to add location coordinates using RPC
    final List<Map<String, dynamic>> ordersWithCoords = [];
    
    for (final order in response) {
      final orderMap = Map<String, dynamic>.from(order);
      print('Processing order: ${orderMap['order_number']}');
      print('Delivery address: ${orderMap['delivery_address']}');
      
      // Get coordinates using PostGIS ST_AsText function
      if (orderMap['delivery_address'] != null) {
        try {
          print('Calling RPC for address: ${orderMap['delivery_address']}');
          final coordResponse = await _supabase
              .rpc('get_address_coordinates', 
                params: {'address_id': orderMap['delivery_address']});
          
          print('RPC Response: $coordResponse');
          
          if (coordResponse != null) {
            // Add coordinates to addresses object
            if (orderMap['addresses'] != null && orderMap['addresses'] is Map) {
              final addressMap = Map<String, dynamic>.from(orderMap['addresses']);
              addressMap['latitude'] = coordResponse['latitude'];
              addressMap['longitude'] = coordResponse['longitude'];
              orderMap['addresses'] = addressMap;
              print('Updated addresses: ${orderMap['addresses']}');
            }
          }
        } catch (e) {
          print('Error fetching coordinates for order ${orderMap['order_number']}: $e');
        }
      }
      
      ordersWithCoords.add(orderMap);
    }
    
    print('Final orders with coords: $ordersWithCoords');
    print('=====================================');

    return ordersWithCoords;
  } catch (e) {
    print('Error fetching completed orders: $e');
    return [];
  }
}


  // Accept a pending order
  Future<bool> acceptOrder(String orderId, String deliveryPersonId) async {
    try {
      await _supabase
          .from('orders')
          .update({
            'delivery_person_id': deliveryPersonId,
            'delivery_status': deliveryStatusAssigned,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId);
      
      return true;
    } catch (e) {
      print('Error accepting order: $e');
      return false;
    }
  }

  // Update order status (pickup, in transit, delivered)
  Future<bool> updateOrderStatus(String orderId, String deliveryStatus) async {
    try {
      Map<String, dynamic> updateData = {
        'delivery_status': deliveryStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Set specific timestamps based on status
      if (deliveryStatus == deliveryStatusPickedUp) {
        updateData['pickup_time'] = DateTime.now().toIso8601String();
      } else if (deliveryStatus == deliveryStatusDelivered) {
        updateData['delivery_time'] = DateTime.now().toIso8601String();
        updateData['status'] = orderStatusDelivered; // Also update main status
      }

      await _supabase
          .from('orders')
          .update(updateData)
          .eq('order_id', orderId);
      
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // Get order details with items
  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            order_id,
            order_number,
            customer_name,
            customer_id,
            total_amount,
            status,
            delivery_status,
            delivery_location,
            proposed_delivery_time,
            pickup_time,
            delivery_time,
            created_at,
            updated_at,
            restaurant!inner(
              name,
              address
            ),
            profiles!inner(
              name,
              phone
            ),
            order_items!inner(
              quantity,
              price,
              menu_items!inner(
                name,
                description
              )
            )
          ''')
          .eq('order_id', orderId)
          .single();

      return response;
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }

  // Calculate distance (placeholder - you might want to use Google Maps API)
  String calculateDistance(double? lat1, double? lon1, double? lat2, double? lon2) {
    // This is a placeholder. In a real app, you'd use Google Maps Distance Matrix API
    // or a similar service to get accurate driving distances and times
    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
      return 'N/A';
    }
    
    // Simple straight-line distance calculation (not accurate for routing)
    // You should replace this with actual distance calculation
    return '${(2.5 + (lat1 + lon1 + lat2 + lon2) % 5).toStringAsFixed(1)} km';
  }

  // Calculate estimated delivery time
  String calculateEstimatedTime(DateTime? proposedTime) {
    if (proposedTime == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = proposedTime.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
  }

  // Real-time subscription for orders assigned to delivery person
  RealtimeChannel subscribeToDeliveryPersonOrders(
    String deliveryPersonId, 
    Function() onOrderChange
  ) {
    return _supabase
        .channel('delivery_person_orders_$deliveryPersonId')
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

  // Real-time subscription for pending orders (for all delivery personnel)
  RealtimeChannel subscribeToPendingOrders(Function() onPendingOrderChange) {
    return _supabase
        .channel('pending_orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            // Check if this is a pending order change
            final newRecord = payload.newRecord;
            final oldRecord = payload.oldRecord;
            
            if (newRecord['delivery_person_id'] == null && 
                newRecord['delivery_status'] == deliveryStatusAssigned) {
              onPendingOrderChange();
            } else if (oldRecord['delivery_person_id'] == null && 
                       oldRecord['delivery_status'] == deliveryStatusAssigned) {
              onPendingOrderChange();
            }
          },
        )
        .subscribe();
  }

  // Format order amount
  String formatAmount(num amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  // Format time ago
  String formatTimeAgo(String? dateString) {
    if (dateString == null) return 'Unknown time';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  // Get customer phone from profiles
  String getCustomerPhone(Map<String, dynamic> orderData) {
    try {
      if (orderData['profiles'] != null && 
          orderData['profiles'] is List && 
          orderData['profiles'].isNotEmpty) {
        return orderData['profiles'][0]['phone'] ?? 'N/A';
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  // Get pickup address from restaurant
  String getPickupAddress(Map<String, dynamic> orderData) {
    try {
      if (orderData['restaurant'] != null && 
          orderData['restaurant'] is List && 
          orderData['restaurant'].isNotEmpty) {
        final restaurant = orderData['restaurant'][0];
        return '${restaurant['name']}, ${restaurant['address']}';
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  // Get delivery address from addresses table
  String getDeliveryAddress(Map<String, dynamic> orderData) {
    try {
      // Check if addresses data exists (joined from addresses table)
      if (orderData['addresses'] != null) {
        final address = orderData['addresses'];
        
        // If addresses is a Map (single join result)
        if (address is Map<String, dynamic>) {
          final fullAddress = address['fulladdress'] as String?;
          final label = address['label'] as String?;
          
          if (fullAddress != null && fullAddress.isNotEmpty) {
            // If label exists, show it along with address
            if (label != null && label.isNotEmpty) {
              return '$label - $fullAddress';
            }
            return fullAddress;
          }
        }
      }
      
      // Fallback: if no address found in addresses table
      return 'Address not found';
    } catch (e) {
      print('Error getting delivery address: $e');
      return 'Address not found';
    }
  }

  // Helper method to check if a delivery status is valid
  bool isValidDeliveryStatus(String status) {
    return [
      deliveryStatusAssigned,
      deliveryStatusPickedUp,
      deliveryStatusInTransit,
      deliveryStatusDelivered,
    ].contains(status);
  }

  // Helper method to check if an order status is valid
  bool isValidOrderStatus(String status) {
    return [
      orderStatusPending,
      orderStatusConfirmed,
      orderStatusPreparing,
      orderStatusReady,
      orderStatusDelivered,
    ].contains(status);
  }


  // Update order status with delivery person's location (only if address doesn't have coordinates)
  Future<bool> updateOrderStatusWithLocation(
    String orderId, 
    String deliveryStatus,
    double latitude,
    double longitude,
  ) async {
    try {
      // First, get the delivery_address UUID from the order
      final orderResponse = await _supabase
          .from('orders')
          .select('delivery_address')
          .eq('order_id', orderId)
          .single();
      
      final deliveryAddressId = orderResponse['delivery_address'] as String?;
      
      if (deliveryAddressId == null) {
        print('No delivery address found for order');
        return false;
      }
      
      // Check if the address already has location coordinates
      final addressResponse = await _supabase
          .from('addresses')
          .select('location')
          .eq('addressid', deliveryAddressId)
          .single();
      
      final existingLocation = addressResponse['location'];
      bool hasExistingCoordinates = existingLocation != null;
      
      print('Address $deliveryAddressId has existing coordinates: $hasExistingCoordinates');
      
      // Update order status
      Map<String, dynamic> updateData = {
        'delivery_status': deliveryStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Set specific timestamps based on status
      if (deliveryStatus == deliveryStatusPickedUp) {
        updateData['pickup_time'] = DateTime.now().toIso8601String();
      } else if (deliveryStatus == deliveryStatusDelivered) {
        updateData['delivery_time'] = DateTime.now().toIso8601String();
        updateData['status'] = orderStatusDelivered;
      }

      await _supabase
          .from('orders')
          .update(updateData)
          .eq('order_id', orderId);
      
      // Only update the delivery address location if it doesn't already have coordinates
      if (deliveryStatus == deliveryStatusDelivered && !hasExistingCoordinates) {
        print('Updating address location with delivery person coordinates');
        await _supabase
            .from('addresses')
            .update({
              'location': 'POINT($longitude $latitude)',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('addressid', deliveryAddressId);
      } else if (hasExistingCoordinates) {
        print('Skipping location update - address already has coordinates');
      }
      
      return true;
    } catch (e) {
      print('Error updating order status with location: $e');
      return false;
    }
  }


// Parse PostGIS geography point to latitude/longitude
Map<String, double>? parseLocationCoordinates(dynamic location) {
  try {
    if (location == null) return null;
    
    String locationStr = location.toString();
    
    // PostGIS returns geography as: {"type":"Point","coordinates":[longitude,latitude]}
    if (locationStr.contains('coordinates')) {
      // Try to parse as JSON
      final jsonData = jsonDecode(locationStr);
      if (jsonData is Map && jsonData['coordinates'] is List) {
        final coords = jsonData['coordinates'] as List;
        if (coords.length >= 2) {
          return {
            'latitude': (coords[1] as num).toDouble(),
            'longitude': (coords[0] as num).toDouble(),
          };
        }
      }
    }
    
    // Alternative format: POINT(longitude latitude)
    if (locationStr.contains('POINT')) {
      final regex = RegExp(r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)');
      final match = regex.firstMatch(locationStr);
      if (match != null) {
        return {
          'latitude': double.parse(match.group(2)!),
          'longitude': double.parse(match.group(1)!),
        };
      }
    }
    
    return null;
  } catch (e) {
    print('Error parsing location coordinates: $e');
    return null;
  }
}
}