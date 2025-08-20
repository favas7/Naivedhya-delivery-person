import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/service/device_notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DeviceNotificationService _deviceService = DeviceNotificationService();
  
  // Notification preferences
  bool _masterNotification = true;
  bool _orderUpdates = true;
  bool _promotionalOffers = false;
  bool _systemAlerts = true;
  bool _locationUpdates = true;
  bool _newOrderAlerts = true;
  bool _paymentNotifications = true;
  bool _weeklyReports = false;
  
  // Quiet hours settings
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 6, minute: 0);
  
  // Sound and vibration settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _notificationTone = 'default';
  
  // Device permission status
  PermissionStatus _devicePermissionStatus = PermissionStatus.denied;
  bool _deviceNotificationsEnabled = false;
  
  // Loading and error states
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get masterNotification => _masterNotification;
  bool get orderUpdates => _orderUpdates;
  bool get promotionalOffers => _promotionalOffers;
  bool get systemAlerts => _systemAlerts;
  bool get locationUpdates => _locationUpdates;
  bool get newOrderAlerts => _newOrderAlerts;
  bool get paymentNotifications => _paymentNotifications;
  bool get weeklyReports => _weeklyReports;
  bool get quietHoursEnabled => _quietHoursEnabled;
  TimeOfDay get quietHoursStart => _quietHoursStart;
  TimeOfDay get quietHoursEnd => _quietHoursEnd;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  String get notificationTone => _notificationTone;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Device permission getters
  PermissionStatus get devicePermissionStatus => _devicePermissionStatus;
  bool get deviceNotificationsEnabled => _deviceNotificationsEnabled;
  bool get canReceiveNotifications => _deviceNotificationsEnabled && _masterNotification;

  /// Initialize the provider
Future<void> initialize() async {
  try {
    // Initialize device service first
    await _deviceService.initialize();
    
    // Check device permissions
    await _checkDevicePermissionStatus();
    
    // Create notification channels
    await _deviceService.createNotificationChannels();
    
  } catch (e) {
    debugPrint('Error initializing NotificationProvider: $e');
    // Don't set error state, just log it and continue
    // The app should still be functional even if notifications fail to initialize
  }
}
  /// Load notification preferences from Supabase
  Future<void> loadNotificationPreferences(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      // Check device permissions first
      await _checkDevicePermissionStatus();

      final response = await _supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        _updatePreferencesFromData(response);
      } else {
        // Create default preferences if none exist
        await _createDefaultPreferences(userId);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notification preferences: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Check device notification permission status
Future<void> _checkDevicePermissionStatus() async {
  try {
    _devicePermissionStatus = await _deviceService.getNotificationPermissionStatus();
    _deviceNotificationsEnabled = await _deviceService.areNotificationsEnabled();
    notifyListeners();
  } catch (e) {
    debugPrint('Error checking device permission status: $e');
    // Set to safe defaults
    _devicePermissionStatus = PermissionStatus.denied;
    _deviceNotificationsEnabled = false;
    notifyListeners();
  }
}

  /// Request device notification permission
  Future<bool> requestDeviceNotificationPermission(BuildContext context) async {
    try {
      final success = await DeviceNotificationService.handleNotificationPermissionFlow(context);
      await _checkDevicePermissionStatus();
      return success;
    } catch (e) {
      _error = 'Failed to request notification permission: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Open device notification settings
  Future<void> openDeviceNotificationSettings() async {
    try {
      await _deviceService.openNotificationSettings();
      // Refresh status when user returns to app
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkDevicePermissionStatus();
    } catch (e) {
      _error = 'Failed to open notification settings: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update individual notification preference
  Future<void> updateNotificationPreference(
    String userId,
    String preferenceKey,
    dynamic value, {
    BuildContext? context,
  }) async {
    try {
      _error = null;

      // Check device permissions before updating preferences
      if (context != null && !_deviceNotificationsEnabled && value == true) {
        final granted = await requestDeviceNotificationPermission(context);
        if (!granted) {
          // Don't update the preference if permission wasn't granted
          return;
        }
      }

      // Update local state first
      _updateLocalPreference(preferenceKey, value);
      notifyListeners();

      // Update in Supabase
      final updateData = {
        preferenceKey: value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('notification_preferences')
          .update(updateData)
          .eq('user_id', userId);

    } catch (e) {
      _error = 'Failed to update notification preference: ${e.toString()}';
      // Revert local change on error
      await loadNotificationPreferences(userId);
      notifyListeners();
    }
  }

  /// Update quiet hours
  Future<void> updateQuietHours(
    String userId,
    bool enabled,
    TimeOfDay? start,
    TimeOfDay? end, {
    BuildContext? context,
  }) async {
    try {
      _error = null;

      // Check device permissions if enabling quiet hours
      if (context != null && !_deviceNotificationsEnabled && enabled) {
        final granted = await requestDeviceNotificationPermission(context);
        if (!granted) return;
      }
      
      _quietHoursEnabled = enabled;
      if (start != null) _quietHoursStart = start;
      if (end != null) _quietHoursEnd = end;
      
      notifyListeners();

      final updateData = {
        'quiet_hours_enabled': enabled,
        'quiet_hours_start': '${_quietHoursStart.hour}:${_quietHoursStart.minute}',
        'quiet_hours_end': '${_quietHoursEnd.hour}:${_quietHoursEnd.minute}',
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('notification_preferences')
          .update(updateData)
          .eq('user_id', userId);

    } catch (e) {
      _error = 'Failed to update quiet hours: ${e.toString()}';
      await loadNotificationPreferences(userId);
      notifyListeners();
    }
  }

  /// Toggle master notification and update all others
  Future<void> toggleMasterNotification(String userId, bool value, {
    BuildContext? context,
  }) async {
    try {
      _error = null;

      // Check device permissions before enabling master notifications
      if (context != null && !_deviceNotificationsEnabled && value) {
        final granted = await requestDeviceNotificationPermission(context);
        if (!granted) return;
      }

      _masterNotification = value;
      
      // If master is turned off, disable all notifications
      if (!value) {
        _orderUpdates = false;
        _promotionalOffers = false;
        _systemAlerts = false;
        _locationUpdates = false;
        _newOrderAlerts = false;
        _paymentNotifications = false;
        _weeklyReports = false;
      }
      
      notifyListeners();

      final updateData = _getAllPreferencesAsMap();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('notification_preferences')
          .update(updateData)
          .eq('user_id', userId);

    } catch (e) {
      _error = 'Failed to update master notification: ${e.toString()}';
      await loadNotificationPreferences(userId);
      notifyListeners();
    }
  }

  /// Send test notification
  Future<void> sendTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification from Naivedhya Delivery App!',
  }) async {
    try {
      if (!_deviceNotificationsEnabled) {
        _error = 'Notifications are not enabled on this device';
        notifyListeners();
        return;
      }

      await _deviceService.sendTestNotification(
        title: title,
        body: body,
        playSound: _soundEnabled,
        enableVibration: _vibrationEnabled,
      );
      
    } catch (e) {
      _error = 'Failed to send test notification: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Check if notifications are working properly
  Future<Map<String, dynamic>> getNotificationStatus() async {
    await _checkDevicePermissionStatus();
    
    return {
      'devicePermissionGranted': _devicePermissionStatus == PermissionStatus.granted,
      'deviceNotificationsEnabled': _deviceNotificationsEnabled,
      'appMasterEnabled': _masterNotification,
      'canReceiveNotifications': canReceiveNotifications,
      'permissionStatus': _devicePermissionStatus.toString(),
      'troubleshootingTips': _getTroubleshootingTips(),
    };
  }

  List<String> _getTroubleshootingTips() {
    List<String> tips = [];
    
    if (_devicePermissionStatus == PermissionStatus.denied) {
      tips.add('Grant notification permission in app settings');
    }
    
    if (_devicePermissionStatus == PermissionStatus.permanentlyDenied) {
      tips.add('Go to device Settings > Apps > Naivedhya Delivery > Notifications and enable them');
    }
    
    if (!_deviceNotificationsEnabled) {
      tips.add('Enable notifications in your device settings');
    }
    
    if (!_masterNotification) {
      tips.add('Enable master notifications in the app settings');
    }
    
    if (_deviceNotificationsEnabled && _masterNotification) {
      tips.add('All settings are configured correctly!');
    }
    
    return tips;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _updatePreferencesFromData(Map<String, dynamic> data) {
    _masterNotification = data['master_notification'] ?? true;
    _orderUpdates = data['order_updates'] ?? true;
    _promotionalOffers = data['promotional_offers'] ?? false;
    _systemAlerts = data['system_alerts'] ?? true;
    _locationUpdates = data['location_updates'] ?? true;
    _newOrderAlerts = data['new_order_alerts'] ?? true;
    _paymentNotifications = data['payment_notifications'] ?? true;
    _weeklyReports = data['weekly_reports'] ?? false;
    _quietHoursEnabled = data['quiet_hours_enabled'] ?? false;
    _soundEnabled = data['sound_enabled'] ?? true;
    _vibrationEnabled = data['vibration_enabled'] ?? true;
    _notificationTone = data['notification_tone'] ?? 'default';

    // Parse quiet hours
    if (data['quiet_hours_start'] != null) {
      final parts = data['quiet_hours_start'].toString().split(':');
      _quietHoursStart = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    if (data['quiet_hours_end'] != null) {
      final parts = data['quiet_hours_end'].toString().split(':');
      _quietHoursEnd = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> _createDefaultPreferences(String userId) async {
    final defaultData = {
      'user_id': userId,
      ..._getAllPreferencesAsMap(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase
        .from('notification_preferences')
        .insert(defaultData);
  }

  void _updateLocalPreference(String key, dynamic value) {
    switch (key) {
      case 'master_notification':
        _masterNotification = value;
        break;
      case 'order_updates':
        _orderUpdates = value;
        break;
      case 'promotional_offers':
        _promotionalOffers = value;
        break;
      case 'system_alerts':
        _systemAlerts = value;
        break;
      case 'location_updates':
        _locationUpdates = value;
        break;
      case 'new_order_alerts':
        _newOrderAlerts = value;
        break;
      case 'payment_notifications':
        _paymentNotifications = value;
        break;
      case 'weekly_reports':
        _weeklyReports = value;
        break;
      case 'sound_enabled':
        _soundEnabled = value;
        break;
      case 'vibration_enabled':
        _vibrationEnabled = value;
        break;
      case 'notification_tone':
        _notificationTone = value;
        break;
    }
  }

  Map<String, dynamic> _getAllPreferencesAsMap() {
    return {
      'master_notification': _masterNotification,
      'order_updates': _orderUpdates,
      'promotional_offers': _promotionalOffers,
      'system_alerts': _systemAlerts,
      'location_updates': _locationUpdates,
      'new_order_alerts': _newOrderAlerts,
      'payment_notifications': _paymentNotifications,
      'weekly_reports': _weeklyReports,
      'quiet_hours_enabled': _quietHoursEnabled,
      'quiet_hours_start': '${_quietHoursStart.hour}:${_quietHoursStart.minute}',
      'quiet_hours_end': '${_quietHoursEnd.hour}:${_quietHoursEnd.minute}',
      'sound_enabled': _soundEnabled,
      'vibration_enabled': _vibrationEnabled,
      'notification_tone': _notificationTone,
    };
  }

  // Clear data on logout
  void clearNotificationData() {
    _masterNotification = true;
    _orderUpdates = true;
    _promotionalOffers = false;
    _systemAlerts = true;
    _locationUpdates = true;
    _newOrderAlerts = true;
    _paymentNotifications = true;
    _weeklyReports = false;
    _quietHoursEnabled = false;
    _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
    _quietHoursEnd = const TimeOfDay(hour: 6, minute: 0);
    _soundEnabled = true;
    _vibrationEnabled = true;
    _notificationTone = 'default';
    _devicePermissionStatus = PermissionStatus.denied;
    _deviceNotificationsEnabled = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}