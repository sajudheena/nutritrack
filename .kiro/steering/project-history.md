# NutriTrack Project History & Setup Guide

## Project Overview

NutriTrack is a nutrition tracking application built as a Dart/Flutter monorepo targeting Android and Windows desktop, with a shared Dart backend server.

**Tech Stack:**
- Flutter/Dart (frontend — Android + Windows)
- Dart + Shelf (backend server)
- SQLite (database via `sqlite3` package)
- JWT authentication
- SHA-256 password hashing

---

## Project Structure

```
nutritrack/
├── packages/
│   └── common/          # Shared pure Dart package (models, logic, DTOs)
├── apps/
│   ├── mobile/          # Flutter app (Android + Windows client)
│   └── server/          # Dart Shelf application server
```

---

## Feature Requirements

- Multiple customer login/registration with JWT auth
- Customer profile: name, email, age, weight, height, gender, activity level
- Daily nutrient targets calculated using Mifflin-St Jeor BMR/TDEE formula
- Static food database (41 items across 8 categories)
- Food logging — search foods, enter grams, log to daily diary
- Daily dashboard with progress bars (calories, protein, carbs, fat, fiber)
- History view — past days with total calories
- Profile screen showing BMR, TDEE, daily targets

---

## Common Package (`packages/common`)

### Models
- `UserProfile` — user data + activity level enum + gender enum
- `FoodItem` — nutritional values per 100g, `scaled(grams)` method
- `NutrientValues` — calories/protein/carbs/fat/fiber/sugar with `operator +`
- `FoodLogEntry` — logged food entry with date, grams, computed nutrients
- `DailyLog` — list of entries with computed `totals` getter

### Nutrition Logic
- `NutritionCalculator.calculateBMR()` — Mifflin-St Jeor formula
- `NutritionCalculator.calculateTDEE()` — BMR × activity multiplier
- `NutritionCalculator.calculateTargets()` — returns `NutrientTargets`

### Food Database
- 41 static food items across 8 categories: Grains, Dairy, Meat & Fish, Vegetables, Fruits, Legumes, Nuts & Seeds, Snacks
- `FoodDatabase.search(query)` and `FoodDatabase.findById(id)`

### Auth
- `hashPassword(password)` — SHA-256 via `crypto` package
- `verifyPassword(password, hash)`

### API DTOs
- `LoginRequest` / `LoginResponse` (token + UserProfile)
- `RegisterRequest`
- `AddFoodLogRequest`
- `DailyLogResponse`

---

## Server (`apps/server`)

### API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /auth/register | No | Register new user |
| POST | /auth/login | No | Login, receive JWT |
| GET | /profile | Yes | Get current user profile |
| PUT | /profile | Yes | Update profile |
| GET | /foods | No | List foods (optional `?q=query`) |
| GET | /foods/:id | No | Get single food item |
| POST | /logs | Yes | Add food log entry |
| GET | /logs?date=YYYY-MM-DD | Yes | Get daily log |
| DELETE | /logs/:id | Yes | Delete log entry |

### Database
- SQLite via `sqlite3` package
- Tables: `users`, `food_log_entries`
- DB file location: `apps/server/bin/nutritrack.db` (fixed path relative to script)
- JWT tokens: 30-day expiry

---

## Mobile App (`apps/mobile`)

### Screens
- `LoginScreen` — email/password login
- `RegisterScreen` — full registration form with profile fields
- `HomeScreen` — daily dashboard with nutrient progress bars + food log list
- `FoodSearchScreen` — search static food database, enter grams, add to log
- `ProfileScreen` — view/edit profile, shows BMR/TDEE/targets, logout
- `HistoryScreen` — past days list with total calories

### Services
- `ApiService` — HTTP client, auto-detects platform for base URL
  - Android emulator: `http://10.0.2.2:8080`
  - Windows: `http://localhost:8080`
- `AuthProvider` — ChangeNotifier, manages login state + JWT in SharedPreferences
- `NutritionProvider` — ChangeNotifier, manages daily log and targets

### Widgets
- `NutrientProgressBar` — color-coded (green/amber/red at 75%/100% of target)
- `FoodLogTile` — food entry with delete button

---

## Setup & Installation

### Prerequisites
- Flutter SDK >= 3.10.0 (currently on 3.44)
- Dart SDK >= 3.0.0 (included with Flutter)
- Git for Windows
- Android Studio (for Android emulator + Android SDK)
- Visual Studio 2022 or later with "Desktop development with C++" workload

### Flutter Installation
- Install from: https://docs.flutter.dev/install/archive
- Extract to `C:\flutter` (no spaces in path, avoid Program Files)
- Add `C:\flutter\bin` to system PATH
- Verify: `flutter doctor`

### Known Issues & Fixes

**`dart` not recognized:**
- Flutter not installed or not on PATH
- Add Flutter bin folder to system PATH

**Git not recognized:**
- Install Git for Windows from https://git-scm.com/download/win
- Select "Git from the command line and also from 3rd-party software" during install

**`Found no pubspec.yaml`:**
- Must `cd` into the correct project subfolder before running `dart pub get`

**`CardTheme` vs `CardThemeData`:**
- Flutter 3.44 renamed `CardTheme` to `CardThemeData`
- Fix in `apps/mobile/lib/main.dart`

**`Access is denied` / `Unable to determine engine version`:**
- Run Command Prompt as Administrator
- Or fix permissions: `icacls C:\Users\roshi\Kirosoftware\flutter\flutter /grant %USERNAME%:F /T`
- Add Flutter folder to antivirus exclusions

**No Windows desktop project configured:**
```cmd
flutter config --enable-windows-desktop
flutter create --platforms=windows .
```

**No Android project configured:**
```cmd
flutter create --platforms=android .
```

**Visual Studio not recognized by Flutter:**
- Flutter requires Visual Studio with "Desktop development with C++" workload
- VS 2026 support was added — confirmed working with Visual Studio Enterprise 2026 18.6.2

**Android cmdline-tools missing:**
- Open Android Studio → SDK Manager → SDK Tools tab
- Check "Android SDK Command-line Tools (latest)" → Apply
- Run: `flutter doctor --android-licenses`

**Two database files created:**
- Caused by running server from different working directories
- Fixed in `bin/server.dart` to always use path relative to script location
- Single DB at: `apps/server/bin/nutritrack.db`

---

## Running the Project

### Step 1 — Common package
```cmd
cd packages/common
dart pub get
```

### Step 2 — Server (Terminal 1, keep running)
```cmd
cd apps/server
dart pub get
dart run bin/server.dart
```
Server starts on `http://localhost:8080`

### Step 3 — Mobile app (Terminal 2)
```cmd
cd apps/mobile
flutter pub get
flutter run -d windows         # Windows desktop
flutter run -d emulator-5554   # Android emulator
```

---

## Viewing the Database

**DB Browser for SQLite (recommended):**
- Download: https://sqlitebrowser.org/dl/
- Open file: `apps/server/bin/nutritrack.db`
- Browse Data tab shows users and food_log_entries tables

**VS Code:**
- Install "SQLite Viewer" extension
- Open the `.db` file directly

**Command line:**
```cmd
sqlite3 apps/server/bin/nutritrack.db
.tables
SELECT * FROM users;
SELECT * FROM food_log_entries;
.quit
```

---

## Architecture Notes

- Both Android and Windows apps connect to the **same server and same SQLite database**
- Android emulator uses `10.0.2.2:8080` which maps to host `localhost:8080`
- Windows app uses `localhost:8080` directly
- Registering on one platform and logging in on the other works — data is shared
- The food database is static (in the `common` package) — no seeding required
- Passwords are SHA-256 hashed before storage
