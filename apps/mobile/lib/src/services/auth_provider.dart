import 'package:flutter/foundation.dart';
import 'package:common/common.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required ApiService api}) : _api = api;

  UserProfile? get profile => _profile;
  bool get isLoggedIn => _profile != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load stored token and fetch profile if available.
  Future<void> loadFromStorage() async {
    await _api.loadToken();
    if (_api.isAuthenticated) {
      try {
        _profile = await _api.getProfile();
        notifyListeners();
      } catch (_) {
        // Token may be expired — clear it
        await _api.clearToken();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _api.login(email, password);
      _profile = result.profile;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weightKg,
    required double heightCm,
    required String gender,
    required String activityLevel,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await _api.register(
        name: name,
        email: email,
        password: password,
        age: age,
        weightKg: weightKg,
        heightCm: heightCm,
        gender: gender,
        activityLevel: activityLevel,
      );
      _profile = result.profile;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _setLoading(true);
    _error = null;
    try {
      _profile = await _api.updateProfile(updates);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    _profile = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
