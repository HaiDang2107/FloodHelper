import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return android;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPxiAAq68u5voQx7i8gSAnT5jkDxM2uAs',
    appId: '1:809425891688:android:47d08944284c7939a5a6dd',
    messagingSenderId: '809425891688',
    projectId: 'floodhelper-374c0',
    storageBucket: 'floodhelper-374c0.firebasestorage.app',
  );
}
