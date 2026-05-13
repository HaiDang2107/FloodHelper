import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/service_providers.dart';
import '../../../home/view_models/friend_view_model.dart';
import '../constants/global_keys.dart';

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
    final data = message.data;
    String? displayMessage;
    Color color = const Color(0xFF0F62FE); // Default info color

    if (data['announcementType'] == 'AUTHORITY' ||
        data['type'] == 'ANNOUNCEMENT_FROM_AUTHORITY') {
      displayMessage = message.notification?.title ?? 'Authority posted a new announcement';
    } else {
      switch (data['type']) {
        case 'FRIEND_REQUEST':
          _ref.read(friendViewModelProvider.notifier).loadRequests();
          final senderName = (data['senderName'] ?? 'Someone').toString();
          displayMessage = '$senderName sent you a friend request';
          break;
        case 'FRIEND_REQUEST_ACCEPTED':
          final senderId = data['userId']?.toString();
          if (senderId != null) {
            _ref.read(friendViewModelProvider.notifier).triggerAcceptedFriendSync(senderId);
          }
          _ref.read(friendViewModelProvider.notifier).loadRequests();
          displayMessage = 'Your friend request was accepted';
          color = Colors.green;
          break;
        default:
          // Fallback to notification body if available
          displayMessage = message.notification?.body;
          break;
      }
    }

    if (displayMessage != null) {
      _showSnackBar(displayMessage, color);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Basic implementation - can be expanded for deep linking
    final data = message.data;
    if (data['type'] == 'FRIEND_REQUEST' || data['type'] == 'FRIEND_REQUEST_ACCEPTED') {
      // Potentially navigate to a specific screen
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    GlobalKeys.messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

final globalNotificationControllerProvider = Provider((ref) => GlobalNotificationController(ref));
