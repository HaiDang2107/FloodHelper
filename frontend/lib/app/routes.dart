import 'package:flutter/material.dart';
import 'package:antiflood/features/auth/screens/sign_in/signin_screen.dart';
import 'package:antiflood/features/auth/screens/sign_up/account_creation_screen.dart';
import 'package:antiflood/features/auth/screens/forget_password/forget_password_screen.dart';
import 'package:antiflood/features/home/screens/home_screen.dart';

class AppRoutes {
  static const String signUp = '/signup';
  static const String accountCreation = '/account-creation';
  static const String forgetPassword = '/forget-password';
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
      case forgetPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgetPasswordScreen(),
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
