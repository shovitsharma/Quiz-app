import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A custom exception to handle authentication-specific errors.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Manages user authentication (signup, login, token storage).
/// Implemented as a singleton to ensure a single instance.
class AuthService {
  // --- Singleton Setup ---
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  // --- Properties ---
  static const String _baseUrl = "http://34.235.122.140:4000/api";
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token'; // Key for storing the token securely

  // --- Private Helper Methods ---

  /// Handles decoding the response and checking for errors.
  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    // Success codes are 200 (OK) or 201 (Created)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      // Throw a custom exception with the server's error message
      throw AuthException(responseBody['message'] ?? 'An unknown error occurred.');
    }
  }

  // --- Public API Methods ---

  /// Logs in a user and securely stores the received token.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = _handleResponse(response);
    final token = data['token'];

    if (token != null) {
      // Securely store the token on the device
      await _storage.write(key: _tokenKey, value: token);
      return data;
    } else {
      throw AuthException('Login successful, but no token was received.');
    }
  }

  /// Signs up a new user.
  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/signup');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": name, "email": email, "password": password}),
    );
    // On success, the backend returns a success message.
    return _handleResponse(response);
  }

  /// Logs out the user by deleting their token.
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Retrieves the stored token. Returns null if no token is found.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Checks if the user is currently logged in (i.e., has a token).
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// A crucial helper for other services (e.g., QuizService).
  /// Returns the headers needed for authenticated API calls.
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw AuthException('Not authenticated. Please log in.');
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}