// lib/services/delivery_personnel_service.dart

import 'dart:io';
import 'package:naivedhya_delivery_app/model/delivery_personnel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliveryPersonnelService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'delivery_personnel';
  static const String storageBucket = 'delivery-documents';

  /// Create a new delivery personnel profile
  Future<DeliveryPersonnel?> createProfile({
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
      // Upload images first if provided
      String? licenseImageUrl;
      String? aadhaarImageUrl;

      if (licenseImagePath != null) {
        licenseImageUrl = await _uploadImage(
          userId, 
          licenseImagePath, 
          'license'
        );
      }

      if (aadhaarImagePath != null) {
        aadhaarImageUrl = await _uploadImage(
          userId, 
          aadhaarImagePath, 
          'aadhaar'
        );
      }

      // Create delivery personnel object
      final deliveryPersonnel = DeliveryPersonnel(
        userId: userId,
        name: name,
        email: email,
        fullName: fullName,
        phone: phone,
        state: state,
        city: city,
        aadhaarNumber: aadhaarNumber,
        dateOfBirth: dateOfBirth,
        vehicleType: vehicleType,
        vehicleModel: vehicleModel,
        numberPlate: numberPlate,
        licenseImageUrl: licenseImageUrl,
        aadhaarImageUrl: aadhaarImageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Insert into database
      final response = await _supabase
          .from(tableName)
          .insert(deliveryPersonnel.toInsertJson())
          .select()
          .single();

      return DeliveryPersonnel.fromJson(response);
    } on PostgrestException catch (e) {
      throw _handlePostgrestException(e);
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Get delivery personnel profile by user ID
  Future<DeliveryPersonnel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      
      return DeliveryPersonnel.fromJson(response);
    } on PostgrestException catch (e) {
      throw _handlePostgrestException(e);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Update delivery personnel profile
  Future<DeliveryPersonnel?> updateProfile({
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
    bool? isAvailable,
  }) async {
    try {
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
      if (isAvailable != null) updateData['is_available'] = isAvailable;

      // Handle image updates
      if (licenseImagePath != null) {
        final imageUrl = await _uploadImage(userId, licenseImagePath, 'license');
        updateData['license_image_url'] = imageUrl;
      }

      if (aadhaarImagePath != null) {
        final imageUrl = await _uploadImage(userId, aadhaarImagePath, 'aadhaar');
        updateData['aadhaar_image_url'] = imageUrl;
      }

      final response = await _supabase
          .from(tableName)
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      return DeliveryPersonnel.fromJson(response);
    } on PostgrestException catch (e) {
      throw _handlePostgrestException(e);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update availability status
  Future<void> updateAvailability(String userId, bool isAvailable) async {
    try {
      await _supabase
          .from(tableName)
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw _handlePostgrestException(e);
    } catch (e) {
      throw Exception('Failed to update availability: $e');
    }
  }

  /// Delete delivery personnel profile
  Future<void> deleteProfile(String userId) async {
    try {
      // Delete associated images first
      await _deleteUserImages(userId);
      
      // Delete profile
      await _supabase
          .from(tableName)
          .delete()
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw _handlePostgrestException(e);
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  /// Check if email already exists
  Future<bool> emailExists(String email) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('user_id')
          .eq('email', email)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if Aadhaar number already exists
  Future<bool> aadhaarExists(String aadhaarNumber) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('user_id')
          .eq('aadhaar_number', aadhaarNumber)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if number plate already exists
  Future<bool> numberPlateExists(String numberPlate) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('user_id')
          .eq('number_plate', numberPlate)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Upload image to Supabase Storage
  Future<String> _uploadImage(String userId, String imagePath, String imageType) async {
    try {
      final file = File(imagePath);
      final fileExt = imagePath.split('.').last.toLowerCase();
      final fileName = '$userId/${imageType}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage
          .from(storageBucket)
          .upload(fileName, file);

      final imageUrl = _supabase.storage
          .from(storageBucket)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete all images for a user
  Future<void> _deleteUserImages(String userId) async {
    try {
      final files = await _supabase.storage
          .from(storageBucket)
          .list(path: userId);
      
      if (files.isNotEmpty) {
        final filePaths = files.map((file) => '$userId/${file.name}').toList();
        await _supabase.storage
            .from(storageBucket)
            .remove(filePaths);
      }
    } catch (e) {
      // Don't throw error for image deletion failures
      print('Warning: Failed to delete user images: $e');
    }
  }

  /// Handle PostgrestException and return user-friendly error message
  String _handlePostgrestException(PostgrestException e) {
    switch (e.code) {
      case '23505': // unique_violation
        if (e.message.contains('email')) {
          return 'This email is already registered';
        } else if (e.message.contains('aadhaar')) {
          return 'This Aadhaar number is already registered';
        } else if (e.message.contains('number_plate')) {
          return 'This number plate is already registered';
        }
        return 'This information is already registered';
      case '23503': // foreign_key_violation
        return 'Invalid user reference';
      case '23502': // not_null_violation
        return 'Required field is missing';
      default:
        return 'Database error: ${e.message}';
    }
  }
}