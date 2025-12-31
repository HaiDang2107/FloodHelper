import '../config/mobile_config.dart';

class ApiConstants {
  // For development on the same machine: 'http://localhost:3000'
  // For mobile testing (phone connected to same LAN): 'http://YOUR_LAN_IP:3000'
  // Example: 'http://192.168.1.100:3000'
  // Run the backend and check the console for your LAN IP addresses
  static String get baseUrl => MobileConfig.getBaseUrl();
  static const String authBasePath = '/auth';
}
