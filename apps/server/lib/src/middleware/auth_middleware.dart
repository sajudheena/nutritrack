import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../auth/jwt_service.dart';

/// Shelf middleware that validates a Bearer JWT token.
///
/// On success, attaches the userId to request context under the key 'userId'.
/// On failure, returns 401.
Middleware authMiddleware(JwtService jwtService) {
  return (Handler innerHandler) {
    return (Request request) {
      final authHeader = request.headers['authorization'] ??
          request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(
          jsonEncode({'error': 'Missing or invalid Authorization header'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring('Bearer '.length).trim();
      final userId = jwtService.verifyToken(token);

      if (userId == null) {
        return Response.unauthorized(
          jsonEncode({'error': 'Invalid or expired token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final updatedRequest = request.change(context: {'userId': userId});
      return innerHandler(updatedRequest);
    };
  };
}

/// Simple CORS middleware — allows all origins (adjust for production).
Middleware corsMiddleware() {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }
      final response = await innerHandler(request);
      return response.change(headers: corsHeaders);
    };
  };
}
