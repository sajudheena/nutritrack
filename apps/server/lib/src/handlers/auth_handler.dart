import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:common/common.dart';
import '../database/db_service.dart';
import '../auth/jwt_service.dart';

const _jsonHeaders = {'Content-Type': 'application/json'};

Router authRouter({
  required DbService dbService,
  required JwtService jwtService,
}) {
  final router = Router();

  // POST /auth/register
  router.post('/auth/register', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;

    final req = RegisterRequest.fromJson(body);

    // Validate required fields
    if (req.email.trim().isEmpty || req.password.trim().isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'Email and password are required'}),
        headers: _jsonHeaders,
      );
    }

    // Check duplicate email
    if (dbService.findUserByEmail(req.email) != null) {
      return Response(
        409,
        body: jsonEncode({'error': 'Email already registered'}),
        headers: _jsonHeaders,
      );
    }

    final id = _generateId();
    final profile = UserProfile(
      id: id,
      name: req.name,
      email: req.email,
      passwordHash: hashPassword(req.password),
      age: req.age,
      weightKg: req.weightKg,
      heightCm: req.heightCm,
      gender: Gender.values.byName(req.gender),
      activityLevel: ActivityLevel.values.byName(req.activityLevel),
    );

    dbService.createUser(profile);

    final token = jwtService.generateToken(id);
    final response = LoginResponse(token: token, profile: profile);

    return Response.ok(
      jsonEncode(response.toJson()),
      headers: _jsonHeaders,
    );
  });

  // POST /auth/login
  router.post('/auth/login', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final req = LoginRequest.fromJson(body);

    final user = dbService.findUserByEmail(req.email);
    if (user == null || !verifyPassword(req.password, user.passwordHash)) {
      return Response(
        401,
        body: jsonEncode({'error': 'Invalid email or password'}),
        headers: _jsonHeaders,
      );
    }

    final token = jwtService.generateToken(user.id);
    final response = LoginResponse(token: token, profile: user);

    return Response.ok(
      jsonEncode(response.toJson()),
      headers: _jsonHeaders,
    );
  });

  return router;
}

String _generateId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final rand = now.toRadixString(36);
  return '$rand${_randomSuffix()}';
}

String _randomSuffix() {
  // Simple pseudo-random suffix using time components
  final ns = DateTime.now().microsecond;
  return ns.toRadixString(36).padLeft(4, '0');
}
