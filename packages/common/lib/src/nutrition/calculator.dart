import '../models/user_profile.dart';
import 'nutrient_targets.dart';

class NutritionCalculator {
  NutritionCalculator._();

  /// Calculates Basal Metabolic Rate using the Mifflin-St Jeor formula.
  ///
  /// Males:   BMR = 10×weight(kg) + 6.25×height(cm) − 5×age + 5
  /// Females: BMR = 10×weight(kg) + 6.25×height(cm) − 5×age − 161
  static double calculateBMR(UserProfile profile) {
    final base = 10 * profile.weightKg +
        6.25 * profile.heightCm -
        5 * profile.age.toDouble();

    return profile.gender == Gender.male ? base + 5 : base - 161;
  }

  /// Calculates Total Daily Energy Expenditure (TDEE) = BMR × activity multiplier.
  static double calculateTDEE(UserProfile profile) {
    final bmr = calculateBMR(profile);
    const multipliers = {
      ActivityLevel.sedentary: 1.2,
      ActivityLevel.lightlyActive: 1.375,
      ActivityLevel.moderatelyActive: 1.55,
      ActivityLevel.veryActive: 1.725,
      ActivityLevel.extraActive: 1.9,
    };
    return bmr * (multipliers[profile.activityLevel] ?? 1.2);
  }

  /// Calculates daily macronutrient targets based on TDEE.
  ///
  /// Distribution:
  ///   Protein  : 25% of calories → calories / 4 kcal/g
  ///   Fat      : 30% of calories → calories / 9 kcal/g
  ///   Carbs    : 45% of calories → calories / 4 kcal/g
  ///   Fiber    : 14g per 1000 kcal (USDA guideline)
  static NutrientTargets calculateTargets(UserProfile profile) {
    final tdee = calculateTDEE(profile);

    final proteinCalories = tdee * 0.25;
    final fatCalories = tdee * 0.30;
    final carbCalories = tdee * 0.45;

    return NutrientTargets(
      calories: tdee,
      protein: proteinCalories / 4.0,
      fat: fatCalories / 9.0,
      carbs: carbCalories / 4.0,
      fiber: (tdee / 1000) * 14,
    );
  }
}
