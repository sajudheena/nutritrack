# NutriTrack

A nutrition tracking application built as a Dart/Flutter monorepo.

## Structure

```
nutritrack/
├── packages/
│   └── common/          # Shared pure Dart package (models, logic, DTOs)
├── apps/
│   ├── mobile/          # Flutter app (Android + Windows)
│   └── server/          # Dart server using Shelf
```

## Getting Started

### Prerequisites

- Dart SDK >= 3.0.0
- Flutter SDK >= 3.10.0
- SQLite (for the server)

---

### 1. Common Package

The shared package has no runtime; it's a library used by both the server and mobile app.

```bash
cd packages/common
dart pub get
dart test
```

---

### 2. Server

```bash
cd apps/server
dart pub get
dart run bin/server.dart
```

The server starts on **http://localhost:8080**.

#### API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /auth/register | No | Register a new user |
| POST | /auth/login | No | Login and receive JWT |
| GET | /profile | Yes | Get current user profile |
| PUT | /profile | Yes | Update user profile |
| GET | /foods | No | List all foods (optional `?q=query`) |
| GET | /foods/:id | No | Get a single food item |
| POST | /logs | Yes | Add a food log entry |
| GET | /logs?date=YYYY-MM-DD | Yes | Get daily log |
| DELETE | /logs/:id | Yes | Delete a log entry |

---

### 3. Mobile App

```bash
cd apps/mobile
flutter pub get

# Run on Android emulator
flutter run

# Run on Windows
flutter run -d windows
```

The mobile app connects to `http://10.0.2.2:8080` on Android emulator and `http://localhost:8080` on Windows.

---

## Development Notes

- Start the server before running the mobile app.
- The food database is static and loaded from `packages/common` — no seeding required.
- JWT tokens are stored in `SharedPreferences` on the mobile side.
- Passwords are hashed with SHA-256 before storage.
