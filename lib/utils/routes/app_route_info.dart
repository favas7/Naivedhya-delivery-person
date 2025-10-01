// lib/routes/app_routes.dart

import 'package:flutter/material.dart';

// App screens
import 'package:naivedhya_delivery_app/views/app/onboarding_screen.dart';
import 'package:naivedhya_delivery_app/views/app/splash_screen.dart';
import 'package:naivedhya_delivery_app/views/app/bottom_nav_screen.dart';

// Auth screens
import 'package:naivedhya_delivery_app/views/auth/forgotpass/forgot_password_screen.dart';
import 'package:naivedhya_delivery_app/views/auth/login/login_screen.dart';
import 'package:naivedhya_delivery_app/views/auth/signup/signup_screen.dart';
import 'package:naivedhya_delivery_app/views/main/home/settings_screen.dart';

// Profile screens
import 'package:naivedhya_delivery_app/views/main/profile/about_screen/about_screen.dart';
import 'package:naivedhya_delivery_app/views/main/profile/contact_support_screen/contact_support_screen.dart';
import 'package:naivedhya_delivery_app/views/main/profile/document_screen/document_screen.dart';
import 'package:naivedhya_delivery_app/views/main/profile/help_faq_screen/help_and_faq.dart';
import 'package:naivedhya_delivery_app/views/main/profile/language_settings_screen/language_settings_screen.dart';
import 'package:naivedhya_delivery_app/views/main/profile/location_settings_screen.dart/location_settings_screen.dart';
import 'package:naivedhya_delivery_app/views/main/profile/notification_screen/notification_settings_screen.dart';
import 'package:naivedhya_delivery_app/views/main/profile/personal_info_screen/personal_info_screen.dart';
import 'package:naivedhya_delivery_app/views/main/profile/vehicle_detail_screen/vehicle_details_screen.dart';

class AppRoutes {
  // App routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  // Profile routes
  static const String profile = '/profile';
  static const String settings1 = '/settings';
  static const String personalInformation = '/profile/personal-information';
  static const String vehicleDetails = '/profile/vehicle-details';
  static const String documents = '/profile/documents';
  static const String notificationSettings = '/profile/notifications';
  static const String locationSettings = '/profile/location';
  static const String languageSettings = '/profile/language';
  static const String helpFaq = '/profile/help-faq';
  static const String contactSupport = '/profile/contact-support';
  static const String about = '/profile/about';
 
  // Static routes map for simple navigation
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    home: (context) => const BottomNavScreen(),
    settings1: (context) => const SettingsScreen(),
    personalInformation: (context) => const PersonalInformationScreen(),
    vehicleDetails: (context) => const VehicleDetailsScreen(),
    documents: (context) => const DocumentsScreen(),
    notificationSettings: (context) => const NotificationSettingsScreen(),
    locationSettings: (context) => const LocationSettingsScreen(),
    languageSettings: (context) => const LanguageSettingsScreen(),
    helpFaq: (context) => const HelpFaqScreen(),
    contactSupport: (context) => const ContactSupportScreen(),
    about: (context) => const AboutScreen(),
  };

  // Custom route generation for complex navigation
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Extract route name and arguments
    final String routeName = settings.name ?? '';
    final Object? _ = settings.arguments;

    // Handle routes with custom transitions or parameters
    switch (routeName) {
      case splash:
        return _createRoute(const SplashScreen(), settings);
        
      case onboarding:
        return _createRoute(const OnboardingScreen(), settings);
        
      case login:
        return _createRoute(const LoginScreen(), settings);
        
      case signup:
        return _createRoute(const SignupScreen(), settings);
        
      case forgotPassword:
        return _createRoute(const ForgotPasswordScreen(), settings);
        
      case home:
        return _createRoute(const BottomNavScreen(), settings);
        
      case settings1:
        return _createRoute(const SettingsScreen(), settings);
        
      // Profile routes
      case personalInformation:
        return _createRoute(const PersonalInformationScreen(), settings);
        
      case vehicleDetails:
        return _createRoute(const VehicleDetailsScreen(), settings);
        
      case documents:
        return _createRoute(const DocumentsScreen(), settings);
        
      case notificationSettings:
        return _createRoute(const NotificationSettingsScreen(), settings);
        
      case locationSettings:
        return _createRoute(const LocationSettingsScreen(), settings);
        
      case languageSettings:
        return _createRoute(const LanguageSettingsScreen(), settings);
        
      case helpFaq:
        return _createRoute(const HelpFaqScreen(), settings);
        
      case contactSupport:
        return _createRoute(const ContactSupportScreen(), settings);
        
      case about:
        return _createRoute(const AboutScreen(), settings);
        
      default:
        // Handle unknown routes
        return _createRoute(
          _buildUnknownRoute(routeName), 
          settings,
        );
    }
  }

  // Create custom route with slide transition
  static Route<dynamic> _createRoute(Widget page, RouteSettings settings, {
    bool slideTransition = true,
  }) {
    if (slideTransition) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        settings: settings,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
    } else {
      return MaterialPageRoute(
        builder: (context) => page,
        settings: settings,
      );
    }
  }

  // Build unknown route widget
  static Widget _buildUnknownRoute(String routeName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Route "$routeName" not found',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Go back or navigate to home
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation helper methods
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context, 
      routeName, 
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context, 
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context, 
      routeName, 
      result: result,
      arguments: arguments,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context, 
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context, 
      routeName, 
      predicate,
      arguments: arguments,
    );
  }

  // Quick navigation methods
  static Future<void> goToLogin(BuildContext context) {
    return pushNamedAndRemoveUntil(
      context, 
      login, 
      (route) => false,
    );
  }

  static Future<void> goToHome(BuildContext context) {
    return pushNamedAndRemoveUntil(
      context, 
      home, 
      (route) => false,
    );
  }

  static Future<void> goToOnboarding(BuildContext context) {
    return pushReplacementNamed(context, onboarding);
  }

  static Future<void> goToSettings(BuildContext context) {
    return pushNamed(context, settings1);
  }
} 