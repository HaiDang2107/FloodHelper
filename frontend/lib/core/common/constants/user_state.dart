import 'package:flutter/material.dart';

enum UserStatus {
  online,
  offline,
  unknown,
}

extension UserStatusColors on UserStatus {
  Color get color {
    switch (this) {
      case UserStatus.online:
        return const Color(0xFF00E676); // Green
      case UserStatus.offline:
        return Colors.red;
      case UserStatus.unknown:
        return Colors.grey;
    }
  }
}
