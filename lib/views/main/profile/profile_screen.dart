import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/utils/l10n/app_localizations.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/language_provider.dart';
import 'package:naivedhya_delivery_app/provider/notification_provider.dart';
import 'package:naivedhya_delivery_app/provider/user_provider.dart';
import 'package:naivedhya_delivery_app/utils/routes/app_route_info.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) { 
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final userProvider = context.read<UserProvider>();
              final authProvider = context.read<AuthProvider>();
              if (authProvider.user != null) {
                userProvider.getUserProfile(authProvider.user!.id);
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer2<AuthProvider, UserProvider>(
        builder: (context, authProvider, userProvider, child) {
          // Load user profile if not loaded
          if (authProvider.user != null && userProvider.userProfile == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.getUserProfile(authProvider.user!.id);
            });
          }

          // Show loading indicator
          if (userProvider.isLoading && userProvider.userProfile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error if any
          if (userProvider.errorMessage != null && userProvider.userProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      userProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (authProvider.user != null) {
                        userProvider.getUserProfile(authProvider.user!.id);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, l10n, userProvider, authProvider),
                
                const SizedBox(height: 20),
                
                // Profile Options
                _buildProfileOptions(context, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context, 
    AppLocalizations l10n,
    UserProvider userProvider,
    AuthProvider authProvider,
  ) {
    final profile = userProvider.userProfile;
    final stats = userProvider.userStats;
    
    final userName = profile?['full_name'] ?? 
                     profile?['name'] ?? 
                     authProvider.user?.email?.split('@')[0] ?? 
                     l10n.deliveryPartner;
    
    final userEmail = profile?['email'] ?? 
                      authProvider.user?.email ?? 
                      'deliverypartner@naivedhya.com';
    
    final earnings = (profile?['earnings'] ?? 0.0).toDouble();
    final rating = (profile?['rating'] ?? 0.0).toDouble();
    final isVerified = profile?['is_verified'] ?? false;
    
    // Get stats - use database count for orders
    final totalOrders = stats?['total_orders'] ?? 0;
    
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
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User Info
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (isVerified)
                  const Icon(
                    Icons.verified,
                    size: 16,
                    color: Colors.white,
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  rating > 0 ? rating.toStringAsFixed(1) : '0.0',
                  l10n.rating,
                  Icons.star,
                ),
                _buildStatItem(
                  totalOrders.toString(),
                  l10n.orders,
                  Icons.assignment,
                ),
                _buildStatItem(
                  '₹${earnings.toStringAsFixed(0)}',
                  l10n.earned,
                  Icons.currency_rupee,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSection(l10n.account, [
            _buildProfileOption(
              icon: Icons.person_outline,
              title: l10n.personalInformation,
              subtitle: l10n.personalInfoSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.personalInformation),
            ), 
            _buildProfileOption(
              icon: Icons.motorcycle,
              title: l10n.vehicleDetails,
              subtitle: l10n.vehicleDetailsSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.vehicleDetails),
            ),
            _buildProfileOption(
              icon: Icons.credit_card,
              title: l10n.documents,
              subtitle: l10n.documentsSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.documents),
            ),
          ]),
          
          const SizedBox(height: 20),
          
          _buildSection(l10n.settings, [
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: l10n.notifications,
              subtitle: l10n.notificationsSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.notificationSettings),
            ),
            _buildProfileOption(
              icon: Icons.location_on_outlined,
              title: l10n.locationSettings,
              subtitle: l10n.locationSettingsSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.locationSettings),
            ),
            _buildProfileOption( 
              icon: Icons.language,
              title: l10n.language,
              subtitle: context.read<LanguageProvider>().getCurrentLanguageName(),
              onTap: () => Navigator.pushNamed(context, AppRoutes.languageSettings),
            ),
          ]),
          
          const SizedBox(height: 20),
          
          _buildSection(l10n.support, [
            _buildProfileOption(
              icon: Icons.help_outline,
              title: l10n.helpFaq,
              subtitle: l10n.helpFaqSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.helpFaq),
            ),
            _buildProfileOption(
              icon: Icons.support_agent,
              title: l10n.contactSupport,
              subtitle: l10n.contactSupportSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.contactSupport),
            ),
            _buildProfileOption( 
              icon: Icons.info_outline,
              title: l10n.about,
              subtitle: l10n.aboutSubtitle,
              onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            ),
          ]),
          
          const SizedBox(height: 30),
          
          // Logout Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context, l10n),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.logout,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> options) {
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: options),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
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

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logoutConfirmTitle),
          content: Text(l10n.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                
                await authProvider.signOut();
                userProvider.clearUserData();
                notificationProvider.clearNotificationData();
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  AppRoutes.goToLogin(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }
}