part of 'home_view_model.dart';

enum MapType { transport, weather }

enum HomeUiEventType { info, success, error }

enum HomePinType { me, friend, victim }

class HomeMapPin {
  final String userId;
  final String fullname;
  final String avatarUrl;
  final LatLng position;
  final HomePinType pinType;
  final bool isSos;

  const HomeMapPin({
    required this.userId,
    required this.fullname,
    required this.avatarUrl,
    required this.position,
    required this.pinType,
    required this.isSos,
  });
}

class HomePinBubbleData {
  final String title;
  final String userId;
  final String fullname;
  final HomePinType pinType;
  final bool canHandle;

  const HomePinBubbleData({
    required this.title,
    required this.userId,
    required this.fullname,
    required this.pinType,
    required this.canHandle,
  });
}

class HomeUiEvent {
  final HomeUiEventType type;
  final String message;

  const HomeUiEvent({required this.type, required this.message});
}

class HomeState {
  final LatLng? currentPosition;
  final bool isLoading;
  final MapType selectedMapType;
  final bool isSosBroadcasting;
  final DistressSignalInput? sosData;
  final bool showStrangerLocation;
  final bool showPostLocation;
  final String? selectedPinId;
  final String? errorMessage;
  final HomeUiEvent? uiEvent;

  final List<UserModel> nearbyUsers;
  final List<PostModel> posts;
  final List<AnnouncementModel> announcements;
  final int unreadAnnouncementsCount;

  final Map<String, LatLng> friendLocations;
  final Map<String, LatLng> victimLocations;
  final Map<String, String> victimFullnames;

  final List<FriendModel> friendsWithMapMode;

  final String locationVisibility;

  const HomeState({
    this.currentPosition,
    this.isLoading = true,
    this.selectedMapType = MapType.transport,
    this.isSosBroadcasting = false,
    this.sosData,
    this.showStrangerLocation = true,
    this.showPostLocation = true,
    this.selectedPinId,
    this.errorMessage,
    this.uiEvent,
    this.nearbyUsers = const [],
    this.posts = const [],
    this.announcements = const [],
    this.unreadAnnouncementsCount = 0,
    this.friendLocations = const {},
    this.victimLocations = const {},
    this.victimFullnames = const {},
    this.friendsWithMapMode = const [],
    this.locationVisibility = 'JUST_FRIEND',
  });

  HomeState copyWith({
    LatLng? currentPosition,
    bool? isLoading,
    MapType? selectedMapType,
    bool? isSosBroadcasting,
    DistressSignalInput? sosData,
    bool? showStrangerLocation,
    bool? showPostLocation,
    String? selectedPinId,
    String? errorMessage,
    HomeUiEvent? uiEvent,
    bool clearSosData = false,
    bool clearUiEvent = false,
    bool clearSelectedPin = false,
    List<UserModel>? nearbyUsers,
    List<PostModel>? posts,
    List<AnnouncementModel>? announcements,
    int? unreadAnnouncementsCount,
    Map<String, LatLng>? friendLocations,
    Map<String, LatLng>? victimLocations,
    Map<String, String>? victimFullnames,
    List<FriendModel>? friendsWithMapMode,
    String? locationVisibility,
  }) {
    return HomeState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      selectedMapType: selectedMapType ?? this.selectedMapType,
      isSosBroadcasting: isSosBroadcasting ?? this.isSosBroadcasting,
      sosData: clearSosData ? null : (sosData ?? this.sosData),
      showStrangerLocation: showStrangerLocation ?? this.showStrangerLocation,
      showPostLocation: showPostLocation ?? this.showPostLocation,
      selectedPinId: clearSelectedPin
          ? null
          : (selectedPinId ?? this.selectedPinId),
      errorMessage: errorMessage,
      uiEvent: clearUiEvent ? null : (uiEvent ?? this.uiEvent),
      nearbyUsers: nearbyUsers ?? this.nearbyUsers,
      posts: posts ?? this.posts,
      announcements: announcements ?? this.announcements,
      unreadAnnouncementsCount:
          unreadAnnouncementsCount ?? this.unreadAnnouncementsCount,
      friendLocations: friendLocations ?? this.friendLocations,
      victimLocations: victimLocations ?? this.victimLocations,
      victimFullnames: victimFullnames ?? this.victimFullnames,
      friendsWithMapMode: friendsWithMapMode ?? this.friendsWithMapMode,
      locationVisibility: locationVisibility ?? this.locationVisibility,
    );
  }
}
