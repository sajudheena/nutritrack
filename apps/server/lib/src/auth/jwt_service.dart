import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  final String _secret;

  JwtService({String? secret})
      : _secret = secret ??
            const String.fromEnvironment(
              'JWT_SECRET',
              defaultValue: 'nutritrack-secret-change-in-production',
            );

  /// Generates a JWT token for [userId] with a 30-day expiry.
  String generateToken(String userId) {
    final jwt = JWT(
      {'userId': userId},
      issuer: 'nutritrack',
    );
    return jwt.sign(
      SecretKey(_secret),
      expiresIn: const Duration(days: 30),
    );
  }

  /// Verifies [token] and returns the userId, or null if invalid/expired.
  String? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      final payload = jwt.payload as Map<String, dynamic>;
      return payload['userId'] as String?;
    } on JWTExpiredException {
      return null;
    } on JWTException {
      return null;
    }
  }
}
