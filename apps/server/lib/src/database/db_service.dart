import 'package:sqlite3/sqlite3.dart';
import 'package:common/common.dart';

class DbService {
  final String dbPath;
  late final Database _db;

  DbService({this.dbPath = 'nutritrack.db'});

  void initialize() {
    _db = sqlite3.open(dbPath);
    _createTables();
  }

  void _createTables() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight_kg REAL NOT NULL,
        height_cm REAL NOT NULL,
        gender TEXT NOT NULL,
        activity_level TEXT NOT NULL
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS food_log_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        food_item_id TEXT NOT NULL,
        food_name TEXT NOT NULL,
        date TEXT NOT NULL,
        grams REAL NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        carbs REAL NOT NULL,
        fat REAL NOT NULL,
        fiber REAL NOT NULL,
        sugar REAL NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');

    _db.execute('CREATE INDEX IF NOT EXISTS idx_log_user_date ON food_log_entries(user_id, date)');
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  void createUser(UserProfile user) {
    _db.execute(
      '''
      INSERT INTO users (id, name, email, password_hash, age, weight_kg, height_cm, gender, activity_level)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        user.id,
        user.name,
        user.email,
        user.passwordHash,
        user.age,
        user.weightKg,
        user.heightCm,
        user.gender.name,
        user.activityLevel.name,
      ],
    );
  }

  UserProfile? findUserByEmail(String email) {
    final result = _db.select(
      'SELECT * FROM users WHERE email = ? LIMIT 1',
      [email],
    );
    if (result.isEmpty) return null;
    return _rowToUserProfile(result.first);
  }

  UserProfile? findUserById(String id) {
    final result = _db.select(
      'SELECT * FROM users WHERE id = ? LIMIT 1',
      [id],
    );
    if (result.isEmpty) return null;
    return _rowToUserProfile(result.first);
  }

  void updateUser(UserProfile user) {
    _db.execute(
      '''
      UPDATE users
      SET name = ?, age = ?, weight_kg = ?, height_cm = ?, gender = ?, activity_level = ?
      WHERE id = ?
      ''',
      [
        user.name,
        user.age,
        user.weightKg,
        user.heightCm,
        user.gender.name,
        user.activityLevel.name,
        user.id,
      ],
    );
  }

  UserProfile _rowToUserProfile(Row row) => UserProfile(
        id: row['id'] as String,
        name: row['name'] as String,
        email: row['email'] as String,
        passwordHash: row['password_hash'] as String,
        age: row['age'] as int,
        weightKg: (row['weight_kg'] as num).toDouble(),
        heightCm: (row['height_cm'] as num).toDouble(),
        gender: Gender.values.byName(row['gender'] as String),
        activityLevel:
            ActivityLevel.values.byName(row['activity_level'] as String),
      );

  // ── Food Log Entries ───────────────────────────────────────────────────────

  void addLogEntry(FoodLogEntry entry) {
    _db.execute(
      '''
      INSERT INTO food_log_entries
        (id, user_id, food_item_id, food_name, date, grams, calories, protein, carbs, fat, fiber, sugar)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        entry.id,
        entry.userId,
        entry.foodItemId,
        entry.foodName,
        entry.dateString,
        entry.grams,
        entry.nutrients.calories,
        entry.nutrients.protein,
        entry.nutrients.carbs,
        entry.nutrients.fat,
        entry.nutrients.fiber,
        entry.nutrients.sugar,
      ],
    );
  }

  List<FoodLogEntry> getLogEntriesForUserAndDate(
      String userId, String date) {
    final result = _db.select(
      'SELECT * FROM food_log_entries WHERE user_id = ? AND date = ? ORDER BY rowid ASC',
      [userId, date],
    );
    return result.map(_rowToFoodLogEntry).toList();
  }

  /// Returns log entries for the given user from the last 30 days.
  List<FoodLogEntry> getLogEntriesForUser(String userId) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final cutoffStr =
        '${cutoff.year.toString().padLeft(4, '0')}-'
        '${cutoff.month.toString().padLeft(2, '0')}-'
        '${cutoff.day.toString().padLeft(2, '0')}';

    final result = _db.select(
      '''
      SELECT * FROM food_log_entries
      WHERE user_id = ? AND date >= ?
      ORDER BY date DESC, rowid ASC
      ''',
      [userId, cutoffStr],
    );
    return result.map(_rowToFoodLogEntry).toList();
  }

  bool deleteLogEntry(String entryId, String userId) {
    _db.execute(
      'DELETE FROM food_log_entries WHERE id = ? AND user_id = ?',
      [entryId, userId],
    );
    return _db.getUpdatedRows() > 0;
  }

  FoodLogEntry _rowToFoodLogEntry(Row row) => FoodLogEntry(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        foodItemId: row['food_item_id'] as String,
        foodName: row['food_name'] as String,
        date: DateTime.parse(row['date'] as String),
        grams: (row['grams'] as num).toDouble(),
        nutrients: NutrientValues(
          calories: (row['calories'] as num).toDouble(),
          protein: (row['protein'] as num).toDouble(),
          carbs: (row['carbs'] as num).toDouble(),
          fat: (row['fat'] as num).toDouble(),
          fiber: (row['fiber'] as num).toDouble(),
          sugar: (row['sugar'] as num).toDouble(),
        ),
      );

  void close() => _db.dispose();
}
