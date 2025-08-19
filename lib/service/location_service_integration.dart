// lib/service/location_service_integration.dart
import 'package:geolocator/geolocator.dart' as geo;
import 'package:naivedhya_delivery_app/provider/location_settings_provider.dart';
import 'package:naivedhya_delivery_app/service/location_service.dart';

/// Extension to integrate LocationService with LocationProvider settings
extension LocationServiceIntegration on LocationService {
  
  /// Get location accuracy based on user settings
  geo.LocationAccuracy getLocationAccuracyFromProvider(LocationProvider locationProvider) {
    switch (locationProvider.locationAccuracy) {
      case LocationAccuracy.high:
        return geo.LocationAccuracy.bestForNavigation;
      case LocationAccuracy.medium:
        return geo.LocationAccuracy.high;
      case LocationAccuracy.low:
        return geo.LocationAccuracy.medium;
    }
  }

  /// Check if location tracking should be allowed based on user settings
  bool shouldTrackLocation(LocationProvider locationProvider) {
    if (!locationProvider.isLocationEnabled) return false;
    if (!locationProvider.hasLocationPermission) return false;
    
    switch (locationProvider.locationSharingPreference) {
      case LocationSharingPreference.never:
        return false;
      case LocationSharingPreference.whileUsingApp:
        return true; // Will be handled by the app state
      case LocationSharingPreference.always:
        return locationProvider.hasBackgroundLocationPermission;
    }
  }

  /// Check if background location tracking is allowed
  bool shouldTrackBackgroundLocation(LocationProvider locationProvider) {
    return locationProvider.isBackgroundLocationEnabled &&
           locationProvider.hasBackgroundLocationPermission &&
           locationProvider.locationSharingPreference == LocationSharingPreference.always;
  }

  /// Get location settings for the LocationService
  geo.LocationSettings getLocationSettingsFromProvider(LocationProvider locationProvider) {
    return geo.LocationSettings(
      accuracy: getLocationAccuracyFromProvider(locationProvider),
      distanceFilter: _getDistanceFilter(locationProvider.locationAccuracy),
    );
  }

  /// Get distance filter based on accuracy setting
  int _getDistanceFilter(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return 1; // Update every 1 meter
      case LocationAccuracy.medium:
        return 5; // Update every 5 meters
      case LocationAccuracy.low:
        return 10; // Update every 10 meters
    }
  }

  /// Start tracking with provider settings
  Future<bool> startTrackingWithSettings(
    String userId, 
    LocationProvider locationProvider, {
    String? orderId,
  }) async {
    // Check if tracking is allowed
    if (!shouldTrackLocation(locationProvider)) {
      return false;
    }

    // Use the existing startTracking method but with provider settings
    return await startTracking(userId, orderId: orderId);
  }
}

/// Helper class to manage location updates based on user settings
class LocationSettingsManager {
  static const LocationSettingsManager _instance = LocationSettingsManager._internal();
  factory LocationSettingsManager() => _instance;
  const LocationSettingsManager._internal();

  /// Update location service settings when user changes preferences
  Future<void> updateLocationServiceSettings(
    LocationService locationService,
    LocationProvider locationProvider,
  ) async {
    // Stop current tracking if it doesn't match new settings
    if (!locationService.shouldTrackLocation(locationProvider)) {
      locationService.stopTracking();
    }

    // Update location settings
    final _ = locationService.getLocationSettingsFromProvider(locationProvider);
    
    // If you have a method to update settings in LocationService, call it here
    // locationService.updateSettings(settings);
  }

  /// Get battery optimization message based on accuracy setting
  String getBatteryOptimizationMessage(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return 'High accuracy will use more battery but provide better tracking';
      case LocationAccuracy.medium:
        return 'Balanced accuracy setting for good tracking with moderate battery usage';
      case LocationAccuracy.low:
        return 'Low accuracy saves battery but may affect delivery tracking quality';
    }
  }

  /// Check if location settings are optimal for delivery
  bool areSettingsOptimalForDelivery(LocationProvider locationProvider) {
    return locationProvider.isLocationEnabled &&
           locationProvider.hasLocationPermission &&
           locationProvider.shareLocationWithCustomers &&
           locationProvider.locationSharingPreference != LocationSharingPreference.never;
  }

  /// Get recommendations for better delivery performance
  List<String> getSettingsRecommendations(LocationProvider locationProvider) {
    List<String> recommendations = [];

    if (!locationProvider.isLocationEnabled) {
      recommendations.add('Enable location services for delivery tracking');
    }

    if (!locationProvider.hasLocationPermission) {
      recommendations.add('Grant location permission for accurate delivery tracking');
    }

    if (!locationProvider.hasBackgroundLocationPermission) {
      recommendations.add('Enable background location for continuous tracking');
    }

    if (!locationProvider.shareLocationWithCustomers) {
      recommendations.add('Enable location sharing to keep customers informed');
    }

    if (locationProvider.locationAccuracy == LocationAccuracy.low) {
      recommendations.add('Consider using higher accuracy for better delivery tracking');
    }

    if (locationProvider.locationSharingPreference == LocationSharingPreference.never) {
      recommendations.add('Allow location sharing for better customer experience');
    }

    return recommendations;
  }
}

/// Extension methods for LocationProvider
extension LocationProviderHelpers on LocationProvider {
  /// Quick check methods
  bool get isOptimalForDelivery => LocationSettingsManager().areSettingsOptimalForDelivery(this);
  
  List<String> get recommendations => LocationSettingsManager().getSettingsRecommendations(this);
  
  String get batteryOptimizationMessage => 
      LocationSettingsManager().getBatteryOptimizationMessage(locationAccuracy);
}