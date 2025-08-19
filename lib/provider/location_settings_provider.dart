// lib/provider/location_provider.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LocationAccuracy { high, medium, low }
enum LocationSharingPreference { always, whileUsingApp, never }

class LocationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Location Settings
  bool _isLocationEnabled = false;
  bool _isBackgroundLocationEnabled = false;
  LocationAccuracy _locationAccuracy = LocationAccuracy.high;
  LocationSharingPreference _locationSharingPreference = LocationSharingPreference.whileUsingApp;
  bool _shareLocationWithCustomers = true;
  bool _isLocationHistoryEnabled = false;
  
  // Permission Status
  PermissionStatus _locationPermissionStatus = PermissionStatus.denied;
  PermissionStatus _backgroundLocationPermissionStatus = PermissionStatus.denied;
  
  // Loading states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isBackgroundLocationEnabled => _isBackgroundLocationEnabled;
  LocationAccuracy get locationAccuracy => _locationAccuracy;
  LocationSharingPreference get locationSharingPreference => _locationSharingPreference;
  bool get shareLocationWithCustomers => _shareLocationWithCustomers;
  bool get isLocationHistoryEnabled => _isLocationHistoryEnabled;
  PermissionStatus get locationPermissionStatus => _locationPermissionStatus;
  PermissionStatus get backgroundLocationPermissionStatus => _backgroundLocationPermissionStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Permission status helpers
  bool get hasLocationPermission => 
      _locationPermissionStatus == PermissionStatus.granted;
  
  bool get hasBackgroundLocationPermission => 
      _backgroundLocationPermissionStatus == PermissionStatus.granted;

  LocationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSettings();
    await _checkPermissions();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isLocationEnabled = prefs.getBool('location_enabled') ?? false;
      _isBackgroundLocationEnabled = prefs.getBool('background_location_enabled') ?? false;
      _shareLocationWithCustomers = prefs.getBool('share_location_with_customers') ?? true;
      _isLocationHistoryEnabled = prefs.getBool('location_history_enabled') ?? false;
      
      // Load location accuracy
      final accuracyIndex = prefs.getInt('location_accuracy') ?? 0;
      _locationAccuracy = LocationAccuracy.values[accuracyIndex];
      
      // Load location sharing preference
      final sharingIndex = prefs.getInt('location_sharing_preference') ?? 1;
      _locationSharingPreference = LocationSharingPreference.values[sharingIndex];
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
      notifyListeners();
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('location_enabled', _isLocationEnabled);
      await prefs.setBool('background_location_enabled', _isBackgroundLocationEnabled);
      await prefs.setBool('share_location_with_customers', _shareLocationWithCustomers);
      await prefs.setBool('location_history_enabled', _isLocationHistoryEnabled);
      await prefs.setInt('location_accuracy', _locationAccuracy.index);
      await prefs.setInt('location_sharing_preference', _locationSharingPreference.index);
      
    } catch (e) {
      _errorMessage = 'Failed to save settings: $e';
      notifyListeners();
    }
  }

  // Check current permission status
  Future<void> _checkPermissions() async {
    try {
      _locationPermissionStatus = await Permission.location.status;
      _backgroundLocationPermissionStatus = await Permission.locationAlways.status;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to check permissions: $e';
      notifyListeners();
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final status = await Permission.location.request();
      _locationPermissionStatus = status;
      
      if (status == PermissionStatus.granted) {
        _isLocationEnabled = true;
        await _saveSettings();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return status == PermissionStatus.granted;
    } catch (e) {
      _errorMessage = 'Failed to request location permission: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Request background location permission
  Future<bool> requestBackgroundLocationPermission() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // First ensure we have basic location permission
      if (_locationPermissionStatus != PermissionStatus.granted) {
        final locationGranted = await requestLocationPermission();
        if (!locationGranted) {
          _isLoading = false;
          return false;
        }
      }

      final status = await Permission.locationAlways.request();
      _backgroundLocationPermissionStatus = status;
      
      if (status == PermissionStatus.granted) {
        _isBackgroundLocationEnabled = true;
        await _saveSettings();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return status == PermissionStatus.granted;
    } catch (e) {
      _errorMessage = 'Failed to request background location permission: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle location enabled
  Future<void> setLocationEnabled(bool enabled) async {
    if (enabled && !hasLocationPermission) {
      final granted = await requestLocationPermission();
      if (!granted) return;
    }
    
    _isLocationEnabled = enabled;
    await _saveSettings();
    await _syncSettingsToServer();
    notifyListeners();
  }

  // Toggle background location
  Future<void> setBackgroundLocationEnabled(bool enabled) async {
    if (enabled && !hasBackgroundLocationPermission) {
      final granted = await requestBackgroundLocationPermission();
      if (!granted) return;
    }
    
    _isBackgroundLocationEnabled = enabled;
    await _saveSettings();
    await _syncSettingsToServer();
    notifyListeners();
  }

  // Set location accuracy
  Future<void> setLocationAccuracy(LocationAccuracy accuracy) async {
    _locationAccuracy = accuracy;
    await _saveSettings();
    await _syncSettingsToServer();
    notifyListeners();
  }

  // Set location sharing preference
  Future<void> setLocationSharingPreference(LocationSharingPreference preference) async {
    _locationSharingPreference = preference;
    await _saveSettings();
    await _syncSettingsToServer();
    notifyListeners();
  }

  // Toggle share location with customers
  Future<void> setShareLocationWithCustomers(bool share) async {
    _shareLocationWithCustomers = share;
    await _saveSettings();
    await _syncSettingsToServer();
    notifyListeners();
  }

  // Toggle location history
  Future<void> setLocationHistoryEnabled(bool enabled) async {
    _isLocationHistoryEnabled = enabled;
    await _saveSettings();
    await _syncSettingsToServer();
    notifyListeners();
  }

  // Sync settings to Supabase
  Future<void> _syncSettingsToServer() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('delivery_partner_settings').upsert({
        'user_id': user.id,
        'location_enabled': _isLocationEnabled,
        'background_location_enabled': _isBackgroundLocationEnabled,
        'location_accuracy': _locationAccuracy.name,
        'location_sharing_preference': _locationSharingPreference.name,
        'share_location_with_customers': _shareLocationWithCustomers,
        'location_history_enabled': _isLocationHistoryEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't show to user for background sync
      debugPrint('Failed to sync location settings to server: $e');
    }
  }

  // Load settings from server
  Future<void> loadSettingsFromServer() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('delivery_partner_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        _isLocationEnabled = response['location_enabled'] ?? false;
        _isBackgroundLocationEnabled = response['background_location_enabled'] ?? false;
        _shareLocationWithCustomers = response['share_location_with_customers'] ?? true;
        _isLocationHistoryEnabled = response['location_history_enabled'] ?? false;
        
        // Parse enums
        final accuracyString = response['location_accuracy'] ?? 'high';
        _locationAccuracy = LocationAccuracy.values.firstWhere(
          (e) => e.name == accuracyString,
          orElse: () => LocationAccuracy.high,
        );
        
        final sharingString = response['location_sharing_preference'] ?? 'whileUsingApp';
        _locationSharingPreference = LocationSharingPreference.values.firstWhere(
          (e) => e.name == sharingString,
          orElse: () => LocationSharingPreference.whileUsingApp,
        );

        // Save to local storage
        await _saveSettings();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load settings from server: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get location accuracy description
  String getLocationAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return 'Best accuracy, more battery usage';
      case LocationAccuracy.medium:
        return 'Balanced accuracy and battery usage';
      case LocationAccuracy.low:
        return 'Lower accuracy, saves battery';
    }
  }

  // Get location sharing preference description
  String getLocationSharingDescription(LocationSharingPreference preference) {
    switch (preference) {
      case LocationSharingPreference.always:
        return 'Share location even when app is closed';
      case LocationSharingPreference.whileUsingApp:
        return 'Share location only when app is open';
      case LocationSharingPreference.never:
        return 'Never share location automatically';
    }
  }
}