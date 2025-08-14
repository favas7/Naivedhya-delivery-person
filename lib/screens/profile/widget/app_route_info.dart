// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/screens/profile/document_screen/document_screen.dart';
import 'package:naivedhya_delivery_app/screens/profile/personal_info_screen/personal_info_screen.dart';
import 'package:naivedhya_delivery_app/screens/profile/profile_screen.dart';
import 'package:naivedhya_delivery_app/screens/profile/vehicle_detail_screen/vehicle_details_screen.dart';

class AppRoutes {
  static const String profile = '/profile';
  static const String personalInformation = '/profile/personal-information';
  static const String vehicleDetails = '/profile/vehicle-details';
  static const String documents = '/profile/documents';
  
  static Map<String, WidgetBuilder> routes = {
    profile: (context) => const ProfileScreen(),
    personalInformation: (context) => const PersonalInformationScreen(),
    vehicleDetails: (context) => const VehicleDetailsScreen(),
    documents: (context) => const DocumentsScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case profile:
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
          settings: settings,
        );
      case personalInformation:
        return MaterialPageRoute(
          builder: (context) => const PersonalInformationScreen(),
          settings: settings,
        );
      case vehicleDetails:
        return MaterialPageRoute(
          builder: (context) => const VehicleDetailsScreen(),
          settings: settings,
        );
      case documents:
        return MaterialPageRoute(
          builder: (context) => const DocumentsScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}