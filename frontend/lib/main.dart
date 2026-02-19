import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/services/api_client.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize persistent cookie jar for auto-login
  await ApiClient().init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
