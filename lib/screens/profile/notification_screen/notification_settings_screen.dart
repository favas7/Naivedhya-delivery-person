import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/notification_provider.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  void _loadNotificationPreferences() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        notificationProvider.loadNotificationPreferences(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (notificationProvider.error != null) {
            return _buildErrorWidget(notificationProvider.error!);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with master toggle
                _buildMasterToggleHeader(),
                
                const SizedBox(height: 20),
                
                // Notification types section
                _buildNotificationTypesSection(),
                
                const SizedBox(height: 20),
                
                // Sound & Vibration section
                _buildSoundVibrationSection(),
                
                const SizedBox(height: 20),
                
                // Quiet Hours section
                _buildQuietHoursSection(),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadNotificationPreferences,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggleHeader() {
    return Consumer2<NotificationProvider, AuthProvider>(
      builder: (context, notificationProvider, authProvider, child) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.notifications,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Master Notifications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notificationProvider.masterNotification 
                    ? 'All notifications are enabled' 
                    : 'All notifications are disabled',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(80),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Enable Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: notificationProvider.masterNotification,
                    onChanged: (value) {
                      if (authProvider.user != null) {
                        notificationProvider.toggleMasterNotification(
                          authProvider.user!.id, 
                          value,
                        );
                      }
                    },
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.success,
                    inactiveThumbColor: Colors.white70,
                    inactiveTrackColor: Colors.white30,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationTypesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildSection(
        'Notification Types',
        [
          _buildNotificationToggle(
            icon: Icons.assignment,
            title: 'Order Updates',
            subtitle: 'New orders, status changes, completion',
            key: 'order_updates',
            value: context.watch<NotificationProvider>().orderUpdates,
          ),
          _buildNotificationToggle(
            icon: Icons.notification_important,
            title: 'New Order Alerts',
            subtitle: 'Get notified instantly when new orders arrive',
            key: 'new_order_alerts',
            value: context.watch<NotificationProvider>().newOrderAlerts,
          ),
          _buildNotificationToggle(
            icon: Icons.payment,
            title: 'Payment Notifications',
            subtitle: 'Payment received, earnings updates',
            key: 'payment_notifications',
            value: context.watch<NotificationProvider>().paymentNotifications,
          ),
          _buildNotificationToggle(
            icon: Icons.location_on,
            title: 'Location Updates',
            subtitle: 'Location sharing and tracking updates',
            key: 'location_updates',
            value: context.watch<NotificationProvider>().locationUpdates,
          ),
          _buildNotificationToggle(
            icon: Icons.settings,
            title: 'System Alerts',
            subtitle: 'App updates, maintenance notifications',
            key: 'system_alerts',
            value: context.watch<NotificationProvider>().systemAlerts,
          ),
          _buildNotificationToggle(
            icon: Icons.local_offer,
            title: 'Promotional Offers',
            subtitle: 'Special offers, bonuses, and rewards',
            key: 'promotional_offers',
            value: context.watch<NotificationProvider>().promotionalOffers,
          ),
          _buildNotificationToggle(
            icon: Icons.analytics,
            title: 'Weekly Reports',
            subtitle: 'Weekly earnings and performance summary',
            key: 'weekly_reports',
            value: context.watch<NotificationProvider>().weeklyReports,
          ),
        ],
      ),
    );
  }

  Widget _buildSoundVibrationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildSection(
        'Sound & Vibration',
        [
          _buildNotificationToggle(
            icon: Icons.volume_up,
            title: 'Sound',
            subtitle: 'Play notification sound',
            key: 'sound_enabled',
            value: context.watch<NotificationProvider>().soundEnabled,
          ),
          _buildNotificationToggle(
            icon: Icons.vibration,
            title: 'Vibration',
            subtitle: 'Vibrate device for notifications',
            key: 'vibration_enabled',
            value: context.watch<NotificationProvider>().vibrationEnabled,
          ),
          _buildNotificationToneSelector(),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildSection(
        'Quiet Hours',
        [
          Consumer2<NotificationProvider, AuthProvider>(
            builder: (context, notificationProvider, authProvider, child) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bedtime,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Enable Quiet Hours',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  notificationProvider.quietHoursEnabled
                    ? 'Notifications will be silenced during quiet hours'
                    : 'Receive notifications at any time',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                trailing: Switch(
                  value: notificationProvider.quietHoursEnabled,
                  onChanged: (value) {
                    if (authProvider.user != null) {
                      notificationProvider.updateQuietHours(
                        authProvider.user!.id,
                        value,
                        null,
                        null,
                      );
                    }
                  },
                  activeColor: AppColors.primary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              );
            },
          ),
          if (context.watch<NotificationProvider>().quietHoursEnabled) ...[
            _buildQuietHoursTimePicker(),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required String key,
    required bool value,
  }) {
    return Consumer2<NotificationProvider, AuthProvider>(
      builder: (context, notificationProvider, authProvider, child) {
        final isEnabled = notificationProvider.masterNotification;
        
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.primary.withAlpha(50) : AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isEnabled ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
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
            value: isEnabled && value,
            onChanged: isEnabled ? (newValue) {
              if (authProvider.user != null) {
                notificationProvider.updateNotificationPreference(
                  authProvider.user!.id,
                  key,
                  newValue,
                );
              }
            } : null,
            activeColor: AppColors.primary,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        );
      },
    );
  }

  Widget _buildNotificationToneSelector() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final isEnabled = notificationProvider.masterNotification && 
                         notificationProvider.soundEnabled;
        
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.primary.withAlpha(50) : AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.music_note,
              color: isEnabled ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          title: Text(
            'Notification Tone',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          subtitle: Text(
            notificationProvider.notificationTone.capitalize(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isEnabled ? AppColors.textSecondary : AppColors.border,
          ),
          onTap: isEnabled ? () => _showToneSelector() : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        );
      },
    );
  }

  Widget _buildQuietHoursTimePicker() {
    return Consumer2<NotificationProvider, AuthProvider>(
      builder: (context, notificationProvider, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildTimePickerCard(
                  'Start Time',
                  notificationProvider.quietHoursStart,
                  (time) {
                    if (authProvider.user != null) {
                      notificationProvider.updateQuietHours(
                        authProvider.user!.id,
                        notificationProvider.quietHoursEnabled,
                        time,
                        null,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePickerCard(
                  'End Time',
                  notificationProvider.quietHoursEnd,
                  (time) {
                    if (authProvider.user != null) {
                      notificationProvider.updateQuietHours(
                        authProvider.user!.id,
                        notificationProvider.quietHoursEnabled,
                        null,
                        time,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePickerCard(String label, TimeOfDay time, Function(TimeOfDay) onTimeChanged) {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Colors.white,
                  hourMinuteTextColor: AppColors.primary,
                  dayPeriodTextColor: AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (selectedTime != null) {
          onTimeChanged(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToneSelector() {
    final tones = ['default', 'gentle', 'classic', 'modern', 'urgent'];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer2<NotificationProvider, AuthProvider>(
          builder: (context, notificationProvider, authProvider, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Notification Tone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...tones.map((tone) => ListTile(
                    title: Text(tone.capitalize()),
                    leading: Radio<String>(
                      value: tone,
                      groupValue: notificationProvider.notificationTone,
                      onChanged: (value) {
                        if (value != null && authProvider.user != null) {
                          notificationProvider.updateNotificationPreference(
                            authProvider.user!.id,
                            'notification_tone',
                            value,
                          );
                          Navigator.pop(context);
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                  )).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}