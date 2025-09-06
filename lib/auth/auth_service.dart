import 'dart:async';
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
  AuthService._privateConstructor() {
    // Check initial login status when the service is created
    _checkInitialAuthStatus();
  }
  static final AuthService instance = AuthService._privateConstructor();

  // --- Properties ---
  // CRITICAL FIX: Removed trailing space from the URL
  static const String _baseUrl = "https://team-01-u90d.onrender.com/api";
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // --- State Management ---
  // A stream to notify the app about authentication status changes.
  final StreamController<bool> _authStatusController = StreamController<bool>.broadcast();
  Stream<bool> get authStatusStream => _authStatusController.stream;

  // --- Private Helper Methods ---

  /// Checks the initial authentication status when the app starts.
  void _checkInitialAuthStatus() async {
    final token = await getToken();
    _authStatusController.add(token != null);
  }

  /// Handles decoding the response and checking for errors robustly.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // Return null for empty successful responses (e.g., 204 No Content)
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } catch (e) {
        throw AuthException('Failed to parse successful server response.');
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'An unknown error occurred';
        throw AuthException(errorMessage);
      } catch (e) {
        // Fallback for non-JSON error responses
        throw AuthException('Server error: ${response.statusCode}');
      }
    }
  }

  // --- Public API Methods ---

  /// Logs in a user and securely stores the received token.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 15)); // Added timeout

      final data = _handleResponse(response);
      final token = data['token'];

      if (token != null) {
        await _storage.write(key: _tokenKey, value: token);
        _authStatusController.add(true); // Notify listeners: Logged In
        return data;
      } else {
        throw AuthException('Login successful, but no token was received.');
      }
    } on TimeoutException {
      throw AuthException('The request timed out. Please try again.');
    }
  }

  /// Signs up a new user.
  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/signup');
    try {
       final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": name, "email": email, "password": password}),
      ).timeout(const Duration(seconds: 15)); // Added timeout
      return _handleResponse(response);
    } on TimeoutException {
       throw AuthException('The request timed out. Please try again.');
    }
  }

  /// Logs out the user by deleting their token.
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _authStatusController.add(false); // Notify listeners: Logged Out
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

  /// Closes the stream controller when the app is disposed.
  void dispose() {
    _authStatusController.close();
  }
}
