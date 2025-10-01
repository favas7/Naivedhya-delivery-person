// lib/screens/profile/location_settings_screen/location_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/location_settings_provider.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  @override
  void initState() { 
    super.initState(); 
    // Load settings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadSettingsFromServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location & Mobile Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Permission Status Card
                _buildPermissionStatusCard(locationProvider),
                
                const SizedBox(height: 20),
                
                // Location Settings
                _buildLocationSettings(locationProvider),
                
                const SizedBox(height: 20),
                
                // Privacy Settings
                _buildPrivacySettings(locationProvider),
                
                const SizedBox(height: 20),
                
                // Notification Settings
                _buildNotificationSettings(locationProvider),
                
                const SizedBox(height: 20),
                
                // Battery Optimization Settings
                _buildBatteryOptimizationSettings(locationProvider),
                
                const SizedBox(height: 20),
                
                // Advanced Settings
                _buildAdvancedSettings(locationProvider),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionStatusCard(LocationProvider provider) {
    final hasLocation = provider.hasLocationPermission;
    final hasBackground = provider.hasBackgroundLocationPermission;
    final hasNotification = provider.hasNotificationPermission;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (hasLocation ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasLocation ? Icons.verified_user : Icons.warning,
                  color: hasLocation ? AppColors.success : AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Permissions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      hasLocation 
                          ? 'Essential permissions granted' 
                          : 'Some permissions are required for delivery service',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Location Permission Status
          _buildPermissionRow(
            'Location Access',
            hasLocation ? 'Granted' : 'Not Granted',
            hasLocation ? AppColors.success : AppColors.error,
            hasLocation ? Icons.check_circle : Icons.error,
          ),
          
          const SizedBox(height: 8),
          
          // Background Location Permission Status
          _buildPermissionRow(
            'Background Location',
            hasBackground ? 'Granted' : 'Not Granted',
            hasBackground ? AppColors.success : AppColors.warning,
            hasBackground ? Icons.check_circle : Icons.warning,
          ),
          
          const SizedBox(height: 8),
          
          // Notification Permission Status
          _buildPermissionRow(
            'Notifications',
            hasNotification ? 'Granted' : 'Not Granted',
            hasNotification ? AppColors.success : AppColors.warning,
            hasNotification ? Icons.check_circle : Icons.warning,
          ),
          
          if (!hasLocation || !hasBackground || !hasNotification) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _requestPermissions(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Grant Permissions',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String title, String status, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          status,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSettings(LocationProvider provider) {
    return _buildSection(
      'Location Services',
      [
        _buildSwitchTile(
          icon: Icons.location_on,
          title: 'Enable Location Services',
          subtitle: 'Allow app to access your location',
          value: provider.isLocationEnabled,
          onChanged: provider.hasLocationPermission 
              ? (value) => provider.setLocationEnabled(value)
              : null,
        ),
        _buildSwitchTile(
          icon: Icons.my_location,
          title: 'Background Location',
          subtitle: 'Track location when app is in background',
          value: provider.isBackgroundLocationEnabled,
          onChanged: provider.hasBackgroundLocationPermission 
              ? (value) => provider.setBackgroundLocationEnabled(value)
              : null,
        ),
        _buildDropdownTile(
          icon: Icons.gps_fixed,
          title: 'Location Accuracy',
          subtitle: provider.getLocationAccuracyDescription(provider.locationAccuracy),
          value: provider.locationAccuracy,
          items: LocationAccuracy.values
              .map((accuracy) => DropdownMenuItem<LocationAccuracy>(
                    value: accuracy,
                    child: Text(_getAccuracyDisplayName(accuracy)),
                  ))
              .toList(),
          onChanged: provider.isLocationEnabled
              ? (LocationAccuracy? value) {
                  if (value != null) {
                    provider.setLocationAccuracy(value);
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(LocationProvider provider) {
    return _buildSection(
      'Privacy & Sharing',
      [
        _buildSwitchTile(
          icon: Icons.share_location,
          title: 'Share with Customers',
          subtitle: 'Allow customers to see your live location',
          value: provider.shareLocationWithCustomers,
          onChanged: (value) => provider.setShareLocationWithCustomers(value),
        ),
        _buildDropdownTile(
          icon: Icons.schedule,
          title: 'When to Share',
          subtitle: provider.getLocationSharingDescription(provider.locationSharingPreference),
          value: provider.locationSharingPreference,
          items: LocationSharingPreference.values
              .map((preference) => DropdownMenuItem<LocationSharingPreference>(
                    value: preference,
                    child: Text(_getSharingDisplayName(preference)),
                  ))
              .toList(),
          onChanged: (LocationSharingPreference? value) {
            if (value != null) {
              provider.setLocationSharingPreference(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(LocationProvider provider) {
    return _buildSection(
      'Notification Settings',
      [
        _buildSwitchTile(
          icon: Icons.notifications,
          title: 'Enable Notifications',
          subtitle: 'Allow app to send notifications',
          value: provider.notificationsEnabled,
          onChanged: provider.hasNotificationPermission 
              ? (value) => provider.setNotificationsEnabled(value)
              : null,
        ),
        _buildSwitchTile(
          icon: Icons.delivery_dining,
          title: 'Delivery Notifications',
          subtitle: 'Get notified about new delivery requests',
          value: provider.deliveryNotifications,
          onChanged: provider.notificationsEnabled
              ? (value) => provider.setDeliveryNotifications(value)
              : null,
        ),
        _buildSwitchTile(
          icon: Icons.shopping_bag,
          title: 'Order Notifications',
          subtitle: 'Updates about order status and changes',
          value: provider.orderNotifications,
          onChanged: provider.notificationsEnabled
              ? (value) => provider.setOrderNotifications(value)
              : null,
        ),
        _buildSwitchTile(
          icon: Icons.info,
          title: 'System Notifications',
          subtitle: 'App updates and system messages',
          value: provider.systemNotifications,
          onChanged: provider.notificationsEnabled
              ? (value) => provider.setSystemNotifications(value)
              : null,
        ),
        _buildSwitchTile(
          icon: Icons.volume_up,
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          value: provider.soundEnabled,
          onChanged: provider.notificationsEnabled
              ? (value) => provider.setSoundEnabled(value)
              : null,
        ),
        _buildSwitchTile(
          icon: Icons.vibration,
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          value: provider.vibrationEnabled,
          onChanged: provider.notificationsEnabled
              ? (value) => provider.setVibrationEnabled(value)
              : null,
        ),
        _buildDropdownTile(
          icon: Icons.priority_high,
          title: 'Notification Priority',
          subtitle: provider.getNotificationPriorityDescription(provider.notificationPriority),
          value: provider.notificationPriority,
          items: NotificationPriority.values
              .map((priority) => DropdownMenuItem<NotificationPriority>(
                    value: priority,
                    child: Text(_getPriorityDisplayName(priority)),
                  ))
              .toList(),
          onChanged: provider.notificationsEnabled
              ? (NotificationPriority? value) {
                  if (value != null) {
                    provider.setNotificationPriority(value);
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildBatteryOptimizationSettings(LocationProvider provider) {
    return _buildSection(
      'Battery & Performance',
      [
        _buildSwitchTile(
          icon: Icons.battery_full,
          title: 'Disable Battery Optimization',
          subtitle: 'Prevent system from killing the app',
          value: provider.batteryOptimizationDisabled,
          onChanged: (value) => provider.setBatteryOptimizationDisabled(value),
        ),
        _buildSwitchTile(
          icon: Icons.power_settings_new,
          title: 'Auto Start',
          subtitle: 'Allow app to start automatically',
          value: provider.autoStartEnabled,
          onChanged: (value) => provider.setAutoStartEnabled(value),
        ),
        _buildSwitchTile(
          icon: Icons.refresh,
          title: 'Background App Refresh',
          subtitle: 'Allow app to refresh in background',
          value: provider.backgroundAppRefreshEnabled,
          onChanged: (value) => provider.setBackgroundAppRefreshEnabled(value),
        ),
        _buildSwitchTile(
          icon: Icons.power_outlined,
          title: 'Low Power Mode Aware',
          subtitle: 'Adapt behavior when in low power mode',
          value: provider.lowPowerModeAware,
          onChanged: (value) => provider.setLowPowerModeAware(value),
        ),
        _buildActionTile(
          icon: Icons.battery_charging_full,
          title: 'Battery Settings',
          subtitle: 'Open system battery optimization settings',
          onTap: () => _openBatterySettings(),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings(LocationProvider provider) {
    return _buildSection(
      'Advanced Settings',
      [
        _buildActionTile(
          icon: Icons.settings,
          title: 'App Settings',
          subtitle: 'Open system app settings',
          onTap: () => openAppSettings(),
        ),
        _buildActionTile(
          icon: Icons.refresh,
          title: 'Refresh Settings',
          subtitle: 'Reload settings from server',
          onTap: () => provider.loadSettingsFromServer(),
        ),
        if (provider.errorMessage != null)
          _buildErrorTile(provider.errorMessage!, provider.clearError),
      ],
    );
  }

  Widget _buildErrorTile(String errorMessage, VoidCallback onDismiss) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, color: AppColors.error, size: 20),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: child,
              )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final isEnabled = onChanged != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isEnabled ? AppColors.primary : AppColors.textSecondary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isEnabled ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.textSecondary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required IconData icon,
    required String title,
    required String subtitle,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    final isEnabled = onChanged != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isEnabled ? AppColors.primary : AppColors.textSecondary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isEnabled ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isEnabled ? AppColors.border : AppColors.textSecondary.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              underline: Container(),
              isDense: true,
              style: TextStyle(
                color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 14,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissions(LocationProvider provider) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      // Request location permission first
      if (!provider.hasLocationPermission) {
        final locationGranted = await provider.requestLocationPermission();
        if (!locationGranted) {
          Navigator.pop(context); // Close loading dialog
          _showPermissionDialog(
            'Location Permission Required',
            'Location access is required for delivery services. Please grant location permission in settings.',
            () => openAppSettings(),
          );
          return;
        }
      }

      // Request background location permission
      if (!provider.hasBackgroundLocationPermission) {
        await provider.requestBackgroundLocationPermission();
      }

      // Request notification permission
      if (!provider.hasNotificationPermission) {
        await provider.requestNotificationPermission();
      }

      Navigator.pop(context); // Close loading dialog

      // Show success message if all permissions granted
      if (provider.hasLocationPermission && 
          provider.hasBackgroundLocationPermission && 
          provider.hasNotificationPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All permissions granted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to request permissions: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPermissionDialog(String title, String message, VoidCallback onOpenSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onOpenSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBatterySettings() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening battery settings...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      // Open app settings - user can navigate to battery optimization from there
      await openAppSettings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open battery settings: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getAccuracyDisplayName(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return 'High Accuracy';
      case LocationAccuracy.medium:
        return 'Balanced';
      case LocationAccuracy.low:
        return 'Battery Saver';
    }
  }

  String _getSharingDisplayName(LocationSharingPreference preference) {
    switch (preference) {
      case LocationSharingPreference.always:
        return 'Always Share';
      case LocationSharingPreference.whileUsingApp:
        return 'While Using App';
      case LocationSharingPreference.never:
        return 'Never Share';
    }
  }

  String _getPriorityDisplayName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return 'High Priority';
      case NotificationPriority.medium:
        return 'Normal Priority';
      case NotificationPriority.low:
        return 'Low Priority';
    }
  }
}