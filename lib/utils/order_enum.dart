// Order and Delivery Status Enums
// These should match exactly with your PostgreSQL enum values

class DeliveryStatus {
  static const String assigned = 'Assigned';
  static const String pickedUp = 'Picked Up';
  static const String inTransit = 'In Transit';
  static const String delivered = 'Delivered';
  
  static const List<String> all = [
    assigned,
    pickedUp,
    inTransit,
    delivered,
  ];
  
  static bool isValid(String status) => all.contains(status);
}

class OrderStatus {
  static const String pending = 'Pending';
  static const String confirmed = 'Confirmed';
  static const String preparing = 'Preparing';
  static const String ready = 'Ready';
  static const String delivered = 'Delivered';
  
  static const List<String> all = [
    pending,
    confirmed,
    preparing,
    ready,
    delivered,
  ];
  
  static bool isValid(String status) => all.contains(status);
}

// If you need display-friendly labels
class StatusLabels {
  static const Map<String, String> deliveryStatus = {
    DeliveryStatus.assigned: 'Assigned',
    DeliveryStatus.pickedUp: 'Picked Up',
    DeliveryStatus.inTransit: 'In Transit',
    DeliveryStatus.delivered: 'Delivered',
  };
  
  static const Map<String, String> orderStatus = {
    OrderStatus.pending: 'Pending',
    OrderStatus.confirmed: 'Confirmed',
    OrderStatus.preparing: 'Preparing',
    OrderStatus.ready: 'Ready for Pickup',
    OrderStatus.delivered: 'Delivered',
  };
}