import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// User/Friend model for data layer
class UserModel {
  final String id;
  final String name;
  final String? displayName;
  final String avatarUrl;
  final String status; // 'online', 'offline'
  final double latitude;
  final double longitude;
  final bool isSosState;
  final List<String> roles;
  final DateTime? dateOfBirth;
  final bool isFriend;
  
  // SOS related fields
  final int? trappedCounts;
  final int? childrenNumbers;
  final int? elderlyNumbers;
  final bool? hasFood;
  final bool? hasWater;
  final String? other;

  const UserModel({
    required this.id,
    required this.name,
    this.displayName,
    required this.avatarUrl,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.isSosState = false,
    this.roles = const [],
    this.dateOfBirth,
    this.isFriend = false,
    this.trappedCounts,
    this.childrenNumbers,
    this.elderlyNumbers,
    this.hasFood,
    this.hasWater,
    this.other,
  });

  LatLng get location => LatLng(latitude, longitude);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['userId'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'] ?? '',
      status: json['status'] ?? 'offline',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isSosState: json['isSosState'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      isFriend: json['isFriend'] ?? false,
      trappedCounts: json['trappedCounts'],
      childrenNumbers: json['childrenNumbers'],
      elderlyNumbers: json['elderlyNumbers'],
      hasFood: json['hasFood'],
      hasWater: json['hasWater'],
      other: json['other'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'isSosState': isSosState,
      'roles': roles,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'isFriend': isFriend,
      'trappedCounts': trappedCounts,
      'childrenNumbers': childrenNumbers,
      'elderlyNumbers': elderlyNumbers,
      'hasFood': hasFood,
      'hasWater': hasWater,
      'other': other,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? avatarUrl,
    String? status,
    double? latitude,
    double? longitude,
    bool? isSosState,
    List<String>? roles,
    DateTime? dateOfBirth,
    bool? isFriend,
    int? trappedCounts,
    int? childrenNumbers,
    int? elderlyNumbers,
    bool? hasFood,
    bool? hasWater,
    String? other,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSosState: isSosState ?? this.isSosState,
      roles: roles ?? this.roles,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isFriend: isFriend ?? this.isFriend,
      trappedCounts: trappedCounts ?? this.trappedCounts,
      childrenNumbers: childrenNumbers ?? this.childrenNumbers,
      elderlyNumbers: elderlyNumbers ?? this.elderlyNumbers,
      hasFood: hasFood ?? this.hasFood,
      hasWater: hasWater ?? this.hasWater,
      other: other ?? this.other,
    );
  }
  
  /// Get color based on status
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'online':
        return const Color(0xFF00E676); // Green
      case 'offline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
