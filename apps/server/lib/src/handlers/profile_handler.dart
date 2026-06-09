import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:common/common.dart';
import '../database/db_service.dart';
import '../auth/jwt_service.dart';
import '../middleware/auth_middleware.dart';

const _jsonHeaders = {'Content-Type': 'application/json'};

Router profileRouter({
  required DbService dbService,
  required JwtService jwtService,
}) {
  final router = Router();

  // GET /profile — returns the current user's profile
  router.get('/profile', (Request request) {
    final pipeline = Pipeline().addMiddleware(authMiddleware(jwtService));
    return pipeline.addHandler((Request req) {
      final userId = req.context['userId'] as String;
      final user = dbService.findUserById(userId);
      if (user == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: _jsonHeaders,
        );
      }
      return Response.ok(jsonEncode(user.toJson()), headers: _jsonHeaders);
    })(request);
  });

  // PUT /profile — update mutable profile fields
  router.put('/profile', (Request request) async {
    final pipeline = Pipeline().addMiddleware(authMiddleware(jwtService));
    return pipeline.addHandler((Request req) async {
      final userId = req.context['userId'] as String;
      final existing = dbService.findUserById(userId);
      if (existing == null) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: _jsonHeaders,
        );
      }

      final body =
          jsonDecode(await req.readAsString()) as Map<String, dynamic>;

      final updated = existing.copyWith(
        name: body['name'] as String? ?? existing.name,
        age: body['age'] != null ? (body['age'] as num).toInt() : existing.age,
        weightKg: body['weightKg'] != null
            ? (body['weightKg'] as num).toDouble()
            : existing.weightKg,
        heightCm: body['heightCm'] != null
            ? (body['heightCm'] as num).toDouble()
            : existing.heightCm,
        gender: body['gender'] != null
            ? Gender.values.byName(body['gender'] as String)
            : existing.gender,
        activityLevel: body['activityLevel'] != null
            ? ActivityLevel.values.byName(body['activityLevel'] as String)
            : existing.activityLevel,
      );

      dbService.updateUser(updated);

      return Response.ok(jsonEncode(updated.toJson()), headers: _jsonHeaders);
    })(request);
  });

  return router;
}
