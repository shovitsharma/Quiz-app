import 'package:flutter/material.dart';
import 'package:quiz_app/quiz_created.dart';

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

  final List<Question> _questions = [];
  int _currentQuestionIndex = 0; // Tracks the current question being viewed/edited

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
      _showAlertDialog('Duplicate content found. Please ensure the question and all options are unique.');
      return false;
    }
    return true;
  }

  /// Saves or updates the question currently displayed in the text fields.
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
      // Update existing question
      _questions[_currentQuestionIndex] = newQuestion;
    } else {
      // Add new question
      _questions.add(newQuestion);
    }
  }
  
  /// Loads the data of a specific question into the UI.
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

  void _handleSubmit() {
    if (!_areFieldsFilled || _correctAnswerLabel == null || !_validateUniqueness()) {
      _handleValidation();
      return;
    }
    _saveOrUpdateCurrentQuestion();
    _showSubmissionDialogs();
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
        // Navigate forward to an existing question
        _loadQuestionData(_currentQuestionIndex);
      } else {
        // Create a new blank question
        _clearForm();
      }
    });
    print("Navigated to question ${_currentQuestionIndex + 1}. Total questions: ${_questions.length}");
  }

  /// NEW: Handles the logic for the "Previous" button.
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
    } else if (!_validateUniqueness()) {
      // Alert is shown by the validation function
    }
  }

  Future<void> _showSubmissionDialogs() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
        ),
        child: child!,
      );
    },
    );
    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Name'),
        content: TextField(
          controller: _quizNameController,
          decoration: const InputDecoration(hintText: 'Enter quiz name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              final finalQuiz = Quiz(
                name: _quizNameController.text,
                date: pickedDate,
                time: pickedTime,
                questions: _questions,
              );
              Navigator.of(context).pop();

              // Generate a random code (in real app, this comes from backend)
            final String quizCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();

            // Navigate to "Quiz Created Screen"
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => QuizCreatedScreen(quizCode: quizCode),
              ),
            );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(child: const Text('Validation error',style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400 ),)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,style: TextStyle(fontSize: 15),textAlign: TextAlign.center,),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
                          _buildOption(label: 'A.', controller: _optionAController, borderColor: Colors.blue.shade700),
                          const SizedBox(height: 16),
                          _buildOption(label: 'B.', controller: _optionBController, borderColor: Colors.yellow.shade700),
                          const SizedBox(height: 16),
                          _buildOption(label: 'C.', controller: _optionCController, borderColor: Colors.green.shade600),
                          const SizedBox(height: 16),
                          _buildOption(label: 'D.', controller: _optionDController, borderColor: Colors.red.shade600),
                          const SizedBox(height: 20),
                          if (_areFieldsFilled && _correctAnswerLabel == null)
                            const Center(
                              child: Text(
                                'Tap the circle to select the correct answer.',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        _buildNavigationButtons(isFormComplete: isFormComplete),
                        const SizedBox(height: 16),
                        _buildSubmitButton(isFormComplete: isFormComplete),
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

  Widget _buildOption({required String label, required TextEditingController controller, required Color borderColor}) {
    final bool isSelected = _correctAnswerLabel == label;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? Colors.green.shade600 : borderColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter option',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_areFieldsFilled) {
                setState(() {
                  _correctAnswerLabel = label;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Colors.green.shade600 : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons({required bool isFormComplete}) {
    // The "Previous" button is enabled if the index is greater than 0
    final bool canGoBack = _currentQuestionIndex > 0;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            // UPDATED: Calls _handlePrevious and is disabled when it can't go back
            onPressed: canGoBack ? _handlePrevious : null,
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
    );
  }

  Widget _buildSubmitButton({required bool isFormComplete}) {
    return ElevatedButton(
      onPressed: isFormComplete ? _handleSubmit : _handleValidation,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFormComplete ? Colors.blue.shade600 : Colors.blue.shade300,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuestionTextField() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: _questionController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(hintText: 'Enter your question', contentPadding: EdgeInsets.all(20), border: InputBorder.none),
      ),
    );
  }

  Widget _buildBackground() {
    return ClipPath(
      clipper: _BackgroundClipper(),
      child: Container(height: 250, color: Colors.red.shade400),
    );
  }
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
