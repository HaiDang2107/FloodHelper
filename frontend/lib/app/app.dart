import 'package:flutter/material.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FloodHelper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.signUp,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
