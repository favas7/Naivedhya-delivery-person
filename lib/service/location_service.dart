// lib/services/location_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  Position? _currentPosition;
  bool _isTracking = false;
  bool _hasPermission = false;
  StreamSubscription<Position>? _positionStream;
  Timer? _locationUpdateTimer;
  
  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get hasPermission => _hasPermission;

  // Initialize location service
  Future<bool> initialize() async {
    try {
      _hasPermission = await _checkLocationPermission();
      if (_hasPermission) {
        await _getCurrentLocation();
      }
      return _hasPermission;
    } catch (e) {
      debugPrint('Error initializing location service: $e');
      return false;
    }
  }

  // Check and request location permissions
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      // Open app settings
      await openAppSettings();
      return false;
    }

    // For background location tracking (Android)
    if (permission == LocationPermission.whileInUse) {
      // Request always permission for background tracking
      await Permission.locationAlways.request();
    }

    return true;
  }

  // Get current location once
  Future<Position?> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  // Start location tracking
  Future<bool> startTracking(String deliveryPartnerId, {String? orderId}) async {
    if (_isTracking) return true;
    
    if (!_hasPermission) {
      _hasPermission = await _checkLocationPermission();
      if (!_hasPermission) return false;
    }

    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _currentPosition = position;
          _updateLocationInDatabase(deliveryPartnerId, position, orderId);
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Location stream error: $error');
        },
      );

      // Also update location every 30 seconds even if position hasn't changed much
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (timer) {
          if (_currentPosition != null) {
            _updateLocationInDatabase(deliveryPartnerId, _currentPosition!, orderId);
          }
        },
      );

      _isTracking = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      return false;
    }
  }

  // Stop location tracking
  void stopTracking() {
    _positionStream?.cancel();
    _locationUpdateTimer?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  // Update location in database
  Future<void> _updateLocationInDatabase(
    String deliveryPartnerId, 
    Position position, 
    String? orderId
  ) async {
    try {
      // Deactivate previous location records
      await _supabase
          .from('delivery_locations')
          .update({'is_active': false})
          .eq('delivery_partner_id', deliveryPartnerId)
          .eq('is_active', true);

      // Insert new location record
      await _supabase.from('delivery_locations').insert({
        'delivery_partner_id': deliveryPartnerId,
        'order_id': orderId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'speed': position.speed,
        'heading': position.heading,
        'timestamp': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      debugPrint('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Error updating location in database: $e');
    }
  }

  // Get distance between two points
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Get bearing between two points
  double getBearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Get delivery partner's current location from database
  Future<Map<String, dynamic>?> getDeliveryPartnerLocation(String deliveryPartnerId) async {
    try {
      final response = await _supabase
          .from('delivery_locations')
          .select()
          .eq('delivery_partner_id', deliveryPartnerId)
          .eq('is_active', true)
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error getting delivery partner location: $e');
      return null;
    }
  }

  // Get location history for a delivery partner
  Future<List<Map<String, dynamic>>> getLocationHistory(
    String deliveryPartnerId, {
    String? orderId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  }) async {
    try {
      var query = _supabase
          .from('delivery_locations')
          .select()
          .eq('delivery_partner_id', deliveryPartnerId);

      if (orderId != null) {
        query = query.eq('order_id', orderId);
      }

      if (fromDate != null) {
        query = query.gte('timestamp', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('timestamp', toDate.toIso8601String());
      }

      final response = await query
          .order('timestamp', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting location history: $e');
      return [];
    }
  }

  // Clean up old location records (call this periodically)
  Future<void> cleanupOldLocations({int daysToKeep = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      await _supabase
          .from('delivery_locations')
          .delete()
          .lt('timestamp', cutoffDate.toIso8601String());
          
      debugPrint('Cleaned up location records older than $daysToKeep days');
    } catch (e) {
      debugPrint('Error cleaning up old locations: $e');
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}