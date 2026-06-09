import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:common/common.dart';
import '../database/db_service.dart';
import '../auth/jwt_service.dart';
import '../middleware/auth_middleware.dart';

const _jsonHeaders = {'Content-Type': 'application/json'};

Router logRouter({
  required DbService dbService,
  required JwtService jwtService,
}) {
  final auth = authMiddleware(jwtService);
  final router = Router();

  // POST /logs — add a food log entry
  router.post('/logs', (Request request) async {
    final pipeline = Pipeline().addMiddleware(auth);
    return pipeline.addHandler((Request req) async {
      final userId = req.context['userId'] as String;
      final body =
          jsonDecode(await req.readAsString()) as Map<String, dynamic>;

      final addReq = AddFoodLogRequest.fromJson(body);

      final foodItem = FoodDatabase.findById(addReq.foodItemId);
      if (foodItem == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Food item not found: ${addReq.foodItemId}'}),
          headers: _jsonHeaders,
        );
      }

      if (addReq.grams <= 0) {
        return Response(
          400,
          body: jsonEncode({'error': 'Grams must be greater than 0'}),
          headers: _jsonHeaders,
        );
      }

      final date = addReq.date != null
          ? DateTime.parse(addReq.date!)
          : DateTime.now();

      final entry = FoodLogEntry(
        id: _generateId(),
        userId: userId,
        foodItemId: foodItem.id,
        foodName: foodItem.name,
        date: date,
        grams: addReq.grams,
        nutrients: foodItem.scaled(addReq.grams),
      );

      dbService.addLogEntry(entry);

      return Response.ok(
        jsonEncode(entry.toJson()),
        headers: _jsonHeaders,
      );
    })(request);
  });

  // GET /logs?date=YYYY-MM-DD — get daily log
  router.get('/logs', (Request request) async {
    final pipeline = Pipeline().addMiddleware(auth);
    return pipeline.addHandler((Request req) async {
      final userId = req.context['userId'] as String;
      final dateParam = req.url.queryParameters['date'];

      String dateStr;
      if (dateParam != null && dateParam.isNotEmpty) {
        dateStr = dateParam;
      } else {
        final now = DateTime.now();
        dateStr = '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}';
      }

      final entries =
          dbService.getLogEntriesForUserAndDate(userId, dateStr);

      final dailyLog = DailyLog(
        userId: userId,
        date: DateTime.parse(dateStr),
        entries: entries,
      );

      return Response.ok(
        jsonEncode(dailyLog.toJson()),
        headers: _jsonHeaders,
      );
    })(request);
  });

  // DELETE /logs/:id — delete a log entry
  router.delete('/logs/<id>', (Request request, String id) async {
    final pipeline = Pipeline().addMiddleware(auth);
    return pipeline.addHandler((Request req) async {
      final userId = req.context['userId'] as String;
      final deleted = dbService.deleteLogEntry(id, userId);

      if (!deleted) {
        return Response.notFound(
          jsonEncode({'error': 'Log entry not found'}),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({'message': 'Deleted successfully'}),
        headers: _jsonHeaders,
      );
    })(request);
  });

  return router;
}

String _generateId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final rand = now.toRadixString(36);
  final suffix = DateTime.now().microsecond.toRadixString(36).padLeft(4, '0');
  return '$rand$suffix';
}
