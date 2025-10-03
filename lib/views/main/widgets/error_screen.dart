// File: lib/widgets/error_screen.dart

import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:naivedhya_delivery_app/utils/error_type.dart';

class ErrorScreen extends StatefulWidget {
  final ErrorType errorType;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;

  const ErrorScreen({
    super.key,
    required this.errorType,
    required this.message,
    required this.onRetry,
    this.onSecondaryAction,
    this.secondaryActionLabel,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _getErrorColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getErrorIcon(),
                  size: 80,
                  color: _getErrorColor(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Error Title
            Text(
              _getErrorTitle(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Error Message
            Text(
              widget.message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Primary Action Button (Retry)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getErrorColor(),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getRetryButtonText(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Secondary Action Button (if provided)
            if (widget.onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
              ),
            ],

            // Additional Help Text
            if (widget.errorType == ErrorType.network) ...[
              const SizedBox(height: 24),
              _buildHelpText(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Troubleshooting Tips',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHelpItem('Check your WiFi or mobile data'),
          _buildHelpItem('Turn airplane mode off'),
          _buildHelpItem('Check if other apps are working'),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getErrorColor() {
    switch (widget.errorType) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.authentication:
        return AppColors.primary;
      case ErrorType.server:
        return AppColors.error;
      case ErrorType.unknown:
        return AppColors.textSecondary;
    }
  }

  IconData _getErrorIcon() {
    switch (widget.errorType) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.authentication:
        return Icons.lock_outline_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  String _getErrorTitle() {
    switch (widget.errorType) {
      case ErrorType.network:
        return 'No Internet Connection';
      case ErrorType.authentication:
        return 'Session Expired';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.unknown:
        return 'Something Went Wrong';
    }
  }

  String _getRetryButtonText() {
    switch (widget.errorType) {
      case ErrorType.authentication:
        return 'Login Again';
      default:
        return 'Try Again';
    }
  }
}