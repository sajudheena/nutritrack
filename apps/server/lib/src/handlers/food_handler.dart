import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:common/common.dart';

const _jsonHeaders = {'Content-Type': 'application/json'};

Router foodRouter() {
  final router = Router();

  // GET /foods — list all foods, optionally filtered by ?q=query
  router.get('/foods', (Request request) {
    final query = request.url.queryParameters['q'];
    final items = query != null && query.isNotEmpty
        ? FoodDatabase.search(query)
        : FoodDatabase.items;

    return Response.ok(
      jsonEncode(items.map((f) => f.toJson()).toList()),
      headers: _jsonHeaders,
    );
  });

  // GET /foods/:id — get a single food item by id
  router.get('/foods/<id>', (Request request, String id) {
    final item = FoodDatabase.findById(id);
    if (item == null) {
      return Response.notFound(
        jsonEncode({'error': 'Food item not found'}),
        headers: _jsonHeaders,
      );
    }
    return Response.ok(jsonEncode(item.toJson()), headers: _jsonHeaders);
  });

  return router;
}
