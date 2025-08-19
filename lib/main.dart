import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/config/supabase_config.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/delivery_provider.dart';
import 'package:naivedhya_delivery_app/provider/location_settings_provider.dart';
import 'package:naivedhya_delivery_app/provider/order_provider.dart';
import 'package:naivedhya_delivery_app/provider/user_provider.dart';
import 'package:naivedhya_delivery_app/provider/notification_provider.dart';
import 'package:naivedhya_delivery_app/screens/app/onboarding_screen.dart';
import 'package:naivedhya_delivery_app/screens/app/splash_screen.dart';
import 'package:naivedhya_delivery_app/screens/auth/forgot_password_screen.dart';
import 'package:naivedhya_delivery_app/screens/auth/login_screen.dart';
import 'package:naivedhya_delivery_app/screens/auth/signup/signup_screen.dart';
import 'package:naivedhya_delivery_app/screens/app/bottom_nav_screen.dart';
import 'package:naivedhya_delivery_app/screens/profile/widget/app_route_info.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        // Set up the sync callback after both providers are created
        ProxyProvider2<DeliveryProvider, OrdersProvider, void>(
          update: (context, deliveryProvider, ordersProvider, _) {
            ordersProvider.setSyncCallback((userId) {
              deliveryProvider.syncWithOrdersProvider(userId);
            });
            return;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Naivedhya Delivery Partner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.secondary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.secondary.withAlpha(0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const BottomNavScreen(),
          // Add AppRoutes
          ...AppRoutes.routes,
        },
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}