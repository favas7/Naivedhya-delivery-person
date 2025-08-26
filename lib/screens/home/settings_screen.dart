import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/l10n/app_localizations.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/language_provider.dart';
import 'package:naivedhya_delivery_app/routes/app_route_info.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            _buildSection(
              title: 'App Settings',
              icon: Icons.settings,
              options: [
                _buildSettingsOption(
                  icon: Icons.notifications_outlined,
                  title: l10n.notifications,
                  subtitle: l10n.notificationsSubtitle,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notificationSettings),
                ),
                _buildSettingsOption(
                  icon: Icons.location_on_outlined,
                  title: l10n.locationSettings,
                  subtitle: l10n.locationSettingsSubtitle,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.locationSettings),
                ),
                _buildSettingsOption(
                  icon: Icons.language,
                  title: l10n.language,
                  subtitle: context.read<LanguageProvider>().getCurrentLanguageName(),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.languageSettings),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Account Settings Section
            _buildSection(
              title: 'Account Settings',
              icon: Icons.account_circle,
              options: [
                _buildSettingsOption(
                  icon: Icons.person_outline,
                  title: l10n.personalInformation,
                  subtitle: l10n.personalInfoSubtitle,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.personalInformation),
                ),
                _buildSettingsOption(
                  icon: Icons.motorcycle,
                  title: l10n.vehicleDetails,
                  subtitle: l10n.vehicleDetailsSubtitle,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.vehicleDetails),
                ),
                _buildSettingsOption(
                  icon: Icons.credit_card,
                  title: l10n.documents,
                  subtitle: l10n.documentsSubtitle,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Support & Help Section
            _buildSection(
              title: 'Support & Help',
              icon: Icons.help_outline,
              options: [
                _buildSettingsOption(
                  icon: Icons.help_outline,
                  title: l10n.helpFaq,
                  subtitle: l10n.helpFaqSubtitle,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.helpFaq),
                ),
                _buildSettingsOption(
                  icon: Icons.support_agent,
                  title: l10n.contactSupport,
                  subtitle: l10n.contactSupportSubtitle,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.contactSupport),
                ),
                _buildSettingsOption(
                  icon: Icons.info_outline,
                  title: l10n.about,
                  subtitle: l10n.aboutSubtitle,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  } 

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        // Section Options
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isLast = index == options.length - 1;
              
              return Column(
                children: [
                  option,
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: AppColors.border,
                      indent: 60,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.2,
          ),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(4),
        child: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
      onTap: onTap,
    );
  }


}