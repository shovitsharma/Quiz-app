import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveSessionService {
  static const String baseUrl = "http://34.235.122.140:4000";

  /// -------------------------
  /// 1️⃣ Create a live session (host)
  /// -------------------------
  static Future<Map<String, dynamic>> createSession({required String quizId}) async {
    final url = Uri.parse('$baseUrl/sessions/create');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"quizId": quizId}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Failed to create session",
      };
    }
  }

  /// -------------------------
  /// 2️⃣ Get session by code
  /// -------------------------
  static Future<Map<String, dynamic>> getSessionByCode(String code) async {
    final url = Uri.parse('$baseUrl/sessions/code/$code');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Failed to fetch session",
      };
    }
  }

  /// -------------------------
  /// 3️⃣ Join session as a player
  /// -------------------------
  static Future<Map<String, dynamic>> joinSession({
    required String code,
    required String playerName,
  }) async {
    final url = Uri.parse('$baseUrl/sessions/join/$code');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": playerName}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Failed to join session",
      };
    }
  }

  /// -------------------------
  /// 4️⃣ Start session (host)
  /// -------------------------
  static Future<Map<String, dynamic>> startSession({required String sessionId}) async {
    final url = Uri.parse('$baseUrl/sessions/$sessionId/start');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Failed to start session",
      };
    }
  }

  /// -------------------------
  /// 5️⃣ Get current question
  /// -------------------------
  static Future<Map<String, dynamic>> getCurrentQuestion(String code) async {
    final url = Uri.parse('$baseUrl/sessions/$code/current');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Failed to fetch question",
      };
    }
  }

  /// -------------------------
  /// 6️⃣ Next question (host)
  /// -------------------------
  static Future<Map<String, dynamic>> nextQuestion(String code) async {
    final url = Uri.parse('$baseUrl/sessions/$code/next');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Failed to move to next question",
      };
    }
  }

  /// -------------------------
  /// 7️⃣ Submit answer
  /// -------------------------
  static Future<Map<String, dynamic>> submitAnswer({
    required String code,
    required int questionIndex,
    required int answerIndex,
    required String playerId,
  }) async {
    final url = Uri.parse('$baseUrl/sessions/$code/submit');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "questionIndex": questionIndex,
        "answerIndex": answerIndex,
        "playerId": playerId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Failed to submit answer",
      };
    }
  }

  /// -------------------------
  /// 8️⃣ End session (host)
  /// -------------------------
  static Future<Map<String, dynamic>> endSession(String code) async {
    final url = Uri.parse('$baseUrl/sessions/$code/end');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)['error'] ?? "Failed to end session",
      };
    }
  }
}
