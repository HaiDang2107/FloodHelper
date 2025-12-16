import 'package:flutter/material.dart';
import 'package:antiflood/features/auth/screens/signin/signin_screen.dart';
import 'package:antiflood/features/auth/screens/signup/account_creation_screen.dart';
import 'package:antiflood/features/home/screens/home_screen.dart';

class AppRoutes {
  static const String signUp = '/signup';
  static const String accountCreation = '/account-creation';
  static const String home = '/home';

  // Hiển thị manh hình dựa trên tên route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case accountCreation:
        return MaterialPageRoute(
          builder: (_) => const AccountCreationScreen(),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(showFormInitially: true),
        );
    }
  }
}
