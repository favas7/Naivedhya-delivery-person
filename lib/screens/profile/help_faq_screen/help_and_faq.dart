import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.account_circle_outlined), text: 'Account'),
            Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Orders'),
            Tab(icon: Icon(Icons.payment), text: 'Payments'),
            Tab(icon: Icon(Icons.description_outlined), text: 'Documents'),
            Tab(icon: Icon(Icons.smartphone), text: 'App Usage'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAccountManagementFAQ(),
                _buildOrdersFAQ(),
                _buildPaymentsFAQ(),
                _buildVehicleDocumentsFAQ(),
                _buildAppUsageFAQ(),
              ],
            ),
          ),
          _buildContactSupportSection(),
        ],
      ),
    );
  }

  Widget _buildAccountManagementFAQ() {
    final faqs = [
      {
        'question': 'How do I update my profile?',
        'answer': 'Go to Settings > Profile > Edit Profile. Update your information and tap Save to confirm changes.',
      },
      {
        'question': 'How do I change my password?',
        'answer': 'Go to Settings > Security > Change Password. Enter your current password and new password to update.',
      },
      {
        'question': 'How do I verify my account?',
        'answer': 'Upload required documents in Settings > Documents. Our team will review and verify your account within 24-48 hours.',
      },
      {
        'question': 'I can\'t access my account',
        'answer': 'Try resetting your password using "Forgot Password" on the login screen. If the issue persists, contact support.',
      },
      {
        'question': 'How do I delete my account?',
        'answer': 'Contact our support team to request account deletion. Please note this action cannot be undone.',
      },
    ];
    
    return _buildFAQList(faqs);
  }

  Widget _buildOrdersFAQ() {
    final faqs = [
      {
        'question': 'How do I accept an order?',
        'answer': 'When you receive an order notification, tap "Accept" to confirm. You have 30 seconds to respond.',
      },
      {
        'question': 'What if I can\'t find the customer?',
        'answer': 'Call the customer using the in-app calling feature. If unreachable, contact support for guidance.',
      },
      {
        'question': 'How do I mark an order as delivered?',
        'answer': 'At the delivery location, tap "Mark as Delivered" and take a photo if required by the customer.',
      },
      {
        'question': 'What if an order gets cancelled?',
        'answer': 'If an order is cancelled, you\'ll be notified immediately. You may receive partial compensation for travel time.',
      },
      {
        'question': 'How do I report a problem with an order?',
        'answer': 'Go to Order History, select the order, and tap "Report Issue". Provide details about the problem.',
      },
    ];
    
    return _buildFAQList(faqs);
  }

  Widget _buildPaymentsFAQ() {
    final faqs = [
      {
        'question': 'When do I get paid?',
        'answer': 'Earnings are transferred to your bank account weekly on Mondays. Payments may take 1-2 business days to reflect.',
      },
      {
        'question': 'How do I add my bank account?',
        'answer': 'Go to Settings > Payment Details > Add Bank Account. Enter your account details and verify with OTP.',
      },
      {
        'question': 'What if my payment is delayed?',
        'answer': 'Check your bank details in Settings > Payment Details. If correct, contact support with your transaction details.',
      },
      {
        'question': 'How do I view my earnings?',
        'answer': 'Go to the Earnings tab to view daily, weekly, and monthly earnings along with detailed breakdowns.',
      },
      {
        'question': 'What about taxes?',
        'answer': 'You are responsible for your own taxes. We provide earning statements to help with tax filing.',
      },
    ];
    
    return _buildFAQList(faqs);
  }

  Widget _buildVehicleDocumentsFAQ() {
    final faqs = [
      {
        'question': 'What documents are required?',
        'answer': 'You need: Driving License, Vehicle Registration, Insurance Certificate, and PAN Card for verification.',
      },
      {
        'question': 'How do I upload documents?',
        'answer': 'Go to Settings > Documents, tap on each document type, and upload clear photos. Ensure all text is readable.',
      },
      {
        'question': 'Why was my document rejected?',
        'answer': 'Common reasons: blurry images, expired documents, incorrect document type, or missing information.',
      },
      {
        'question': 'How do I update an expired document?',
        'answer': 'Go to Settings > Documents, find the expired document, and tap "Update" to upload the renewed version.',
      },
      {
        'question': 'Can I change my vehicle?',
        'answer': 'Yes, contact support to update your vehicle details. You\'ll need to upload new vehicle documents.',
      },
    ];
    
    return _buildFAQList(faqs);
  }

  Widget _buildAppUsageFAQ() {
    final faqs = [
      {
        'question': 'How do I go online to receive orders?',
        'answer': 'Tap the "Go Online" button on the main screen. Ensure your location services are enabled.',
      },
      {
        'question': 'The app is not working properly',
        'answer': 'Try restarting the app. If issues persist, clear app cache or reinstall the app. Contact support if needed.',
      },
      {
        'question': 'How do I change the app language?',
        'answer': 'Go to Settings > Language and select your preferred language from the available options.',
      },
      {
        'question': 'Why is my battery draining fast?',
        'answer': 'GPS tracking can drain battery. Use power saving mode and consider using a car charger during long shifts.',
      },
      {
        'question': 'I\'m not getting any orders',
        'answer': 'Check if you\'re online, in a high-demand area, and during peak hours. Ensure all documents are verified.',
      },
    ];
    
    return _buildFAQList(faqs);
  }

  Widget _buildFAQList(List<Map<String, String>> faqs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return _buildFAQItem(faqs[index]['question']!, faqs[index]['answer']!);
      },
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Still need help?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _contactSupport(context),
                  icon: const Icon(Icons.support_agent, size: 20),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openHelpResources(context),
                  icon: const Icon(Icons.video_library_outlined, size: 20),
                  label: const Text('Help Videos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone, color: AppColors.primary),
              ),
              title: const Text('Call Support'),
              subtitle: const Text('+91 9876543210'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement phone call
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.email, color: AppColors.secondary),
              ),
              title: const Text('Email Support'),
              subtitle: const Text('support@naivedhya.com'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement email
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat, color: AppColors.accent),
              ),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement live chat
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openHelpResources(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Videos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: AppColors.warning,
            ),
            SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We are working on video tutorials to help you get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}