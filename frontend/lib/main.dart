import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'data/services/firebase_messaging_service.dart';
import 'data/providers/service_providers.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  if (DefaultFirebaseOptions.isSupportedPlatform) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  
  // Create provider container
  final container = ProviderContainer();
  
  // Initialize ApiClient persistent cookie jar for auto-login
  await container.read(apiClientProvider).init();

  // Initialize background location service (configures foreground service)
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await container.read(locationTrackingServiceProvider).initialize();
  }
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}
