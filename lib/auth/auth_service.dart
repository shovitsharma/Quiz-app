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
class AuthService {
  // --- Singleton Setup ---
  AuthService._internal() {
    // Check initial login status when the service is created
    _checkInitialAuthStatus();
  }
  static final AuthService instance = AuthService._internal();

  // --- Properties ---
  static const String _baseUrl = "https://team-01-u90d.onrender.com/api";
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // --- State Management ---
  // A stream to notify the app about authentication status changes.
  final StreamController<bool> _authStatusController = StreamController<bool>.broadcast();
  Stream<bool> get authStatusStream => _authStatusController.stream;

  /// Checks the initial authentication status when the app starts.
  void _checkInitialAuthStatus() async {
    final token = await getToken();
    _authStatusController.add(token != null);
  }

  /// A private helper method to handle server responses and errors.
  dynamic _handleResponse(http.Response response) {
    // Try to decode the body, but handle cases where it might be empty.
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      // If decoding fails but the status code is successful, return an empty map.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {};
      }
      // Otherwise, throw an error with the status code.
      throw AuthException('Server error: ${response.statusCode}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body; // If successful, return the decoded JSON body.
    } else {
      // If the server returned an error, find the 'message' field in the JSON.
      final errorMessage = body['message'] ?? 'An unknown server error occurred.';
      throw AuthException(errorMessage);
    }
  }

  // --- Public API Methods ---

  /// Logs in a user and securely stores the received token.
  Future<void> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 15));

      final data = _handleResponse(response);
      final token = data['token'];

      if (token != null) {
        await _storage.write(key: _tokenKey, value: token);
        _authStatusController.add(true); // Notify listeners: Logged In
      } else {
        throw AuthException('Login failed: No token received from server.');
      }
    } on TimeoutException {
      throw AuthException('The request timed out. Please check your connection.');
    } on AuthException {
      rethrow; // Re-throw our custom exceptions to be caught by the UI.
    } catch (e) {
      throw AuthException('An error occurred. Please try again.');
    }
  }

  /// Signs up a new user.
  Future<void> signup(String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": name, "email": email, "password": password}),
      ).timeout(const Duration(seconds: 15));

      _handleResponse(response); // We just need to check if it was successful.
    } on TimeoutException {
      throw AuthException('The request timed out. Please check your connection.');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('An error occurred. Please try again.');
    }
  }

  /// Logs out the user by deleting their token.
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _authStatusController.add(false); // Notify listeners: Logged Out
  }

  /// Retrieves the stored token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Checks if the user is currently logged in.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// **ADDED BACK**: Returns the headers needed for authenticated API calls.
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw AuthException('You are not logged in. Please log in again.');
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /// Closes the stream controller when the service is no longer needed.
  void dispose() {
    _authStatusController.close();
  }
}

