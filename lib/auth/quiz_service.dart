import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class QuizService {
  static const String baseUrl = "http://34.235.122.140:4000";

  /// Helper: Build headers with token
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// -------------------------
  /// 1️⃣ Create a new quiz
  /// -------------------------
  static Future<Map<String, dynamic>> createQuiz({required String title}) async {
    final url = Uri.parse('$baseUrl/quiz');

    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({"title": title}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "data": data,
          "message": "Quiz created successfully",
        };
      } else {
        return {
          "success": false,
          "data": null,
          "message": data['error'] ?? "Failed to create quiz",
        };
      }
    } catch (e) {
      return {"success": false, "data": null, "message": e.toString()};
    }
  }

  /// -------------------------
  /// 2️⃣ Add a question
  /// -------------------------
  static Future<Map<String, dynamic>> addQuestion({
    required String quizId,
    required String questionText,
    required List<String> options,
    required int correctAnswer,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/$quizId/questions');

    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          "questionText": questionText,
          "options": options,
          "correctAnswer": correctAnswer,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "data": data,
          "message": "Question added successfully",
        };
      } else {
        return {
          "success": false,
          "data": null,
          "message": data['error'] ?? "Failed to add question",
        };
      }
    } catch (e) {
      return {"success": false, "data": null, "message": e.toString()};
    }
  }

  /// -------------------------
  /// 3️⃣ Get quiz details by ID
  /// -------------------------
  static Future<Map<String, dynamic>> getQuiz(String quizId) async {
    final url = Uri.parse('$baseUrl/quiz/$quizId');

    try {
      final response = await http.get(url, headers: await _headers());
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": data,
          "message": "Quiz fetched successfully",
        };
      } else {
        return {
          "success": false,
          "data": null,
          "message": data['error'] ?? "Failed to fetch quiz",
        };
      }
    } catch (e) {
      return {"success": false, "data": null, "message": e.toString()};
    }
  }
}
