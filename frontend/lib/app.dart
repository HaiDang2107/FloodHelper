import 'package:flutter/material.dart';
import 'routing/routes.dart';
import 'core/common/constants/global_keys.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/common/services/global_notification_controller.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize global messaging
    ref.read(globalNotificationControllerProvider).init();

    return MaterialApp(
      title: 'FloodHelper',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: GlobalKeys.messengerKey,
      navigatorKey: GlobalKeys.navigatorKey,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      initialRoute: AppRoutes.signIn,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
