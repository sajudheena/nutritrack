import 'dart:convert';
import '../models/user_profile.dart';
import '../models/daily_log.dart';

// ── Auth ─────────────────────────────────────────────────────────────────────

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json['email'] as String,
        password: json['password'] as String,
      );

  String toJsonString() => jsonEncode(toJson());

  factory LoginRequest.fromJsonString(String source) =>
      LoginRequest.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

class LoginResponse {
  final String token;
  final UserProfile profile;

  const LoginResponse({required this.token, required this.profile});

  Map<String, dynamic> toJson() => {
        'token': token,
        'profile': profile.toJson(),
      };

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] as String,
        profile:
            UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      );

  String toJsonString() => jsonEncode(toJson());

  factory LoginResponse.fromJsonString(String source) =>
      LoginResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final int age;
  final double weightKg;
  final double heightCm;
  final String gender; // 'male' | 'female'
  final String activityLevel;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.activityLevel,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'gender': gender,
        'activityLevel': activityLevel,
      };

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        age: json['age'] as int,
        weightKg: (json['weightKg'] as num).toDouble(),
        heightCm: (json['heightCm'] as num).toDouble(),
        gender: json['gender'] as String,
        activityLevel: json['activityLevel'] as String,
      );

  String toJsonString() => jsonEncode(toJson());

  factory RegisterRequest.fromJsonString(String source) =>
      RegisterRequest.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

// ── Food Log ──────────────────────────────────────────────────────────────────

class AddFoodLogRequest {
  final String foodItemId;
  final double grams;

  /// Date string YYYY-MM-DD. Defaults to today if omitted by the server.
  final String? date;

  const AddFoodLogRequest({
    required this.foodItemId,
    required this.grams,
    this.date,
  });

  Map<String, dynamic> toJson() => {
        'foodItemId': foodItemId,
        'grams': grams,
        if (date != null) 'date': date,
      };

  factory AddFoodLogRequest.fromJson(Map<String, dynamic> json) =>
      AddFoodLogRequest(
        foodItemId: json['foodItemId'] as String,
        grams: (json['grams'] as num).toDouble(),
        date: json['date'] as String?,
      );

  String toJsonString() => jsonEncode(toJson());

  factory AddFoodLogRequest.fromJsonString(String source) =>
      AddFoodLogRequest.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

class DailyLogResponse {
  final DailyLog dailyLog;

  const DailyLogResponse({required this.dailyLog});

  Map<String, dynamic> toJson() => dailyLog.toJson();

  factory DailyLogResponse.fromJson(Map<String, dynamic> json) =>
      DailyLogResponse(dailyLog: DailyLog.fromJson(json));

  String toJsonString() => jsonEncode(toJson());

  factory DailyLogResponse.fromJsonString(String source) =>
      DailyLogResponse.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
