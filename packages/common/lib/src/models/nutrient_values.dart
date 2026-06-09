import 'dart:convert';

class NutrientValues {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const NutrientValues({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  const NutrientValues.zero()
      : calories = 0,
        protein = 0,
        carbs = 0,
        fat = 0,
        fiber = 0,
        sugar = 0;

  NutrientValues operator +(NutrientValues other) => NutrientValues(
        calories: calories + other.calories,
        protein: protein + other.protein,
        carbs: carbs + other.carbs,
        fat: fat + other.fat,
        fiber: fiber + other.fiber,
        sugar: sugar + other.sugar,
      );

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
      };

  factory NutrientValues.fromJson(Map<String, dynamic> json) => NutrientValues(
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        fiber: (json['fiber'] as num).toDouble(),
        sugar: (json['sugar'] as num).toDouble(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory NutrientValues.fromJsonString(String source) =>
      NutrientValues.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'NutrientValues(cal: $calories, prot: $protein, carbs: $carbs, fat: $fat)';
}
