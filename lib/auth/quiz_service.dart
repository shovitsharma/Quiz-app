import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class QuizService {
  static const String baseUrl = "http://34.235.122.140:4000/api";

  /// Helper: Build headers with token
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// 1️⃣ Create a new quiz
  static Future<Map<String, dynamic>> createQuiz({
    required String title,
    List<Map<String, dynamic>>? questions,
  }) async {
    final url = Uri.parse('$baseUrl/quizzes');
    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          "title": title,
          "questions": questions ?? [],
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          "success": true,
          "data": data,
          "message": data['message'] ?? "Quiz created successfully",
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

  /// 2️⃣ Add a question (matches backend exactly)
  static Future<Map<String, dynamic>> addQuestion({
    required String quizId,
    required String text, // backend expects "text"
    required List<String> options,
    required int correctIndex, // backend expects "correctIndex"
    int? points,
    int? timeLimitSec,
  }) async {
    final url = Uri.parse('$baseUrl/quizzes/$quizId/questions');
    try {
      final body = {
        "text": text,
        "options": options,
        "correctIndex": correctIndex,
      };
      if (points != null) body["points"] = points;
      if (timeLimitSec != null) body["timeLimitSec"] = timeLimitSec;

      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode(body),
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

  /// 3️⃣ Get quiz details by ID
  static Future<Map<String, dynamic>> getQuiz(String quizId) async {
    final url = Uri.parse('$baseUrl/quizzes/$quizId');
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
