import 'package:flutter/material.dart';
import 'package:quiz_app/auth/socket_service.dart';

class QuizQuestion {
  String question;
  List<String> options;
  int correctIndex; // hidden from taker

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json["question"],
      options: List<String>.from(json["options"]),
      correctIndex: json["correctIndex"],
    );
  }
}

class TakeQuizScreen extends StatefulWidget {
  final String quizId;
  final String nickname;

  const TakeQuizScreen({
    super.key,
    required this.quizId,
    required this.nickname,
  });

  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  Map<int, int> _selectedAnswers = {};
  Map<String, dynamic>? _currentQuestion;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  @override
  void dispose() {
    LiveSocketService().disconnect();
    super.dispose();
  }

  void _connectSocket() {
    final socket = LiveSocketService();
    socket.connect("http://34.235.122.140:4000");

    // Player joins the session
    socket.joinAsPlayer(
      code: widget.quizId,
      name: widget.nickname,
      callback: (resp) {
        if (resp["success"] != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resp["message"] ?? "Failed to join")),
          );
        }
      },
    );

    // Receive next question
    socket.onQuestionShow((questionData) {
      if (!mounted) return;
      setState(() {
        _currentQuestion = questionData;
        _isLoading = false;
      });
    });

    // Session ended, show score
    socket.onSessionEnded((data) {
      _showScore();
    });
  }

  void _submitAnswer(int index) {
    if (_currentQuestion == null) return;

    final questionIndex = _currentQuestion!["index"];
    _selectedAnswers[questionIndex] = index;

    LiveSocketService().submitAnswer(
      questionIndex: questionIndex,
      answerIndex: index,
      callback: (_) {},
    );
  }

  void _showScore() {
    int score = 0;
    _selectedAnswers.forEach((index, answer) {
      if (_currentQuestion?["correctIndex"] == answer) score++;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('Your score: $score'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final questionText = _currentQuestion!["questionText"];
    final options = List<String>.from(_currentQuestion!["options"]);
    final questionIndex = _currentQuestion!["index"];
    final selectedIndex = _selectedAnswers[questionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  _buildQuestionCard(questionText),
                  const SizedBox(height: 30),
                  Column(
                    children: List.generate(options.length, (index) {
                      final isSelected = selectedIndex == index;
                      final label = String.fromCharCode(65 + index);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.lightBlue.shade100
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(65, 0, 0, 0),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 12),
                                child: Text(
                                  '$label.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _submitAnswer(index);
                                  }),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      options[index],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _submitAnswer(index);
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String questionText) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Text(
        questionText,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
