import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DeviceNotificationService {
  static final DeviceNotificationService _instance = DeviceNotificationService._internal();
  factory DeviceNotificationService() => _instance;
  DeviceNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      // Don't throw error, just log it
    }
  }

  void _onNotificationTap(NotificationResponse notificationResponse) {
    // Handle notification tap
    debugPrint('Notification tapped: ${notificationResponse.payload}');
  }

  /// Check if notifications are enabled at system level
  Future<bool> areNotificationsEnabled() async {
    try {
      final permission = await Permission.notification.status;
      return permission == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error checking notification status: $e');
      return false;
    }
  }

  /// Request notification permission
  Future<PermissionStatus> requestNotificationPermission() async {
    try {
      await initialize();
      
      // For Android 13+ (API 33+), we need to request notification permission
      final permission = await Permission.notification.request();
      
      return permission;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Check notification permission status
  Future<PermissionStatus> getNotificationPermissionStatus() async {
    try {
      return await Permission.notification.status;
    } catch (e) {
      debugPrint('Error getting notification permission status: $e');
      return PermissionStatus.denied;
    }
  }

  /// Open device notification settings
  Future<void> openNotificationSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
      // Fallback to general app settings
      try {
        await AppSettings.openAppSettings();
      } catch (e2) {
        debugPrint('Error opening app settings: $e2');
      }
    }
  }

  /// Open general app settings
  Future<void> openAppSettings() async {
    try {
      await AppSettings.openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  /// Test notification to verify settings
  Future<void> sendTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification to verify your settings.',
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        enableLights: true,
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      rethrow; // Re-throw so the caller can handle it
    }
  }

  /// Create notification channels for different types
  Future<void> createNotificationChannels() async {
    try {
      if (!_isInitialized) await initialize();

      // Order updates channel
      const AndroidNotificationChannel orderUpdatesChannel =
          AndroidNotificationChannel(
        'order_updates',
        'Order Updates',
        description: 'Notifications for order status changes',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
      );

      // New order alerts channel
      const AndroidNotificationChannel newOrderAlertsChannel =
          AndroidNotificationChannel(
        'new_order_alerts',
        'New Order Alerts',
        description: 'Notifications for new incoming orders',
        importance: Importance.max,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      // Payment notifications channel
      const AndroidNotificationChannel paymentChannel =
          AndroidNotificationChannel(
        'payment_notifications',
        'Payment Notifications',
        description: 'Notifications for payment updates',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
      );

      // System alerts channel
      const AndroidNotificationChannel systemAlertsChannel =
          AndroidNotificationChannel(
        'system_alerts',
        'System Alerts',
        description: 'Important system notifications and updates',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
      );

      // Promotional offers channel
      const AndroidNotificationChannel promotionalChannel =
          AndroidNotificationChannel(
        'promotional_offers',
        'Promotional Offers',
        description: 'Special offers and promotional notifications',
        importance: Importance.defaultImportance,
        enableVibration: false,
        enableLights: false,
      );

      // Create all channels
      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (plugin != null) {
        await plugin.createNotificationChannel(orderUpdatesChannel);
        await plugin.createNotificationChannel(newOrderAlertsChannel);
        await plugin.createNotificationChannel(paymentChannel);
        await plugin.createNotificationChannel(systemAlertsChannel);
        await plugin.createNotificationChannel(promotionalChannel);
      }
    } catch (e) {
      debugPrint('Error creating notification channels: $e');
      // Don't throw error for channel creation failures
    }
  }

  /// Show permission request dialog
  static Future<bool> showPermissionDialog(BuildContext context) async {
    try {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To receive important updates about your orders and deliveries, please enable notifications for this app.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'You can customize which notifications you receive in the app settings.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Enable'),
              ),
            ],
          );
        },
      ) ?? false;
    } catch (e) {
      debugPrint('Error showing permission dialog: $e');
      return false;
    }
  }

  /// Show settings redirect dialog
  static Future<bool> showSettingsDialog(BuildContext context, {
    String title = 'Notification Access Required',
    String message = 'Please enable notifications in your device settings to receive important updates.',
  }) async {
    try {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      ) ?? false;
    } catch (e) {
      debugPrint('Error showing settings dialog: $e');
      return false;
    }
  }

  /// Handle permission flow
  static Future<bool> handleNotificationPermissionFlow(BuildContext context) async {
    try {
      final service = DeviceNotificationService();
      
      // Check current permission status
      final currentStatus = await service.getNotificationPermissionStatus();
      
      if (currentStatus == PermissionStatus.granted) {
        return true;
      }
      
      if (currentStatus == PermissionStatus.denied) {
        // Show explanation dialog first
        final shouldRequest = await showPermissionDialog(context);
        if (!shouldRequest) return false;
        
        // Request permission
        final newStatus = await service.requestNotificationPermission();
        return newStatus == PermissionStatus.granted;
      }
      
      if (currentStatus == PermissionStatus.permanentlyDenied) {
        // Show settings dialog
        final shouldOpenSettings = await showSettingsDialog(context);
        if (shouldOpenSettings) {
          await service.openNotificationSettings();
        }
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error in permission flow: $e');
      return false;
    }
  }
}