import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context),
            
            const SizedBox(height: 20),
            
            // Profile Options
            _buildProfileOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
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
                        color: Colors.black.withAlpha(0),
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
                  authProvider.user?.email?.split('@')[0] ?? 'Delivery Partner',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  authProvider.user?.email ?? 'deliverypartner@naivedhya.com',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('4.8', 'Rating', Icons.star),
                    _buildStatItem('156', 'Orders', Icons.assignment),
                    _buildStatItem('2.5k', 'Earned', Icons.currency_rupee),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildProfileOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSection('Account', [
            _buildProfileOption(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Update your personal details',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.motorcycle,
              title: 'Vehicle Details',
              subtitle: 'Manage your vehicle information',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.credit_card,
              title: 'Documents',
              subtitle: 'License, Aadhaar and other documents',
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 20),
          
          _buildSection('Settings', [
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.location_on_outlined,
              title: 'Location Settings',
              subtitle: 'Update location and privacy settings',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 20),
          
          _buildSection('Support', [
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: 'Get help and find answers',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.support_agent,
              title: 'Contact Support',
              subtitle: '24/7 customer support',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 30),
          
          // Logout Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
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
                color: Colors.black.withAlpha(0),
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
          color: AppColors.primary.withAlpha(0),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/onboarding');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}