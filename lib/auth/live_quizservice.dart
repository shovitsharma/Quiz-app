import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveSessionService {
  static const String baseUrl = "http://34.235.122.140:4000/api"; // Fixed: Added /api
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Helper: Enhanced error handling
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          "success": true,
          "data": data,
          "message": data['message'] ?? "Success",
        };
      } else {
        return {
          "success": false,
          "data": null,
          "message": data['error'] ?? "Request failed",
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "data": null,
        "message": "Invalid server response: $e",
        "statusCode": response.statusCode,
      };
    }
  }

  /// Helper: Make HTTP request with timeout
  static Future<Map<String, dynamic>> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(timeoutDuration);
      return _handleResponse(response);
    } catch (e) {
      return {
        "success": false,
        "data": null,
        "message": e.toString(),
      };
    }
  }

  /// -------------------------
  /// 1️⃣ Create a live session (host)
  /// -------------------------
  static Future<Map<String, dynamic>> createSession({
    required String quizId,
    String? hostName,
  }) async {
    return _makeRequest(() => http.post(
      Uri.parse('$baseUrl/sessions/create'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "quizId": quizId,
        if (hostName != null) "hostName": hostName,
      }),
    ));
  }

  /// -------------------------
  /// 2️⃣ Get session by code (public)
  /// -------------------------
  static Future<Map<String, dynamic>> getSessionByCode(String code) async {
    if (code.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Session code cannot be empty",
      };
    }

    return _makeRequest(() => http.get(
      Uri.parse('$baseUrl/sessions/code/${code.trim()}'),
    ));
  }

  /// -------------------------
  /// 3️⃣ Join session as a player (public)
  /// -------------------------
  static Future<Map<String, dynamic>> joinSession({
    required String code,
    required String playerName,
  }) async {
    // Validation
    if (code.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Session code cannot be empty",
      };
    }

    if (playerName.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Player name cannot be empty",
      };
    }

    return _makeRequest(() => http.post(
      Uri.parse('$baseUrl/sessions/join/${code.trim()}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": playerName.trim()}),
    ));
  }

  /// -------------------------
  /// 4️⃣ Start session (host)
  /// -------------------------
  static Future<Map<String, dynamic>> startSession({
    required String sessionId,
    required String hostKey, // Backend requires hostKey
  }) async {
    if (sessionId.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Session ID cannot be empty",
      };
    }

    if (hostKey.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Host key cannot be empty",
      };
    }

    return _makeRequest(() => http.post(
      Uri.parse('$baseUrl/sessions/${sessionId.trim()}/start'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"hostKey": hostKey.trim()}),
    ));
  }

  /// -------------------------
  /// 5️⃣ Get current question (public)
  /// -------------------------
  static Future<Map<String, dynamic>> getCurrentQuestion(String code) async {
    if (code.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Session code cannot be empty",
      };
    }

    return _makeRequest(() => http.get(
      Uri.parse('$baseUrl/sessions/${code.trim()}/current'),
    ));
  }

  /// -------------------------
  /// 6️⃣ Next question (host)
  /// -------------------------
  static Future<Map<String, dynamic>> nextQuestion(String code) async {
    if (code.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Session code cannot be empty",
      };
    }

    return _makeRequest(() => http.post(
      Uri.parse('$baseUrl/sessions/${code.trim()}/next'),
    ));
  }

  /// -------------------------
  /// 7️⃣ Submit answer (public)
  /// -------------------------
  static Future<Map<String, dynamic>> submitAnswer({
    required String code,
    required String participantName, // Backend expects participantName, not playerId
    required int answer, // Backend expects answer, not answerIndex
  }) async {
    // Validation
    if (code.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Session code cannot be empty",
      };
    }

    if (participantName.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Participant name cannot be empty",
      };
    }

    if (answer < 0) {
      return {
        "success": false,
        "data": null,
        "message": "Answer must be non-negative",
      };
    }

    return _makeRequest(() => http.post(
      Uri.parse('$baseUrl/sessions/${code.trim()}/submit'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "participantName": participantName.trim(),
        "answer": answer,
      }),
    ));
  }

  /// -------------------------
  /// 8️⃣ End session (host)
  /// -------------------------
  static Future<Map<String, dynamic>> endSession(String code) async {
    if (code.trim().isEmpty) {
      return {
        "success": false,
        "data": null,
        "message": "Session code cannot be empty",
      };
    }

    return _makeRequest(() => http.post(
      Uri.parse('$baseUrl/sessions/${code.trim()}/end'),
    ));
  }
}