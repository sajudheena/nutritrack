/// NutriTrack shared library.
///
/// Exports all public models, DTOs, nutrition logic, auth utilities, and the
/// static food database.
library common;

// Models
export 'src/models/user_profile.dart';
export 'src/models/food_item.dart';
export 'src/models/nutrient_values.dart';
export 'src/models/food_log_entry.dart';
export 'src/models/daily_log.dart';

// Nutrition
export 'src/nutrition/nutrient_targets.dart';
export 'src/nutrition/calculator.dart';

// Data
export 'src/data/food_database.dart';

// Auth
export 'src/auth/auth_utils.dart';

// API DTOs
export 'src/api/api_models.dart';
