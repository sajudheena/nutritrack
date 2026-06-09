import 'dart:convert';
import 'food_log_entry.dart';
import 'nutrient_values.dart';

class DailyLog {
  final String userId;
  final DateTime date;
  final List<FoodLogEntry> entries;

  const DailyLog({
    required this.userId,
    required this.date,
    required this.entries,
  });

  /// Computed sum of all entry nutrients.
  NutrientValues get totals => entries.fold(
        const NutrientValues.zero(),
        (acc, entry) => acc + entry.nutrients,
      );

  String get dateString =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'date': dateString,
        'entries': entries.map((e) => e.toJson()).toList(),
        'totals': totals.toJson(),
      };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
        userId: json['userId'] as String,
        date: DateTime.parse(json['date'] as String),
        entries: (json['entries'] as List<dynamic>)
            .map((e) => FoodLogEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory DailyLog.fromJsonString(String source) =>
      DailyLog.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DailyLog(userId: $userId, date: $dateString, entries: ${entries.length})';
}
