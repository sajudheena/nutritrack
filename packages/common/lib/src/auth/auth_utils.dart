import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Hashes [password] using SHA-256 and returns the hex digest.
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Returns true if [password] hashes to [hash].
bool verifyPassword(String password, String hash) {
  return hashPassword(password) == hash;
}
