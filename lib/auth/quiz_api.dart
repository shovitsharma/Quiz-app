import 'dart:async'; // <-- ADD THIS LINE
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/auth/auth_service.dart'; // Your existing AuthService
import 'package:quiz_app/models/hosted_quiz.dart'; // The model we just created

/// A service to handle all quiz-related API interactions.
class QuizService {
  // Singleton setup
  QuizService._internal();
  static final QuizService instance = QuizService._internal();

  static const String _baseUrl = "https://team-01-u90d.onrender.com/api";

  /// Fetches all quizzes created by the currently authenticated host.
  /// Throws an exception if the request fails.
  Future<List<HostedQuiz>> getMyQuizzes() async {
    final url = Uri.parse('$_baseUrl/quizzes/my-quizzes');
    try {
      // Get the authentication headers, which include the user's token.
      final headers = await AuthService.instance.getAuthHeaders();

      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        // Map the list of JSON objects to a list of HostedQuiz objects.
        return jsonList.map((json) => HostedQuiz.fromJson(json)).toList();
      } else {
        // Handle server errors
        throw Exception('Failed to load quizzes: Server error ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Failed to load quizzes: The request timed out.');
    } catch (e) {
      // Handle other errors (e.g., no internet)
      throw Exception('Failed to load quizzes. Please check your connection.');
    }
  }
}

