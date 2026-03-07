import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'data/services/api_client.dart';
import 'data/services/firebase_messaging_service.dart';
import 'data/services/location_tracking_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize persistent cookie jar for auto-login
  await ApiClient().init();

  // Initialize background location service (configures foreground service)
  await LocationTrackingService().initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
