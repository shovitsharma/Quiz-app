import 'package:flutter/material.dart';
import 'package:quiz_app/auth/auth_service.dart';
import 'package:quiz_app/auth/live_quizservice.dart';
import 'package:quiz_app/auth/quiz_service.dart';
import 'package:quiz_app/host_lobbby.dart';
import 'package:quiz_app/login.dart'; // Assuming QuizPageTemplate is in here

// --- DATA MODELS ---
class Question {
  String text;
  List<String> options;
  int correctIndex;

  Question({required this.text, required this.options, required this.correctIndex});

  Map<String, dynamic> toJson() {
    return {'text': text, 'options': options, 'correctIndex': correctIndex};
  }
}

// --- WIDGET ---
class QuizCreationPage extends StatefulWidget {
  const QuizCreationPage({super.key});

  @override
  State<QuizCreationPage> createState() => _QuizCreationPageState();
}

class _QuizCreationPageState extends State<QuizCreationPage> {
  // --- STATE ---
  final _formKey = GlobalKey<FormState>();
  final _quizTitleController = TextEditingController();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers =
      List.generate(4, (_) => TextEditingController());
  int? _selectedCorrectIndex;
  final List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isSavingAndHosting = false;

  @override
  void dispose() {
    _quizTitleController.dispose();
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- LOGIC ---

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<void> _saveQuizAndHost() async {
    if (_quizTitleController.text.trim().isEmpty) {
      _showErrorDialog('Please provide a title for your quiz.');
      return;
    }
    if (_questions.isEmpty) {
      _showErrorDialog('Please add at least one question.');
      return;
    }

    setState(() => _isSavingAndHosting = true);

    try {
      final questionsPayload = _questions.map((q) => q.toJson()).toList();
      final quizData = await QuizService.instance.createQuiz(
        title: _quizTitleController.text.trim(),
        questions: questionsPayload,
      );
      final newQuizId = quizData['quiz']['_id'];

      final sessionData = await LiveSessionService.instance.createSession(quizId: newQuizId);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HostLobbyScreen(
              sessionId: sessionData['sessionId'],
              hostKey: sessionData['hostKey'],
              joinCode: sessionData['code'],
            ),
          ),
        );
        _clearFullForm();
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSavingAndHosting = false);
      }
    }
  }

  void _clearFullForm() {
    setState(() {
      _quizTitleController.clear();
      _questions.clear();
      _navigateToQuestion(0);
    });
  }

  void _saveAndContinue() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCorrectIndex == null) {
      _showErrorDialog('Please select a correct answer.');
      return;
    }
    final newQuestion = Question(
      text: _questionController.text.trim(),
      options: _optionControllers.map((c) => c.text.trim()).toList(),
      correctIndex: _selectedCorrectIndex!,
    );
    setState(() {
      if (_currentQuestionIndex < _questions.length) {
        _questions[_currentQuestionIndex] = newQuestion;
      } else {
        _questions.add(newQuestion);
      }
      _navigateToQuestion(_questions.length);
    });
  }

  void _deleteCurrentQuestion() {
    if (_currentQuestionIndex < _questions.length) {
      setState(() {
        _questions.removeAt(_currentQuestionIndex);
        final newIndex = _currentQuestionIndex >= _questions.length
            ? _questions.length
            : _currentQuestionIndex;
        _navigateToQuestion(newIndex);
      });
    }
  }

  void _navigateToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
      if (index < _questions.length) {
        _loadQuestionData(index);
      } else {
        _clearQuestionForm();
      }
    });
  }

  void _loadQuestionData(int index) {
    final question = _questions[index];
    _questionController.text = question.text;
    for (int i = 0; i < 4; i++) {
      _optionControllers[i].text = question.options[i];
    }
    _selectedCorrectIndex = question.correctIndex;
  }

  void _clearQuestionForm() {
    _formKey.currentState?.reset();
    _questionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    _selectedCorrectIndex = null;
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    bool isEditing = _currentQuestionIndex < _questions.length;

    return QuizPageTemplate(
      child: Column(
        children: [
          _buildAppBar(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuizTitleField(),
                  const SizedBox(height: 16),
                  _buildQuestionNavigator(),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1, color: Colors.black26),
                  _buildQuestionHeader(isEditing),
                  _buildQuestionForm(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Create & Host Quiz',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildQuizTitleField() {
    return TextFormField(
      controller: _quizTitleController,
      decoration: InputDecoration(
        hintText: 'Enter Quiz Title',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Title is required' : null,
    );
  }

  Widget _buildQuestionNavigator() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _questions.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          bool isSelected = index == _currentQuestionIndex;
          return ActionChip(
            label: Text('${index + 1}'),
            backgroundColor: isSelected ? Colors.black : Colors.white,
            labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold),
            onPressed: () => _navigateToQuestion(index),
            side: BorderSide(color: Colors.grey.shade400),
          );
        },
      ),
    );
  }

  Widget _buildQuestionHeader(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${isEditing ? "Editing" : "New"} Question #${_currentQuestionIndex + 1}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
              onPressed: _deleteCurrentQuestion,
              tooltip: 'Delete this question',
            )
        ],
      ),
    );
  }

  Widget _buildQuestionForm() {
    return Form(
      key: _formKey,
      child: Column(children: [
        TextFormField(
          controller: _questionController,
          decoration: InputDecoration(
            hintText: 'Enter question text...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Question text is required' : null,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ...List.generate(4, (index) {
          bool isSelected = _selectedCorrectIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Option ${String.fromCharCode(65 + index)}',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.green : Colors.grey),
                  onPressed: () => setState(() => _selectedCorrectIndex = index),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Option is required' : null,
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: _saveAndContinue,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.black, width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Save & Add Next',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: (_isSavingAndHosting || _questions.isEmpty)
              ? null
              : _saveQuizAndHost,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isSavingAndHosting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
              : Text(
                  'Finish & Host Quiz (${_questions.length}Q)',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}