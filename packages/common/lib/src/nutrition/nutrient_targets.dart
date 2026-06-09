import 'dart:convert';

class NutrientTargets {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const NutrientTargets({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
      };

  factory NutrientTargets.fromJson(Map<String, dynamic> json) =>
      NutrientTargets(
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        fiber: (json['fiber'] as num).toDouble(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory NutrientTargets.fromJsonString(String source) =>
      NutrientTargets.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'NutrientTargets(cal: $calories, prot: $protein, carbs: $carbs, fat: $fat, fiber: $fiber)';
}
