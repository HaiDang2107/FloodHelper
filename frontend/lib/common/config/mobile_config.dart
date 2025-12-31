// Mobile development configuration
// Uncomment and update the IP address when testing on mobile device
// The IP address should be one of the LAN addresses shown when you start the backend

class MobileConfig {
  // For mobile testing, replace with your computer's LAN IP
  // Example: 'http://192.168.1.100:3000'
  // Leave as null for localhost development3000
  static const String? mobileBaseUrl = 'http://10.177.173.50:3000';

  // Helper method to get the correct base URL
  static String getBaseUrl() {
    return mobileBaseUrl ?? 'http://localhost:3000';
  }
}

// SETUP INSTRUCTIONS FOR MOBILE TESTING:
// =====================================
// 1. Start your backend server: npm run start:dev (in backend folder)
// 2. Check the console output for LAN IP addresses (look for "🌐 LAN Addresses")
// 3. Copy one of the IP addresses (e.g., http://192.168.1.100:3000)
// 4. Replace null with the IP address: static const String? mobileBaseUrl = 'http://192.168.1.100:3000';
// 5. Run: flutter clean && flutter pub get
// 6. Make sure your phone and computer are on the same WiFi network
// 7. Run your app on mobile device: flutter run
//
// TROUBLESHOOTING:
// - If connection fails, try a different LAN IP from the list
// - Make sure firewall allows connections on port 3000
// - Test the IP address in your phone's browser first