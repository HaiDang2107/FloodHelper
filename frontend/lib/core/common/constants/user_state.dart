import 'package:flutter/material.dart';

enum UserStatus {
  online,
  offline,
  sos,
  unknown,
}

extension UserStatusColors on UserStatus {
  Color get color {
    switch (this) {
      case UserStatus.online:
        return const Color(0xFF00E676); // Green
      case UserStatus.offline:
        return const Color.fromARGB(255, 0, 0, 0);
      case UserStatus.sos:
        return const Color(0xFFFF1744); // Red
      case UserStatus.unknown:
        return Colors.grey;
    }
  }
}
