// lib/models/delivery_personnel.dart

class DeliveryPersonnel {
  final String userId;
  final String name;
  final String email;
  final String fullName;
  final String phone;
  final String state;
  final String city;
  final String aadhaarNumber;
  final DateTime dateOfBirth;
  final String vehicleType;
  final String vehicleModel;
  final String numberPlate;
  final String? licenseImageUrl;
  final String? aadhaarImageUrl;
  final bool isAvailable;
  final List<String>? assignedOrders;
  final double earnings;
  final bool isVerified;
  final String verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryPersonnel({
    required this.userId,
    required this.name,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.state,
    required this.city,
    required this.aadhaarNumber,
    required this.dateOfBirth,
    required this.vehicleType,
    required this.vehicleModel,
    required this.numberPlate,
    this.licenseImageUrl,
    this.aadhaarImageUrl,
    this.isAvailable = true,
    this.assignedOrders,
    this.earnings = 0.0,
    this.isVerified = false,
    this.verificationStatus = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from JSON (Supabase response)
  factory DeliveryPersonnel.fromJson(Map<String, dynamic> json) {
    return DeliveryPersonnel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      aadhaarNumber: json['aadhaar_number'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      vehicleType: json['vehicle_type'] as String,
      vehicleModel: json['vehicle_model'] as String,
      numberPlate: json['number_plate'] as String,
      licenseImageUrl: json['license_image_url'] as String?,
      aadhaarImageUrl: json['aadhaar_image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      assignedOrders: json['assigned_orders'] != null 
          ? List<String>.from(json['assigned_orders'] as List)
          : null,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'state': state,
      'city': city,
      'aadhaar_number': aadhaarNumber,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0], // Date only
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'number_plate': numberPlate,
      'license_image_url': licenseImageUrl,
      'aadhaar_image_url': aadhaarImageUrl,
      'is_available': isAvailable,
      'assigned_orders': assignedOrders,
      'earnings': earnings,
      'is_verified': isVerified,
      'verification_status': verificationStatus,
    };
  }

  // For inserting new records (excludes timestamps)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  // Create a copy with updated fields
  DeliveryPersonnel copyWith({
    String? userId,
    String? name,
    String? email,
    String? fullName,
    String? phone,
    String? state,
    String? city,
    String? aadhaarNumber,
    DateTime? dateOfBirth,
    String? vehicleType,
    String? vehicleModel,
    String? numberPlate,
    String? licenseImageUrl,
    String? aadhaarImageUrl,
    bool? isAvailable,
    List<String>? assignedOrders,
    double? earnings,
    bool? isVerified,
    String? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryPersonnel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      city: city ?? this.city,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      numberPlate: numberPlate ?? this.numberPlate,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      aadhaarImageUrl: aadhaarImageUrl ?? this.aadhaarImageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      earnings: earnings ?? this.earnings,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DeliveryPersonnel(userId: $userId, name: $name, email: $email, phone: $phone)';
  }
}