import 'package:flutter/material.dart';
import 'package:antiflood/ui/auth/views/sign_in/signin_screen.dart';
import 'package:antiflood/ui/auth/views/sign_up/account_creation_screen.dart';
import 'package:antiflood/ui/auth/views/forget_password/forget_password_screen.dart';
import 'package:antiflood/ui/home/views/home_screen.dart';

class AppRoutes {
  static const String signIn = '/signin';
  static const String accountCreation = '/account-creation';
  static const String forgetPassword = '/forget-password';
  static const String home = '/home';

  // Hiển thị manh hình dựa trên tên route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
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
          builder: (_) => const SignInScreen(showFormInitially: true),
        );
    }
  }
}
