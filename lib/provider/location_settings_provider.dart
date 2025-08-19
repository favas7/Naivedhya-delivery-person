// lib/provider/location_provider.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LocationAccuracy { high, medium, low }
enum LocationSharingPreference { always, whileUsingApp, never }
enum NotificationPriority { high, medium, low }

class LocationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Location Settings
  bool _isLocationEnabled = false;
  bool _isBackgroundLocationEnabled = false;
  LocationAccuracy _locationAccuracy = LocationAccuracy.high;
  LocationSharingPreference _locationSharingPreference = LocationSharingPreference.whileUsingApp;
  bool _shareLocationWithCustomers = true;
  bool _isLocationHistoryEnabled = false;
  
  // Mobile Settings - Notifications
  bool _notificationsEnabled = true;
  bool _deliveryNotifications = true;
  bool _orderNotifications = true;
  bool _systemNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  NotificationPriority _notificationPriority = NotificationPriority.high;
  
  // Mobile Settings - Battery Optimization
  bool _batteryOptimizationDisabled = false;
  bool _autoStartEnabled = false;
  bool _backgroundAppRefreshEnabled = true;
  bool _lowPowerModeAware = true;
  
  // Permission Status
  PermissionStatus _locationPermissionStatus = PermissionStatus.denied;
  PermissionStatus _backgroundLocationPermissionStatus = PermissionStatus.denied;
  PermissionStatus _notificationPermissionStatus = PermissionStatus.denied;
  
  // Loading states
  bool _isLoading = false;
  bool _isServerSyncEnabled = true; // Toggle for server sync
  String? _errorMessage;

  // Location Getters
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isBackgroundLocationEnabled => _isBackgroundLocationEnabled;
  LocationAccuracy get locationAccuracy => _locationAccuracy;
  LocationSharingPreference get locationSharingPreference => _locationSharingPreference;
  bool get shareLocationWithCustomers => _shareLocationWithCustomers;
  bool get isLocationHistoryEnabled => _isLocationHistoryEnabled;
  
  // Mobile Settings Getters - Notifications
  bool get notificationsEnabled => _notificationsEnabled;
  bool get deliveryNotifications => _deliveryNotifications;
  bool get orderNotifications => _orderNotifications;
  bool get systemNotifications => _systemNotifications;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  NotificationPriority get notificationPriority => _notificationPriority;
  
  // Mobile Settings Getters - Battery
  bool get batteryOptimizationDisabled => _batteryOptimizationDisabled;
  bool get autoStartEnabled => _autoStartEnabled;
  bool get backgroundAppRefreshEnabled => _backgroundAppRefreshEnabled;
  bool get lowPowerModeAware => _lowPowerModeAware;
  
  // Permission Status Getters
  PermissionStatus get locationPermissionStatus => _locationPermissionStatus;
  PermissionStatus get backgroundLocationPermissionStatus => _backgroundLocationPermissionStatus;
  PermissionStatus get notificationPermissionStatus => _notificationPermissionStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Permission status helpers
  bool get hasLocationPermission => 
      _locationPermissionStatus == PermissionStatus.granted;
  
  bool get hasBackgroundLocationPermission => 
      _backgroundLocationPermissionStatus == PermissionStatus.granted;
      
  bool get hasNotificationPermission => 
      _notificationPermissionStatus == PermissionStatus.granted;

  LocationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSettings();
    await _checkPermissions();
    await _checkServerConnection();
  }

  // Check if server/table exists and is accessible
  Future<void> _checkServerConnection() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _isServerSyncEnabled = false;
        return;
      }

      // Try to access the table - this will throw an error if table doesn't exist
      await _supabase
          .from('delivery_partner_settings')
          .select('id')
          .eq('user_id', user.id)
          .limit(1);
      
      _isServerSyncEnabled = true;
    } catch (e) {
      // Table doesn't exist or other error - disable server sync
      _isServerSyncEnabled = false;
      debugPrint('Server sync disabled: $e');
    }
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Location settings
      _isLocationEnabled = prefs.getBool('location_enabled') ?? false;
      _isBackgroundLocationEnabled = prefs.getBool('background_location_enabled') ?? false;
      _shareLocationWithCustomers = prefs.getBool('share_location_with_customers') ?? true;
      _isLocationHistoryEnabled = prefs.getBool('location_history_enabled') ?? false;
      
      // Notification settings
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _deliveryNotifications = prefs.getBool('delivery_notifications') ?? true;
      _orderNotifications = prefs.getBool('order_notifications') ?? true;
      _systemNotifications = prefs.getBool('system_notifications') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      
      // Battery optimization settings
      _batteryOptimizationDisabled = prefs.getBool('battery_optimization_disabled') ?? false;
      _autoStartEnabled = prefs.getBool('auto_start_enabled') ?? false;
      _backgroundAppRefreshEnabled = prefs.getBool('background_app_refresh_enabled') ?? true;
      _lowPowerModeAware = prefs.getBool('low_power_mode_aware') ?? true;
      
      // Load enums
      final accuracyIndex = prefs.getInt('location_accuracy') ?? 0;
      if (accuracyIndex < LocationAccuracy.values.length) {
        _locationAccuracy = LocationAccuracy.values[accuracyIndex];
      }
      
      final sharingIndex = prefs.getInt('location_sharing_preference') ?? 1;
      if (sharingIndex < LocationSharingPreference.values.length) {
        _locationSharingPreference = LocationSharingPreference.values[sharingIndex];
      }
      
      final notificationPriorityIndex = prefs.getInt('notification_priority') ?? 0;
      if (notificationPriorityIndex < NotificationPriority.values.length) {
        _notificationPriority = NotificationPriority.values[notificationPriorityIndex];
      }
      
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
      
      // Location settings
      await prefs.setBool('location_enabled', _isLocationEnabled);
      await prefs.setBool('background_location_enabled', _isBackgroundLocationEnabled);
      await prefs.setBool('share_location_with_customers', _shareLocationWithCustomers);
      await prefs.setBool('location_history_enabled', _isLocationHistoryEnabled);
      await prefs.setInt('location_accuracy', _locationAccuracy.index);
      await prefs.setInt('location_sharing_preference', _locationSharingPreference.index);
      
      // Notification settings
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('delivery_notifications', _deliveryNotifications);
      await prefs.setBool('order_notifications', _orderNotifications);
      await prefs.setBool('system_notifications', _systemNotifications);
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('vibration_enabled', _vibrationEnabled);
      await prefs.setInt('notification_priority', _notificationPriority.index);
      
      // Battery optimization settings
      await prefs.setBool('battery_optimization_disabled', _batteryOptimizationDisabled);
      await prefs.setBool('auto_start_enabled', _autoStartEnabled);
      await prefs.setBool('background_app_refresh_enabled', _backgroundAppRefreshEnabled);
      await prefs.setBool('low_power_mode_aware', _lowPowerModeAware);
      
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
      _notificationPermissionStatus = await Permission.notification.status;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to check permissions: $e';
      notifyListeners();
    }
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final status = await Permission.notification.request();
      _notificationPermissionStatus = status;
      
      if (status == PermissionStatus.granted) {
        _notificationsEnabled = true;
        await _saveSettings();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return status == PermissionStatus.granted;
    } catch (e) {
      _errorMessage = 'Failed to request notification permission: $e';
      _isLoading = false;
      notifyListeners();
      return false;
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

  // Location Settings Methods
  Future<void> setLocationEnabled(bool enabled) async {
    if (enabled && !hasLocationPermission) {
      final granted = await requestLocationPermission();
      if (!granted) return;
    }
    
    _isLocationEnabled = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setBackgroundLocationEnabled(bool enabled) async {
    if (enabled && !hasBackgroundLocationPermission) {
      final granted = await requestBackgroundLocationPermission();
      if (!granted) return;
    }
    
    _isBackgroundLocationEnabled = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setLocationAccuracy(LocationAccuracy accuracy) async {
    _locationAccuracy = accuracy;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setLocationSharingPreference(LocationSharingPreference preference) async {
    _locationSharingPreference = preference;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setShareLocationWithCustomers(bool share) async {
    _shareLocationWithCustomers = share;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setLocationHistoryEnabled(bool enabled) async {
    _isLocationHistoryEnabled = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  // Notification Settings Methods
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled && !hasNotificationPermission) {
      final granted = await requestNotificationPermission();
      if (!granted) return;
    }
    
    _notificationsEnabled = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setDeliveryNotifications(bool enabled) async {
    _deliveryNotifications = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setOrderNotifications(bool enabled) async {
    _orderNotifications = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setSystemNotifications(bool enabled) async {
    _systemNotifications = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setNotificationPriority(NotificationPriority priority) async {
    _notificationPriority = priority;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  // Battery Optimization Methods
  Future<void> setBatteryOptimizationDisabled(bool disabled) async {
    _batteryOptimizationDisabled = disabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setAutoStartEnabled(bool enabled) async {
    _autoStartEnabled = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setBackgroundAppRefreshEnabled(bool enabled) async {
    _backgroundAppRefreshEnabled = enabled;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  Future<void> setLowPowerModeAware(bool aware) async {
    _lowPowerModeAware = aware;
    await _saveSettings();
    if (_isServerSyncEnabled) {
      await _syncSettingsToServer();
    }
    notifyListeners();
  }

  // Sync settings to Supabase
  Future<void> _syncSettingsToServer() async {
    if (!_isServerSyncEnabled) return;
    
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('delivery_partner_settings').upsert({
        'user_id': user.id,
        // Location settings
        'location_enabled': _isLocationEnabled,
        'background_location_enabled': _isBackgroundLocationEnabled,
        'location_accuracy': _locationAccuracy.name,
        'location_sharing_preference': _locationSharingPreference.name,
        'share_location_with_customers': _shareLocationWithCustomers,
        'location_history_enabled': _isLocationHistoryEnabled,
        // Notification settings
        'notifications_enabled': _notificationsEnabled,
        'delivery_notifications': _deliveryNotifications,
        'order_notifications': _orderNotifications,
        'system_notifications': _systemNotifications,
        'sound_enabled': _soundEnabled,
        'vibration_enabled': _vibrationEnabled,
        'notification_priority': _notificationPriority.name,
        // Battery settings
        'battery_optimization_disabled': _batteryOptimizationDisabled,
        'auto_start_enabled': _autoStartEnabled,
        'background_app_refresh_enabled': _backgroundAppRefreshEnabled,
        'low_power_mode_aware': _lowPowerModeAware,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // If sync fails, disable it temporarily
      _isServerSyncEnabled = false;
      debugPrint('Failed to sync settings to server: $e');
    }
  }

  // Load settings from server
  Future<void> loadSettingsFromServer() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _isLoading = false;
        return;
      }

      if (!_isServerSyncEnabled) {
        // Check if server is available now
        await _checkServerConnection();
        if (!_isServerSyncEnabled) {
          _isLoading = false;
          return;
        }
      }

      final response = await _supabase
          .from('delivery_partner_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        // Location settings
        _isLocationEnabled = response['location_enabled'] ?? false;
        _isBackgroundLocationEnabled = response['background_location_enabled'] ?? false;
        _shareLocationWithCustomers = response['share_location_with_customers'] ?? true;
        _isLocationHistoryEnabled = response['location_history_enabled'] ?? false;
        
        // Notification settings
        _notificationsEnabled = response['notifications_enabled'] ?? true;
        _deliveryNotifications = response['delivery_notifications'] ?? true;
        _orderNotifications = response['order_notifications'] ?? true;
        _systemNotifications = response['system_notifications'] ?? true;
        _soundEnabled = response['sound_enabled'] ?? true;
        _vibrationEnabled = response['vibration_enabled'] ?? true;
        
        // Battery settings
        _batteryOptimizationDisabled = response['battery_optimization_disabled'] ?? false;
        _autoStartEnabled = response['auto_start_enabled'] ?? false;
        _backgroundAppRefreshEnabled = response['background_app_refresh_enabled'] ?? true;
        _lowPowerModeAware = response['low_power_mode_aware'] ?? true;
        
        // Parse enums safely
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
        
        final priorityString = response['notification_priority'] ?? 'high';
        _notificationPriority = NotificationPriority.values.firstWhere(
          (e) => e.name == priorityString,
          orElse: () => NotificationPriority.high,
        );

        // Save to local storage
        await _saveSettings();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Server not available, continue with local settings
      _isServerSyncEnabled = false;
      _isLoading = false;
      debugPrint('Failed to load settings from server: $e');
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

  // Description methods
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

  String getNotificationPriorityDescription(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return 'High priority, may override Do Not Disturb';
      case NotificationPriority.medium:
        return 'Standard priority notifications';
      case NotificationPriority.low:
        return 'Low priority, minimal interruption';
    }
  }
}