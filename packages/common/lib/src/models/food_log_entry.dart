import 'dart:convert';
import 'nutrient_values.dart';

class FoodLogEntry {
  final String id;
  final String userId;
  final String foodItemId;
  final String foodName;

  /// Date only (time component is ignored).
  final DateTime date;
  final double grams;
  final NutrientValues nutrients;

  const FoodLogEntry({
    required this.id,
    required this.userId,
    required this.foodItemId,
    required this.foodName,
    required this.date,
    required this.grams,
    required this.nutrients,
  });

  /// Returns a date-only string in YYYY-MM-DD format.
  String get dateString =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'foodItemId': foodItemId,
        'foodName': foodName,
        'date': dateString,
        'grams': grams,
        'nutrients': nutrients.toJson(),
      };

  factory FoodLogEntry.fromJson(Map<String, dynamic> json) => FoodLogEntry(
        id: json['id'] as String,
        userId: json['userId'] as String,
        foodItemId: json['foodItemId'] as String,
        foodName: json['foodName'] as String,
        date: DateTime.parse(json['date'] as String),
        grams: (json['grams'] as num).toDouble(),
        nutrients:
            NutrientValues.fromJson(json['nutrients'] as Map<String, dynamic>),
      );

  String toJsonString() => jsonEncode(toJson());

  factory FoodLogEntry.fromJsonString(String source) =>
      FoodLogEntry.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'FoodLogEntry(id: $id, food: $foodName, grams: $grams, date: $dateString)';
}
