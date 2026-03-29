import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/friend_request_model.dart';
import '../../../data/providers/providers.dart';
import '../../../data/repositories/friend_repository.dart';

part 'friend_view_model.g.dart';

/// State for friend request feature
class FriendRequestState {
  final List<FriendRequestModel> sentRequests;
  final List<FriendRequestModel> receivedRequests;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final String? successMessage;
  final String? acceptedFriendUserId;

  const FriendRequestState({
    this.sentRequests = const [],
    this.receivedRequests = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
    this.successMessage,
    this.acceptedFriendUserId,
  });

  FriendRequestState copyWith({
    List<FriendRequestModel>? sentRequests,
    List<FriendRequestModel>? receivedRequests,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
    String? successMessage,
    String? acceptedFriendUserId,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearAcceptedFriendUserId = false,
  }) {
    return FriendRequestState(
      sentRequests: sentRequests ?? this.sentRequests,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      acceptedFriendUserId: clearAcceptedFriendUserId
          ? null
          : (acceptedFriendUserId ?? this.acceptedFriendUserId),
    );
  }
}

@riverpod
class FriendViewModel extends _$FriendViewModel {
  late final FriendRepository _friendRepository;

  @override
  FriendRequestState build() {
    _friendRepository = ref.read(friendRepositoryProvider);

    // Auto-load requests on build
    Future.microtask(() => loadRequests());

    return const FriendRequestState();
  }

  /// Load both sent and received requests
  Future<void> loadRequests() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _friendRepository.getSentRequests(),
        _friendRepository.getReceivedRequests(),
      ]);

      state = state.copyWith(
        sentRequests: results[0],
        receivedRequests: results[1],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load requests: $e',
      );
    }
  }

  /// Send a friend request by user ID
  Future<bool> sendFriendRequest(String receiverId, {String? note}) async {
    state = state.copyWith(isSending: true, clearError: true, clearSuccess: true);
    try {
      await _friendRepository.sendFriendRequest(
        receiverId: receiverId,
        note: note,
      );

      // Reload sent requests to update UI
      final sentRequests = await _friendRepository.getSentRequests();

      state = state.copyWith(
        isSending: false,
        sentRequests: sentRequests,
        successMessage: 'Friend request sent successfully!',
      );
      return true;
    } catch (e) {
      String errorMsg = 'Failed to send friend request';
      final errorStr = e.toString();
      if (errorStr.contains('not found') || errorStr.contains('Not found')) {
        errorMsg = 'User not found. Please check the ID.';
      } else if (errorStr.contains('already friends')) {
        errorMsg = 'You are already friends with this user.';
      } else if (errorStr.contains('already exists')) {
        errorMsg = 'A friend request already exists.';
      } else if (errorStr.contains('yourself')) {
        errorMsg = 'You cannot send a request to yourself.';
      }

      state = state.copyWith(
        isSending: false,
        errorMessage: errorMsg,
      );
      return false;
    }
  }

  /// Accept a received friend request
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final acceptedRequest = state.receivedRequests.firstWhere(
        (request) => request.requestId == requestId,
      );

      await _friendRepository.acceptFriendRequest(requestId);

      // Remove from received list
      final updatedReceived = state.receivedRequests
          .where((r) => r.requestId != requestId)
          .toList();

      state = state.copyWith(
        receivedRequests: updatedReceived,
        successMessage: 'Friend request accepted!',
        acceptedFriendUserId: acceptedRequest.user.userId,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to accept request: $e',
      );
    }
  }

  /// Reject a received friend request
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _friendRepository.rejectFriendRequest(requestId);

      final updatedReceived = state.receivedRequests
          .where((r) => r.requestId != requestId)
          .toList();

      state = state.copyWith(
        receivedRequests: updatedReceived,
        successMessage: 'Friend request rejected.',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to reject request: $e',
      );
    }
  }

  /// Cancel a sent friend request
  Future<void> cancelFriendRequest(String requestId) async {
    try {
      await _friendRepository.cancelFriendRequest(requestId);

      final updatedSent = state.sentRequests
          .where((r) => r.requestId != requestId)
          .toList();

      state = state.copyWith(
        sentRequests: updatedSent,
        successMessage: 'Friend request cancelled.',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to cancel request: $e',
      );
    }
  }

  /// Add a received request to the list (called from push notification)
  void addReceivedRequest(FriendRequestModel request) {
    final updated = [request, ...state.receivedRequests];
    state = state.copyWith(receivedRequests: updated);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  void clearAcceptedFriendSyncEvent() {
    state = state.copyWith(clearAcceptedFriendUserId: true);
  }
}
