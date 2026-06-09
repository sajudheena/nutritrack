import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:common/common.dart';

class ApiService {
  static const _tokenKey = 'auth_token';

  String? _token;

  /// Determines base URL based on platform.
  /// Update [_productionServerUrl] to your deployed server URL.
  static const _productionServerUrl = 'https://YOUR-APP.up.railway.app';
  static const _localServerUrl = 'http://localhost:8080';
  static const _androidEmulatorUrl = 'http://10.0.2.2:8080';

  static String get baseUrl {
    // Use kReleaseMode to switch between local dev and production
    if (kIsWeb) return _productionServerUrl;
    if (Platform.isAndroid) return _androidEmulatorUrl;
    return _localServerUrl;
  }

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<Map<String, dynamic>> _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Future.value(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final message = body['error'] as String? ?? 'Unknown error';
    throw ApiException(message, response.statusCode);
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      _uri('/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = await _decode(response);
    final result = LoginResponse.fromJson(data);
    await _saveToken(result.token);
    return result;
  }

  Future<LoginResponse> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weightKg,
    required double heightCm,
    required String gender,
    required String activityLevel,
  }) async {
    final response = await http.post(
      _uri('/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'gender': gender,
        'activityLevel': activityLevel,
      }),
    );
    final data = await _decode(response);
    final result = LoginResponse.fromJson(data);
    await _saveToken(result.token);
    return result;
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<UserProfile> getProfile() async {
    final response = await http.get(_uri('/profile'), headers: _headers);
    final data = await _decode(response);
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> updates) async {
    final response = await http.put(
      _uri('/profile'),
      headers: _headers,
      body: jsonEncode(updates),
    );
    final data = await _decode(response);
    return UserProfile.fromJson(data);
  }

  // ── Foods ──────────────────────────────────────────────────────────────────

  Future<List<FoodItem>> getFoods() async {
    final response = await http.get(_uri('/foods'), headers: _headers);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FoodItem>> searchFoods(String query) async {
    final response = await http.get(
      _uri('/foods', {'q': query}),
      headers: _headers,
    );
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Log ────────────────────────────────────────────────────────────────────

  Future<FoodLogEntry> addLogEntry({
    required String foodItemId,
    required double grams,
    String? date,
  }) async {
    final body = AddFoodLogRequest(
      foodItemId: foodItemId,
      grams: grams,
      date: date,
    ).toJson();

    final response = await http.post(
      _uri('/logs'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = await _decode(response);
    return FoodLogEntry.fromJson(data);
  }

  Future<DailyLog> getDailyLog(DateTime date) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final response = await http.get(
      _uri('/logs', {'date': dateStr}),
      headers: _headers,
    );
    final data = await _decode(response);
    return DailyLog.fromJson(data);
  }

  Future<void> deleteLogEntry(String entryId) async {
    final response = await http.delete(
      _uri('/logs/$entryId'),
      headers: _headers,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        body['error'] as String? ?? 'Failed to delete entry',
        response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
