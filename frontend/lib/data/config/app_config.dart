// Centralized app configuration
// All environment-specific settings in one place

class AppConfig {
  AppConfig._();

  // ==================== MQTT (EMQX Cloud) ====================
  static const String mqttBrokerUrl = 've29bdd2.ala.asia-southeast1.emqxsl.com';
  static const int mqttPort = 8883;
  static const String mqttUsername = 'haidang';
  static const String mqttPassword = 'haidang';
  static const bool mqttUseSsl = true;

  // MQTT topic for publishing user location.
  // Convention: '{userId}/current-location'
  static const String mqttCurrentLocationSuffix = 'current-location';

  // MQTT topic for receiving friend's last known location.
  // Convention: '{friendId}/to_{myId}/last-location'
  static const String mqttLastLocationSuffix = 'last-location';

  // MQTT topic for distress signal commands.
  static const String mqttSignalTopic = 'signal';

  // MQTT topic for rescuer distress stream.
  static const String mqttRescuerCommonTopic = 'rescuer/common';

  // MQTT topic for rescuer handle actions.
  static const String mqttRescuerHandleTopic = 'rescuer/handle';

  // MQTT topic suffix for victim-side rescuer reply.
  static const String mqttRescuerReplySuffix = 'rescuer-reply';

  /// MQTT client ID prefix (will be appended with userId)
  static const String mqttClientIdPrefix = ''; // may be 'floodhelper_'

  // ==================== Location Tracking ====================

  /// Interval (in seconds) between each location publish to MQTT
  static const int locationPublishIntervalSeconds = 3;

  /// Location tracking accuracy
  /// Using 'high' for GPS-level accuracy
  static const bool locationHighAccuracy = true;

  // ==================== Background Service Notification ====================
  static const String notificationChannelId = 'floodhelper_location';
  static const String notificationChannelName = 'Location Tracking';
  static const String notificationTitle = 'FloodHelper đang hoạt động';
  static const String notificationContent = 'Đang chia sẻ vị trí với đội cứu hộ...';
  static const String distressAlertChannelId = 'floodhelper_distress_alert';
  static const String distressAlertChannelName = 'Distress Alerts';

  // ==================== API ====================
  /// Base URL for the backend API
  /// Current config: Development environment
  // static const String apiBaseUrl = 'http://192.168.88.106:3000'; // Android emulator localhost
  // static const String apiBaseUrl = 'http://192.168.1.164:3000'; // FaceNet
  static const String apiBaseUrl = 'http://192.168.1.160:3000'; // Home
  // static const String apiBaseUrl = 'http://192.168.1.159:3000'; // 
  // static const String apiBaseUrl = 'http://192.168.110.181:3000';
  // static const String apiBaseUrl = 'http://192.168.60.144:3000';
  // static const String apiBaseUrl = 'http://localhost:3000'; // iOS simulator / Web
  // static const String apiBaseUrl = 'https://your-production-api.com'; // Production
  // static const String apiBaseUrl = 'https://floodhelper.onrender.com';

  // ==================== Firebase ====================
  static const String fcmFriendRequestChannel = 'friend_requests';

  // ==================== Feature Flags ====================
  static const bool useMockData = false;
}
