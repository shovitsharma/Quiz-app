import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Import the AuthService to get the token

/// A custom exception for live session-related errors.
class LiveSessionException implements Exception {
  final String message;
  LiveSessionException(this.message);

  @override
  String toString() => message;
}

/// Manages the setup and lifecycle of a live quiz session via REST API.
class LiveSessionService {
  // --- Singleton Setup ---
  LiveSessionService._privateConstructor();
  static final LiveSessionService instance = LiveSessionService._privateConstructor();

  // --- Properties ---
  static const String _baseUrl = "http://34.235.122.140:4000/api";
  final AuthService _authService = AuthService.instance; // Dependency for auth

  // --- Private Helper ---

  /// Decodes responses and throws a LiveSessionException on failure.
  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw LiveSessionException(
          responseBody['error'] ?? 'An unknown server error occurred.');
    }
  }

  // --- ⚠️ Architectural Note ---
  // Methods for `submitAnswer`, `nextQuestion`, and `endSession` have been
  // intentionally removed from this HTTP service. These actions are part of the
  // real-time game flow and must be handled exclusively by your WebSocket
  // (Socket.IO) service to ensure a consistent game state for all players.
  // Using REST for these actions would lead to synchronization issues and bugs.

  // --- Public API Methods ---

  /// **[HOST-ONLY]** Creates a new live session from a quiz.
  /// This is an authenticated action and requires a valid JWT token.
  Future<Map<String, dynamic>> createSession({required String quizId}) async {
    final url = Uri.parse('$_baseUrl/sessions/create');
    final headers = await _authService.getAuthHeaders(); // Get auth headers

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"quizId": quizId}),
    );

    return _handleResponse(response);
  }

  /// **[PUBLIC]** Gets basic public information about a session using its join code.
  Future<Map<String, dynamic>> getSessionByCode(String code) async {
    final url = Uri.parse('$_baseUrl/sessions/code/${code.trim()}');
    final response = await http.get(url);
    return _handleResponse(response);
  }

  /// **[PLAYER-ONLY]** Allows a player to join a session lobby.
  Future<Map<String, dynamic>> joinSession(
      {required String code, required String playerName}) async {
    final url = Uri.parse('$_baseUrl/sessions/join/${code.trim()}');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": playerName.trim()}),
    );
    return _handleResponse(response);
  }

  /// **[HOST-ONLY]** Starts the quiz session.
  /// This endpoint is authorized using the unique `hostKey` returned upon session creation.
  Future<Map<String, dynamic>> startSession(
      {required String sessionId, required String hostKey}) async {
    final url = Uri.parse('$_baseUrl/sessions/${sessionId.trim()}/start');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"hostKey": hostKey}),
    );
    return _handleResponse(response);
  }
}