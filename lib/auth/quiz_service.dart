import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/auth/auth_service.dart';

/// A custom exception for quiz-related API errors.
class QuizException implements Exception {
  final String message;
  QuizException(this.message);

  @override
  String toString() => message;
}

/// Manages creating, fetching, and updating quizzes via the REST API.
class QuizService {
  // --- Singleton Setup ---
  QuizService._privateConstructor();
  static final QuizService instance = QuizService._privateConstructor();

  // --- Properties ---
  static const String _baseUrl = "https://team-01-u90d.onrender.com ";
  final AuthService _authService = AuthService.instance; // Dependency for auth

  // --- Private Helper ---

  /// Handles decoding responses and throws a QuizException on failure.
  dynamic _handleResponse(http.Response response) {
    final responseBody = jsonDecode(response.body);
    // Success codes are 200 (OK) or 201 (Created)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      // Use 'error' key from backend response, or provide a default
      throw QuizException(responseBody['error'] ?? 'An unknown API error occurred.');
    }
  }

  // --- Public API Methods ---

  /// **[HOST-ONLY]** Fetches a list of all quizzes created by the logged-in host.
  /// Assumes a backend endpoint `GET /api/quizzes` exists for this.
  Future<List<dynamic>> getQuizzes() async {
    final url = Uri.parse('$_baseUrl/quizzes');
    final headers = await _authService.getAuthHeaders();

    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  /// **[HOST-ONLY]** Fetches the details for a single quiz by its ID.
  Future<Map<String, dynamic>> getQuiz(String quizId) async {
    final url = Uri.parse('$_baseUrl/quizzes/$quizId');
    final headers = await _authService.getAuthHeaders();

    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  /// **[HOST-ONLY]** Creates a new quiz with an initial set of questions.
  /// This is the primary method for the "Create Quiz" screen.
  Future<Map<String, dynamic>> createQuiz({
    required String title,
    required List<Map<String, dynamic>> questions,
  }) async {
    final url = Uri.parse('$_baseUrl/quizzes');
    final headers = await _authService.getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "title": title,
        "questions": questions, // Send the full list of questions at once
      }),
    );
    return _handleResponse(response);
  }

  /// **[HOST-ONLY]** Adds a single new question to an existing quiz.
  /// Useful for an "Edit Quiz" feature.
  Future<Map<String, dynamic>> addQuestion({
    required String quizId,
    required String text,
    required List<String> options,
    required int correctIndex,
  }) async {
    final url = Uri.parse('$_baseUrl/quizzes/$quizId/questions');
    final headers = await _authService.getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "text": text,
        "options": options,
        "correctIndex": correctIndex,
      }),
    );
    return _handleResponse(response);
  }
}