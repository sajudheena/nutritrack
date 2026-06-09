import 'package:flutter/foundation.dart';
import 'package:common/common.dart';
import 'api_service.dart';

class NutritionProvider extends ChangeNotifier {
  final ApiService _api;

  DailyLog? _dailyLog;
  NutrientTargets? _targets;
  bool _isLoading = false;
  String? _error;

  NutritionProvider({required ApiService api}) : _api = api;

  DailyLog? get dailyLog => _dailyLog;
  NutrientTargets? get targets => _targets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Recalculate targets from the given profile.
  void setTargets(UserProfile profile) {
    _targets = NutritionCalculator.calculateTargets(profile);
    notifyListeners();
  }

  Future<void> loadDailyLog(DateTime date) async {
    _setLoading(true);
    _error = null;
    try {
      _dailyLog = await _api.getDailyLog(date);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addEntry({
    required String foodItemId,
    required double grams,
    String? date,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.addLogEntry(
        foodItemId: foodItemId,
        grams: grams,
        date: date,
      );
      // Reload today's log to get updated totals
      final now = DateTime.now();
      _dailyLog = await _api.getDailyLog(now);
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

  Future<bool> removeEntry(String entryId) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.deleteLogEntry(entryId);
      // Reload today's log
      if (_dailyLog != null) {
        _dailyLog = await _api.getDailyLog(_dailyLog!.date);
      }
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
