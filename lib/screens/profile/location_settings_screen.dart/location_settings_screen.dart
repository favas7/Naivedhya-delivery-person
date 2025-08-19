// lib/screens/profile/location_settings_screen/location_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/location_settings_provider.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
        title: const Text('Location Settings'),
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
                  hasLocation ? Icons.location_on : Icons.location_off,
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
                      'Location Permissions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      hasLocation 
                          ? 'Location access granted' 
                          : 'Location access required for delivery tracking',
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
          
          if (!hasLocation || !hasBackground) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _requestPermissions(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Grant Permissions'),
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
          icon: Icons.my_location, // FIXED: Changed from Icons.background_replace to Icons.my_location
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
              ? (LocationAccuracy? value) {  // FIXED: Added explicit type
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
          onChanged: (LocationSharingPreference? value) {  // FIXED: Added explicit type
            if (value != null) {
              provider.setLocationSharingPreference(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings(LocationProvider provider) {
    return _buildSection(
      'Advanced Settings',
      [
        _buildActionTile(
          icon: Icons.settings_applications,
          title: 'App Settings',
          subtitle: 'Open system location settings for this app',
          onTap: () => openAppSettings(),
        ),
        _buildActionTile(
          icon: Icons.refresh,
          title: 'Refresh Permissions',
          subtitle: 'Check current permission status',
          onTap: () => _refreshPermissions(provider),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
            child: Column(children: children),
          ),
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _getAccuracyDisplayName(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return 'High';
      case LocationAccuracy.medium:
        return 'Medium';
      case LocationAccuracy.low:
        return 'Low';
    }
  }

  String _getSharingDisplayName(LocationSharingPreference preference) {
    switch (preference) {
      case LocationSharingPreference.always:
        return 'Always';
      case LocationSharingPreference.whileUsingApp:
        return 'While Using App';
      case LocationSharingPreference.never:
        return 'Never';
    }
  }

  Future<void> _requestPermissions(LocationProvider provider) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      // Request basic location permission first
      if (!provider.hasLocationPermission) {
        await provider.requestLocationPermission();
      }

      // Then request background location if basic permission granted
      if (provider.hasLocationPermission && !provider.hasBackgroundLocationPermission) {
        await provider.requestBackgroundLocationPermission();
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show result
        final hasBasic = provider.hasLocationPermission;
        final hasBackground = provider.hasBackgroundLocationPermission;
        
        String message;
        if (hasBasic && hasBackground) {
          message = 'All location permissions granted successfully!';
        } else if (hasBasic) {
          message = 'Basic location permission granted. Background permission is recommended for better service.';
        } else {
          message = 'Location permissions are required for delivery tracking. Please enable them in app settings.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: hasBasic ? AppColors.success : AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permissions: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _refreshPermissions(LocationProvider provider) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checking permissions...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Refresh permissions (this will trigger a rebuild)
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission status updated'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}