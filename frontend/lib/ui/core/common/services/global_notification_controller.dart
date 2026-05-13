import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/service_providers.dart';
import '../../../home/view_models/friend_view_model.dart';
import '../../../home/view_models/home_view_model.dart';
import '../constants/global_keys.dart';
import '../widgets/global_notification.dart';

class GlobalNotificationController {
  final Ref _ref;
  bool _isInitialized = false;

  GlobalNotificationController(this._ref);

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    final messagingService = _ref.read(firebaseMessagingServiceProvider);
    messagingService.onForegroundMessage(_handleForegroundMessage);
    messagingService.onMessageOpenedApp(_handleMessageOpenedApp);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    
    String? displayMessage = notification?.body;
    Color color = const Color(0xFF0F62FE); // Default info color

    final type = data['type'];

    // Customize based on message type and refresh relevant state
    if (type == 'FRIEND_REQUEST') {
      color = const Color(0xFF0F62FE);
      _ref.read(friendViewModelProvider.notifier).loadReceivedRequests();
      final senderName = data['senderName'] ?? 'Someone';
      displayMessage = '$senderName sent you a friend request';
    } else if (type == 'FRIEND_REQUEST_ACCEPTED') {
      color = Colors.green;
      final senderId = data['userId']?.toString();
      if (senderId != null) {
        _ref.read(friendViewModelProvider.notifier).triggerAcceptedFriendSync(senderId);
      }
      _ref.read(homeViewModelProvider.notifier).refreshFriends();
      displayMessage = 'Your friend request was accepted';
    } else if (type == 'FRIEND_REQUEST_REJECTED') {
      color = Colors.orange;
      _ref.read(friendViewModelProvider.notifier).loadSentRequests();
      displayMessage = 'Your friend request was rejected';
    } else if (type == 'EMERGENCY_ALERT') {
      color = Colors.red;
    } else if (data['announcementType'] == 'AUTHORITY' ||
        data['type'] == 'ANNOUNCEMENT_FROM_AUTHORITY') {
      displayMessage = notification?.title ?? 'Authority posted a new announcement';
    }

    if (displayMessage != null) {
      showNotification(displayMessage, backgroundColor: color);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Basic implementation - can be expanded for deep linking
    final data = message.data;
    if (data['type'] == 'FRIEND_REQUEST' ||
        data['type'] == 'FRIEND_REQUEST_ACCEPTED' ||
        data['type'] == 'FRIEND_REQUEST_REJECTED') {
      // Potentially navigate to a specific screen
    }
  }

  void showNotification(String message,
      {Color? backgroundColor, Duration duration = const Duration(seconds: 3)}) {
    final overlayState = GlobalKeys.navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => GlobalNotification(
        message: message,
        backgroundColor: backgroundColor ?? const Color(0xFF0F62FE),
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

final globalNotificationControllerProvider =
    Provider((ref) => GlobalNotificationController(ref));
