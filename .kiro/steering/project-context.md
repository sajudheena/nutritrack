# NutriTrack Project Context

## Project Overview
A nutrition tracking app built as a Dart/Flutter monorepo. Customers can view daily nutrient targets (calories, protein, carbs, fat, fiber) and track their daily food intake. Supports multiple customer logins.

## Tech Stack
- **Language**: Dart / Flutter
- **Frontend**: Flutter app targeting Android and Windows desktop
- **Backend**: Dart server using Shelf framework
- **Database**: SQLite (via `sqlite3` package) stored at `apps/server/bin/nutritrack.db`
- **Auth**: JWT tokens (dart_jsonwebtoken), passwords hashed with SHA-256
- **Shared code**: Pure Dart `common` package shared between server and mobile

## Monorepo Structure
```
nutritrack/
├── packages/
│   └── common/          # Shared models, DTOs, nutrition logic, food database
├── apps/
│   ├── mobile/          # Flutter app (Android + Windows)
│   └── server/          # Dart Shelf HTTP server
```

## Running the Project

### Start the server (Terminal 1)
```cmd
cd C:\Users\roshi\KiroProjects\nutritrack\apps\server
dart run bin/server.dart
```
Server runs on port 8080. DB file is always stored at `apps/server/bin/nutritrack.db`.

### Start the Flutter app (Terminal 2)
```cmd
cd C:\Users\roshi\KiroProjects\nutritrack\apps\mobile
flutter run -d windows        # Windows desktop
flutter run -d emulator-5554  # Android emulator
```

## API Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /auth/register | No | Register new user |
| POST | /auth/login | No | Login, receive JWT |
| GET | /profile | Yes | Get user profile |
| PUT | /profile | Yes | Update profile |
| GET | /foods | No | List foods (?q=query) |
| GET | /foods/:id | No | Get single food |
| POST | /logs | Yes | Add food log entry |
| GET | /logs?date=YYYY-MM-DD | Yes | Get daily log |
| DELETE | /logs/:id | Yes | Delete log entry |

## Platform URL Configuration
- **Windows app** → connects to `http://localhost:8080`
- **Android emulator** → connects to `http://10.0.2.2:8080` (emulator alias for localhost)
- Both point to the same server and same SQLite database

## Key Setup Notes
- Flutter SDK installed at `C:\Users\roshi\Kirosoftware\flutter\flutter`
- Requires Git on PATH for Flutter to work
- Android emulator: sdk gphone64 x86 64 (emulator-5554)
- Visual Studio Enterprise 2026 with C++ workload installed (Windows desktop builds)
- Windows desktop support added with: `flutter create --platforms=windows .`
- Android support added with: `flutter create --platforms=android .`

## Common Package Contents
- `UserProfile` — user model with BMR/TDEE fields
- `FoodItem` — food with per-100g nutritional values, `scaled(grams)` method
- `NutrientValues` — calories, protein, carbs, fat, fiber, sugar with `operator +`
- `FoodLogEntry` — a logged food item for a user on a date
- `DailyLog` — all entries for a day with computed totals
- `NutritionCalculator` — Mifflin-St Jeor BMR/TDEE calculation
- `FoodDatabase` — static list of 41 foods across 8 categories
- `AuthUtils` — SHA-256 password hashing

## Flutter App Screens
- Login / Register
- Home dashboard (nutrient progress bars, today's log)
- Food search (search static DB, enter grams, add to log)
- Profile (view/edit profile, see BMR/TDEE targets, logout)
- History (past days with calorie totals)

## Viewing the Database
Use DB Browser for SQLite (sqlitebrowser.org) or the VS Code "SQLite Viewer" extension.
Open: `C:\Users\roshi\KiroProjects\nutritrack\apps\server\bin\nutritrack.db`
