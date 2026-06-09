import 'dart:convert';
import 'nutrient_values.dart';

class FoodItem {
  final String id;
  final String name;
  final String category;

  /// Nutritional values per 100g
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  /// Returns NutrientValues scaled to the given gram amount.
  NutrientValues scaled(double grams) {
    final factor = grams / 100.0;
    return NutrientValues(
      calories: calories * factor,
      protein: protein * factor,
      carbs: carbs * factor,
      fat: fat * factor,
      fiber: fiber * factor,
      sugar: sugar * factor,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'per100g': {
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
          'fiber': fiber,
          'sugar': sugar,
        },
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final per = json['per100g'] as Map<String, dynamic>;
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      calories: (per['calories'] as num).toDouble(),
      protein: (per['protein'] as num).toDouble(),
      carbs: (per['carbs'] as num).toDouble(),
      fat: (per['fat'] as num).toDouble(),
      fiber: (per['fiber'] as num).toDouble(),
      sugar: (per['sugar'] as num).toDouble(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory FoodItem.fromJsonString(String source) =>
      FoodItem.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'FoodItem(id: $id, name: $name, category: $category)';
}
