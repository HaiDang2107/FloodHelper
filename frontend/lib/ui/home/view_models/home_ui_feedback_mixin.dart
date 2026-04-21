part of 'home_view_model.dart';

mixin HomeUiFeedbackMixin on _HomeViewModelBase {
  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    switch (data['type']) {
      case 'FRIEND_REQUEST':
        unawaited(ref.read(friendViewModelProvider.notifier).loadRequests());
        final senderName = (data['senderName'] ?? 'Someone').toString();
        _emitUiEvent(
          '$senderName sent you a friend request',
          HomeUiEventType.info,
        );
        break;
      case 'FRIEND_REQUEST_ACCEPTED':
        unawaited(refreshFriends());
        unawaited(ref.read(friendViewModelProvider.notifier).loadRequests());
        _emitUiEvent(
          'Your friend request was accepted',
          HomeUiEventType.success,
        );
        break;
      default:
        break;
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {}

  void showInfoMessage(String message) {
    _emitUiEvent(message, HomeUiEventType.info);
  }

  void clearUiEvent() {
    state = state.copyWith(clearUiEvent: true);
  }

  void _emitUiEvent(String message, HomeUiEventType type) {
    state = state.copyWith(
      uiEvent: HomeUiEvent(type: type, message: message),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
