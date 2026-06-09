import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database/db_service.dart';
import 'auth/jwt_service.dart';
import 'handlers/auth_handler.dart';
import 'handlers/profile_handler.dart';
import 'handlers/food_handler.dart';
import 'handlers/log_handler.dart';

/// Assembles and returns the main application router.
Router buildRouter({
  required DbService dbService,
  required JwtService jwtService,
}) {
  final router = Router();

  // Health check for Railway
  router.get('/health', (Request req) => Response.ok(
    jsonEncode({'status': 'ok'}),
    headers: {'Content-Type': 'application/json'},
  ));

  // Mount sub-routers
  router.mount('/', authRouter(dbService: dbService, jwtService: jwtService).call);
  router.mount('/', profileRouter(dbService: dbService, jwtService: jwtService).call);
  router.mount('/', foodRouter().call);
  router.mount('/', logRouter(dbService: dbService, jwtService: jwtService).call);

  return router;
}
