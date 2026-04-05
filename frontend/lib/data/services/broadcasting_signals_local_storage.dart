import 'package:shared_preferences/shared_preferences.dart';

enum BroadcastingSignalsSortCriterion {
  trappedCounts,
  childrenNumbers,
  elderlyNumbers,
  hasFood,
  hasWater,
}

class BroadcastingSignalsLocalStorage {
  static const List<BroadcastingSignalsSortCriterion> defaultSortCriteria = [
    BroadcastingSignalsSortCriterion.trappedCounts,
    BroadcastingSignalsSortCriterion.childrenNumbers,
    BroadcastingSignalsSortCriterion.elderlyNumbers,
    BroadcastingSignalsSortCriterion.hasFood,
    BroadcastingSignalsSortCriterion.hasWater,
  ];

  static String _sortCriteriaKey(String rescuerId) =>
      'rescuer_broadcasting_sort_criteria_$rescuerId';

  static Future<void> saveSortCriteriaOrder({
    required String rescuerId,
    required List<BroadcastingSignalsSortCriterion> criteria,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = criteria.map((value) => value.name).join(',');
    await prefs.setString(_sortCriteriaKey(rescuerId), encoded);
  }

  static Future<List<BroadcastingSignalsSortCriterion>> getSortCriteriaOrder(
    String rescuerId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sortCriteriaKey(rescuerId));
    if (raw == null || raw.trim().isEmpty) {
      return List<BroadcastingSignalsSortCriterion>.from(defaultSortCriteria);
    }

    final parsed = raw
        .split(',') // Tách chuỗi theo dấu ","
        .map((item) => item.trim()) // Bỏ khoảng trắng đầu cuối
        .where((item) => item.isNotEmpty) // Loại bỏ phần tử rỗng
        .map(
          (item) => BroadcastingSignalsSortCriterion.values.firstWhere(
            (value) =>
                value.name ==
                item, // map string với phần tử trong BroadcastingSignalsSortCriterion
            orElse: () => BroadcastingSignalsSortCriterion
                .trappedCounts, // Nếu không tìm thấy phần tử nào match với string thì mặc định là trappedCounts
          ),
        )
        .toList(growable: false);

    final normalized = <BroadcastingSignalsSortCriterion>[];
    for (final criterion in parsed) {
      // Đảm bảo tiêu chí chỉ xuất hiện 1 lần
      if (!normalized.contains(criterion)) {
        // tiêu chí chưa tồn tại tring normalized ==> thêm
        normalized.add(criterion);
      }
    }

    return normalized;
  }

  static Future<void> clearSortCriteriaOrder(String rescuerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sortCriteriaKey(rescuerId));
  }
}
