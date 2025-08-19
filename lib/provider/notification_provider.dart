import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
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

  // Load notification preferences from Supabase
  Future<void> loadNotificationPreferences(String userId) async {
    try {
      _setLoading(true);
      _error = null;

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

  // Update individual notification preference
  Future<void> updateNotificationPreference(
    String userId,
    String preferenceKey,
    dynamic value,
  ) async {
    try {
      _error = null;

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

  // Update quiet hours
  Future<void> updateQuietHours(
    String userId,
    bool enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  ) async {
    try {
      _error = null;
      
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

  // Toggle master notification and update all others
  Future<void> toggleMasterNotification(String userId, bool value) async {
    try {
      _error = null;
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
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}