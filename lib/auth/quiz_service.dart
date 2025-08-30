import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/client/pages/take_Quiz.dart'; 

class QuizService {
  static const String baseUrl = "http://34.235.122.140:4000";

  // ------------------------------
  // JOIN QUIZ (temporary contestant)
  // ------------------------------
  static Future<Map<String, dynamic>> joinQuiz({
    required String quizCode,
    required String playerName,
    required String profilePic,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/join');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "quizCode": quizCode,
        "nickname": playerName,
        "profilePic": profilePic,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)["message"] ?? "Failed to join quiz"
      };
    }
  }

  // ------------------------------
  // CHECK QUIZ STATUS
  // ------------------------------
  static Future<bool> checkQuizStatus({required String quizCode}) async {
    final url = Uri.parse('$baseUrl/quiz/status/$quizCode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['started'] ?? false;
    } else {
      return false;
    }
  }

  // ------------------------------
  // FETCH QUIZ QUESTIONS
  // ------------------------------
  static Future<List<QuizQuestion>> getQuizQuestions({required String quizCode}) async {
    final url = Uri.parse('$baseUrl/quiz/$quizCode/questions');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['questions'];
      return data.map((q) {
        return QuizQuestion(
          question: q['question'],
          options: List<String>.from(q['options']),
          correctIndex: q['correctIndex'], // hidden in production
        );
      }).toList();
    } else {
      throw Exception('Failed to load quiz questions');
    }
  }

  // ------------------------------
  // CREATE QUIZ (returns quizCode)
  // ------------------------------
  static Future<String> createQuiz({
    required String name,
    required String date, // ISO string or "YYYY-MM-DD"
    required String time, // "HH:mm"
  }) async {
    final url = Uri.parse('$baseUrl/quiz/create');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "date": date,
        "time": time,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id']; // or data['quizCode'] depending on backend
    } else {
      final data = jsonDecode(response.body);
      throw Exception("Failed to create quiz: ${data['message']}");
    }
  }

  // ------------------------------
  // ADD QUESTION TO QUIZ
  // ------------------------------
  static Future<void> addQuestion({
    required String quizId,
    required String questionText,
    required List<String> options,
    required String correctAnswerLabel,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/$quizId/question');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "questionText": questionText,
        "options": options,
        "correctAnswerLabel": correctAnswerLabel,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception("Failed to add question: ${data['message']}");
    }
  }

  // ------------------------------
  // SUBMIT QUIZ RESULTS
  // ------------------------------
  static Future<Map<String, dynamic>> submitQuiz({
    required String quizCode,
    required String playerName,
    required List<Map<String, dynamic>> answers,
  }) async {
    final url = Uri.parse('$baseUrl/quiz/submit');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "quizCode": quizCode,
        "nickname": playerName,
        "answers": answers,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body)["message"] ?? "Failed to submit quiz"
      };
    }
  }
}
