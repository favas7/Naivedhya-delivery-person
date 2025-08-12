import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // User profile data
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Constants
  static const String tableName = 'delivery_personnel';
  static const String storageBucket = 'delivery-documents';

  // Getters
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _userProfile != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Ensure storage bucket exists - ADD THIS NEW METHOD
  Future<bool> _ensureBucketExists() async {
    try {
      // Try to list files in bucket to check if it exists
      await _supabase.storage.from(storageBucket).list();
      return true;
    } catch (e) {
      // If bucket doesn't exist, create it
      try {
        await _supabase.storage.createBucket(
          storageBucket,
          BucketOptions(
            public: true,
            allowedMimeTypes: ['image/jpeg', 'image/png', 'image/jpg'],
            fileSizeLimit: '5242880', // 5MB
          ),
        );
        print('Storage bucket created successfully: $storageBucket');
        return true;
      } catch (createError) {
        print('Failed to create storage bucket: $createError');
        _setError('Failed to create storage bucket. Please contact support.');
        return false;
      }
    }
  }

Future<bool> saveUserProfile({
  required String userId,
  required String name,
  required String email,
  required String fullName,
  required String phone,
  required String state,
  required String city,
  required String aadhaarNumber,
  required DateTime dateOfBirth,
  required String vehicleType,
  required String vehicleModel,
  required String numberPlate,
  String? licenseImagePath,
  String? aadhaarImagePath,
}) async {
  try {
    _setLoading(true);
    _setError(null);

    // Check for existing data
    final existingData = await _checkExistingData(email, aadhaarNumber, numberPlate);
    if (existingData != null) {
      _setError(existingData);
      return false;
    }

    // Upload images if provided
    String? licenseImageUrl;
    String? aadhaarImageUrl;

    if (licenseImagePath != null) {
      licenseImageUrl = await _uploadImage(userId, licenseImagePath, 'license');
      if (licenseImageUrl == null) {
        _setError('Failed to upload license image');
        return false;
      }
    }

    if (aadhaarImagePath != null) {
      aadhaarImageUrl = await _uploadImage(userId, aadhaarImagePath, 'aadhaar');
      if (aadhaarImageUrl == null) {
        _setError('Failed to upload Aadhaar image');
        return false;
      }
    }

    // Save to database
    final profileData = {
      'user_id': userId,
      'name': name,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'state': state,
      'city': city,
      'aadhaar_number': aadhaarNumber,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'number_plate': numberPlate,
      'license_image_url': licenseImageUrl,
      'aadhaar_image_url': aadhaarImageUrl,
      'is_available': true,
      'earnings': 0.0,
      'is_verified': false,
      'verification_status': 'pending',
    };

    final response = await _supabase
        .from(tableName)
        .insert(profileData)
        .select()
        .single();

    _userProfile = response;
    notifyListeners();
    return true;

  } catch (e) {
    String errorMessage = 'Failed to save profile';
    
    if (e is PostgrestException) {
      errorMessage = _handlePostgrestException(e);
    } else if (e is StorageException) {
      errorMessage = 'Storage error: ${e.message} (Check if bucket exists and policies are set)';
    } else {
      errorMessage = 'Failed to save profile: ${e.toString()}';
    }
    
    _setError(errorMessage);
    return false;
  } finally {
    _setLoading(false);
  }
}

Future<String?> _uploadImage(String userId, String imagePath, String imageType) async {
  try {
    final file = File(imagePath);
    
    if (!await file.exists()) {
      _setError('Image file not found: $imagePath');
      return null;
    }

    final fileExt = imagePath.split('.').last.toLowerCase();
    final fileName = '$userId/${imageType}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    print('Uploading image to bucket: $storageBucket, path: $fileName');

    // Upload file
    final uploadResponse = await _supabase.storage
        .from(storageBucket)
        .upload(fileName, file);

    print('Upload response: $uploadResponse');

    // Get public URL
    final imageUrl = _supabase.storage
        .from(storageBucket)
        .getPublicUrl(fileName);

    print('Image uploaded successfully: $imageUrl');
    return imageUrl;

  } on StorageException catch (e) {
    print('StorageException during upload: ${e.message}, status: ${e.statusCode}');
    _setError('Storage error: ${e.message}');
    return null;
  } catch (e) {
    print('Unexpected error during upload: $e');
    _setError('Failed to upload $imageType image: ${e.toString()}');
    return null;
  }
}


  /// Get user profile by user ID
  Future<bool> getUserProfile(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        _userProfile = response;
        notifyListeners();
        return true;
      } else {
        _setError('Profile not found');
        return false;
      }

    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? fullName,
    String? phone,
    String? state,
    String? city,
    String? vehicleType,
    String? vehicleModel,
    String? numberPlate,
    String? licenseImagePath,
    String? aadhaarImagePath,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Ensure bucket exists if uploading images
      if (licenseImagePath != null || aadhaarImagePath != null) {
        if (!await _ensureBucketExists()) {
          return false;
        }
      }

      Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add non-null values to update data
      if (name != null) updateData['name'] = name;
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (state != null) updateData['state'] = state;
      if (city != null) updateData['city'] = city;
      if (vehicleType != null) updateData['vehicle_type'] = vehicleType;
      if (vehicleModel != null) updateData['vehicle_model'] = vehicleModel;
      if (numberPlate != null) updateData['number_plate'] = numberPlate;

      // Handle image updates
      if (licenseImagePath != null) {
        final imageUrl = await _uploadImage(userId, licenseImagePath, 'license');
        if (imageUrl != null) {
          updateData['license_image_url'] = imageUrl;
        }
      }

      if (aadhaarImagePath != null) {
        final imageUrl = await _uploadImage(userId, aadhaarImagePath, 'aadhaar');
        if (imageUrl != null) {
          updateData['aadhaar_image_url'] = imageUrl;
        }
      }

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      _userProfile = response;
      notifyListeners();
      return true;

    } catch (e) {
      String errorMessage = 'Failed to update profile';
      
      if (e is PostgrestException) {
        errorMessage = _handlePostgrestException(e);
      } else {
        errorMessage = 'Failed to update profile: ${e.toString()}';
      }
      
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update availability status
  Future<bool> updateAvailability(String userId, bool isAvailable) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from(tableName)
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      // Update local data
      if (_userProfile != null) {
        _userProfile!['is_available'] = isAvailable;
        _userProfile!['updated_at'] = DateTime.now().toIso8601String();
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to update availability: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Legacy method for backward compatibility
  Future<String?> uploadImage(String filePath, String fileName) async {
    try {
      if (!await _ensureBucketExists()) {
        return null;
      }

      final file = File(filePath);
      
      if (!await file.exists()) {
        _setError('File not found');
        return null;
      }

      final uniqueFileName = '${fileName}_${DateTime.now().millisecondsSinceEpoch}';
      
      await _supabase.storage
          .from(storageBucket)
          .upload(uniqueFileName, file);

      final imageUrl = _supabase.storage
          .from(storageBucket)
          .getPublicUrl(uniqueFileName);

      return imageUrl;

    } catch (e) {
      _setError('Failed to upload image: ${e.toString()}');
      return null;
    }
  }

  /// Check for existing data before insert
  Future<String?> _checkExistingData(String email, String aadhaarNumber, String numberPlate) async {
    try {
      // Check email
      final emailCheck = await _supabase
          .from(tableName)
          .select('user_id')
          .eq('email', email)
          .maybeSingle();
      
      if (emailCheck != null) {
        return 'This email is already registered';
      }

      // Check Aadhaar
      final aadhaarCheck = await _supabase
          .from(tableName)
          .select('user_id')
          .eq('aadhaar_number', aadhaarNumber)
          .maybeSingle();
      
      if (aadhaarCheck != null) {
        return 'This Aadhaar number is already registered';
      }

      // Check number plate
      final plateCheck = await _supabase
          .from(tableName)
          .select('user_id')
          .eq('number_plate', numberPlate)
          .maybeSingle();
      
      if (plateCheck != null) {
        return 'This number plate is already registered';
      }

      return null;
    } catch (e) {
      print('Error checking existing data: $e');
      return null;
    }
  }

  /// Handle PostgrestException and return user-friendly error message
  String _handlePostgrestException(PostgrestException e) {
    switch (e.code) {
      case '23505':
        if (e.message.contains('email')) {
          return 'This email is already registered';
        } else if (e.message.contains('aadhaar')) {
          return 'This Aadhaar number is already registered';
        } else if (e.message.contains('number_plate')) {
          return 'This number plate is already registered';
        }
        return 'This information is already registered';
      case '23503':
        return 'Invalid user reference';
      case '23502':
        return 'Required field is missing';
      case '42P01':
        return 'Database table not found. Please contact support.';
      default:
        return 'Database error: ${e.message}';
    }
  }

  /// Clear user data (for logout)
  void clearUserData() {
    _userProfile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Refresh user profile from database
  Future<bool> refreshProfile() async {
    if (_userProfile == null) return false;
    return await getUserProfile(_userProfile!['user_id']);
  }

  /// Get user availability status
  bool get isAvailable => _userProfile?['is_available'] ?? true;

  /// Get user verification status
  String get verificationStatus => _userProfile?['verification_status'] ?? 'pending';

  /// Get user earnings
  double get earnings => (_userProfile?['earnings'] ?? 0.0).toDouble();
}