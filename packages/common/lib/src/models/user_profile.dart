import 'dart:convert';

enum Gender { male, female }

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive,
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final int age;
  final double weightKg;
  final double heightCm;
  final Gender gender;
  final ActivityLevel activityLevel;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.activityLevel,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    int? age,
    double? weightKg,
    double? heightCm,
    Gender? gender,
    ActivityLevel? activityLevel,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'age': age,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'gender': gender.name,
        'activityLevel': activityLevel.name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        age: json['age'] as int,
        weightKg: (json['weightKg'] as num).toDouble(),
        heightCm: (json['heightCm'] as num).toDouble(),
        gender: Gender.values.byName(json['gender'] as String),
        activityLevel:
            ActivityLevel.values.byName(json['activityLevel'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String source) =>
      UserProfile.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserProfile(id: $id, name: $name, email: $email, age: $age)';
}
