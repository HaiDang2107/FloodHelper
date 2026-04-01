import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/distress_signal_input.dart';

class SosLocalStorage {
  static String _keyForUser(String userId) => 'sos_state_$userId';

  static Future<void> saveBroadcastingState(
    String userId,
    DistressSignalInput data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForUser(userId),
      jsonEncode({
        'isBroadcasting': true,
        'trappedCounts': data.trappedCounts,
        'childrenNumbers': data.childrenNumbers,
        'elderlyNumbers': data.elderlyNumbers,
        'hasFood': data.hasFood,
        'hasWater': data.hasWater,
        'other': data.other,
      }),
    );
  }

  static Future<DistressSignalInput?> getBroadcastingState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    if (json['isBroadcasting'] != true) {
      return null;
    }

    return DistressSignalInput(
      trappedCounts: _asInt(json['trappedCounts']),
      childrenNumbers: _asInt(json['childrenNumbers']),
      elderlyNumbers: _asInt(json['elderlyNumbers']),
      hasFood: json['hasFood'] == true,
      hasWater: json['hasWater'] == true,
      other: (json['other'] ?? '').toString().isEmpty
          ? null
          : json['other'].toString(),
    );
  }

  static Future<void> clearBroadcastingState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForUser(userId));
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
