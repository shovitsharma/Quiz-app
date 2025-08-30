import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/auth/auth_service.dart';

import 'quiz_created.dart';

// --- DATA MODELS ---
class Question {
  String questionText;
  List<String> options;
  String correctAnswerLabel;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerLabel,
  });
}

class Quiz {
  final String name;
  final DateTime date;
  final TimeOfDay time;
  final List<Question> questions;

  Quiz({
    required this.name,
    required this.date,
    required this.time,
    required this.questions,
  });
}

class QuizQuestionPage extends StatefulWidget {
  const QuizQuestionPage({super.key});

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  // --- STATE VARIABLES ---
  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  final _quizNameController = TextEditingController();

  String? _correctAnswerLabel;
  bool _areFieldsFilled = false;
  bool _isSubmitting = false;

  final List<Question> _questions = [];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _questionController.addListener(_validateFields);
    _optionAController.addListener(_validateFields);
    _optionBController.addListener(_validateFields);
    _optionCController.addListener(_validateFields);
    _optionDController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _quizNameController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _areFieldsFilled = _questionController.text.isNotEmpty &&
          _optionAController.text.isNotEmpty &&
          _optionBController.text.isNotEmpty &&
          _optionCController.text.isNotEmpty &&
          _optionDController.text.isNotEmpty;
    });
  }

  bool _validateUniqueness() {
    final List<String> allTexts = [
      _questionController.text.trim(),
      _optionAController.text.trim(),
      _optionBController.text.trim(),
      _optionCController.text.trim(),
      _optionDController.text.trim(),
    ];
    final Set<String> uniqueTexts = Set<String>.from(allTexts);
    if (uniqueTexts.length < allTexts.length) {
      _showAlertDialog('Duplicate content found. Ensure question and options are unique.');
      return false;
    }
    return true;
  }

  void _saveOrUpdateCurrentQuestion() {
    final newQuestion = Question(
      questionText: _questionController.text.trim(),
      options: [
        _optionAController.text.trim(),
        _optionBController.text.trim(),
        _optionCController.text.trim(),
        _optionDController.text.trim(),
      ],
      correctAnswerLabel: _correctAnswerLabel!,
    );

    if (_currentQuestionIndex < _questions.length) {
      _questions[_currentQuestionIndex] = newQuestion;
    } else {
      _questions.add(newQuestion);
    }
  }

  void _loadQuestionData(int index) {
    if (index < _questions.length) {
      final question = _questions[index];
      _questionController.text = question.questionText;
      _optionAController.text = question.options[0];
      _optionBController.text = question.options[1];
      _optionCController.text = question.options[2];
      _optionDController.text = question.options[3];
      _correctAnswerLabel = question.correctAnswerLabel;
    }
  }

  void _clearForm() {
    _questionController.clear();
    _optionAController.clear();
    _optionBController.clear();
    _optionCController.clear();
    _optionDController.clear();
    _correctAnswerLabel = null;
  }

  void _handleNext() {
    if (!_areFieldsFilled || _correctAnswerLabel == null || !_validateUniqueness()) {
      _handleValidation();
      return;
    }
    _saveOrUpdateCurrentQuestion();
    setState(() {
      _currentQuestionIndex++;
      if (_currentQuestionIndex < _questions.length) {
        _loadQuestionData(_currentQuestionIndex);
      } else {
        _clearForm();
      }
    });
  }

  void _handlePrevious() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _loadQuestionData(_currentQuestionIndex);
      });
    }
  }

  void _handleValidation() {
    if (!_areFieldsFilled) {
      _showAlertDialog('Please fill in all fields.');
    } else if (_correctAnswerLabel == null) {
      _showAlertDialog('Please select the correct answer.');
    } else if (!_validateUniqueness()) {}
  }

  Future<void> _handleSubmit() async {
    if (!_areFieldsFilled || _correctAnswerLabel == null || !_validateUniqueness()) {
      _handleValidation();
      return;
    }

    _saveOrUpdateCurrentQuestion();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    if (!mounted) return;

    final quizName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Quiz Name'),
        content: TextField(
          controller: _quizNameController,
          decoration: const InputDecoration(hintText: 'Enter quiz name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_quizNameController.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (quizName == null || quizName.isEmpty) return;

    // --- Backend Integration ---
    final token = AuthService.getToken();
    if (token == null) {
      _showAlertDialog('You must be logged in to create a quiz.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Step 1: Create quiz
      final quizResponse = await http.post(
        Uri.parse('http://34.235.122.140:4000/api/quiz/create'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": quizName,
          "date": pickedDate.toIso8601String(),
          "time": "${pickedTime.hour}:${pickedTime.minute}",
        }),
      );

      if (quizResponse.statusCode != 201) {
        final data = jsonDecode(quizResponse.body);
        _showAlertDialog('Quiz creation failed: ${data['message']}');
        setState(() => _isSubmitting = false);
        return;
      }

      final quizData = jsonDecode(quizResponse.body);
      final String quizId = quizData['id'];

      // Step 2: Submit questions
      for (final q in _questions) {
        final questionResponse = await http.post(
          Uri.parse('http://34.235.122.140:4000/api/quiz/$quizId/question'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "questionText": q.questionText,
            "options": q.options,
            "correctAnswerLabel": q.correctAnswerLabel,
          }),
        );

        if (questionResponse.statusCode != 201) {
          final data = jsonDecode(questionResponse.body);
          _showAlertDialog('Failed to add question: ${data['message']}');
          setState(() => _isSubmitting = false);
          return;
        }
      }

      // Step 3: Navigate to QuizCreatedScreen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => QuizCreatedScreen(quizCode: quizId),
          ),
        );
      }
    } catch (e) {
      _showAlertDialog('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  // UI BUILDERS BELOW (unchanged from your existing code)
  @override
  Widget build(BuildContext context) {
    final bool isFormComplete = _areFieldsFilled && _correctAnswerLabel != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),
                          _buildQuestionTextField(),
                          const SizedBox(height: 30),
                          _buildOption('A.', _optionAController, Colors.blue.shade700),
                          const SizedBox(height: 16),
                          _buildOption('B.', _optionBController, Colors.yellow.shade700),
                          const SizedBox(height: 16),
                          _buildOption('C.', _optionCController, Colors.green.shade600),
                          const SizedBox(height: 16),
                          _buildOption('D.', _optionDController, Colors.red.shade600),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _currentQuestionIndex > 0 ? _handlePrevious : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow.shade700,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('Previous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isFormComplete ? _handleNext : _handleValidation,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormComplete ? Colors.grey.shade700 : Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: isFormComplete && !_isSubmitting ? _handleSubmit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 54),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(_isSubmitting ? 'Submitting...' : 'Submit', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, TextEditingController controller, Color borderColor) {
    final bool isSelected = _correctAnswerLabel == label;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isSelected ? Colors.green.shade600 : borderColor, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Padding(padding: const EdgeInsets.only(left: 20, right: 12), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: TextField(controller: controller, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 18)))),
          GestureDetector(
            onTap: () {
              if (_areFieldsFilled) {
                setState(() => _correctAnswerLabel = label);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? Colors.green.shade600 : Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTextField() => Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
        child: TextField(
          controller: _questionController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(hintText: 'Enter your question', contentPadding: EdgeInsets.all(20), border: InputBorder.none),
        ),
      );

  Widget _buildBackground() => ClipPath(clipper: _BackgroundClipper(), child: Container(height: 250, color: Colors.red.shade400));
}

class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
