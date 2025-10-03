// File: lib/views/main/home/home_screen.dart (UPDATED)
// Only showing the updated error handling part - keep rest of your code

import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/delivery_provider.dart';
import 'package:naivedhya_delivery_app/utils/routes/app_route_info.dart';
import 'package:naivedhya_delivery_app/views/main/home/map_screen.dart';
import 'package:naivedhya_delivery_app/utils/error_type.dart';
import 'package:naivedhya_delivery_app/views/main/widgets/error_screen.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      deliveryProvider.initializeDeliveryData(authProvider.user!.id);
    }
  }

  void _handleAuthError() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Clear session and navigate to login
    authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login, // Make sure you have this route defined
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<AuthProvider, DeliveryProvider>(
          builder: (context, authProvider, deliveryProvider, child) {
            if (deliveryProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // UPDATED ERROR HANDLING - Shows different screens based on error type
            if (deliveryProvider.error != null) {
              final error = deliveryProvider.error!; // Store error in variable
              return ErrorScreen(
                errorType: error.type,
                message: error.message,
                onRetry: () {
                  deliveryProvider.clearError(); 
                  // For auth errors, redirect to login
                  if (error.type == ErrorType.authentication) {
                    _handleAuthError();
                  } else {
                    _initializeData();
                  }
                },
                onSecondaryAction: deliveryProvider.error!.type == ErrorType.authentication 
                  ? null 
                  : () {
                    // Optional: Navigate back or to another screen
                    Navigator.pop(context);
                  },
                secondaryActionLabel: 'Go Back',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (authProvider.user != null) {
                  await deliveryProvider.refreshData(authProvider.user!.id);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(deliveryProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Online/Offline Status
                    _buildStatusToggle(authProvider, deliveryProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Cards
                    _buildStatsCards(deliveryProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Orders
                    _buildRecentOrders(deliveryProvider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ... REST OF YOUR CODE REMAINS THE SAME ...
  // (Keep all your existing _buildHeader, _buildStatusToggle, _buildStatsCards, etc. methods)

  Widget _buildHeader(DeliveryProvider deliveryProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                deliveryProvider.deliveryPersonName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // Show notifications
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusToggle(AuthProvider authProvider, DeliveryProvider deliveryProvider) {
    final isOnline = deliveryProvider.isAvailable;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isOnline ? AppColors.primaryGradient : const LinearGradient(
          colors: [Colors.grey, Colors.grey],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? AppColors.primary : Colors.grey).withAlpha(51),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You\'re Online' : 'You\'re Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline 
                      ? 'Ready to accept new orders'
                      : 'Go online to start receiving orders',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            onChanged: (value) async {
              if (authProvider.user != null) {
                await deliveryProvider.toggleAvailability(authProvider.user!.id);
              }
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.white30,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(DeliveryProvider deliveryProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Today\'s Orders',
            deliveryProvider.todaysOrdersCount.toString(),
            Icons.assignment_turned_in,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Today\'s Earnings',
            '₹${deliveryProvider.todaysEarnings.toStringAsFixed(0)}',
            Icons.currency_rupee,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'View Map',
                Icons.map_outlined,
                AppColors.secondary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Support',
                Icons.support_agent_outlined,
                AppColors.primary,
                () {
                  Navigator.pushNamed(context, AppRoutes.contactSupport);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded( 
              child: _buildActionButton(
                'Settings',
                Icons.settings_outlined,
                AppColors.textSecondary,
                () {
                  Navigator.pushNamed(context, AppRoutes.settings1);
                },
              ), 
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(DeliveryProvider deliveryProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to orders screen
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (deliveryProvider.recentOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No recent orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your recent orders will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: deliveryProvider.recentOrders.length,
            itemBuilder: (context, index) {
              final order = deliveryProvider.recentOrders[index];
              return _buildOrderCard(
                orderId: order['order_number'] ?? '#${order['order_id']?.toString().substring(0, 8)}',
                customerName: order['customer_name'] ?? 'Customer',
                amount: '₹${(order['total_amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                status: deliveryProvider.getOrderStatusDisplay(order['status'], order['delivery_status']),
                time: deliveryProvider.getTimeAgo(order['created_at']),
                deliveryProvider: deliveryProvider,
              );
            },
          ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String customerName,
    required String amount,
    required String status,
    required String time,
    required DeliveryProvider deliveryProvider,
  }) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = AppColors.success;
        break;
      case 'in progress':
      case 'picked up':
        statusColor = AppColors.warning;
        break;
      case 'assigned':
        statusColor = AppColors.primary;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  customerName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}