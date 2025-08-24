import 'package:flutter/material.dart';

class QuizQuestion {
  String question;
  List<String> options;
  int correctIndex; // not shown to contestant

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class TakeQuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;

  const TakeQuizScreen({super.key, required this.questions});

  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  int _currentQuestion = 0;
  Map<int, int> _selectedAnswers = {}; // questionIndex -> selected option index

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestion];

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
                  _buildQuestionCard(question.question),
                  const SizedBox(height: 30),
                  // Options
                  Column(
  children: List.generate(question.options.length, (index) {
    final isSelected = _selectedAnswers[_currentQuestion] == index;
    final label = String.fromCharCode(65 +index); // A., B., C., D.

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // spacing between options
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightBlue.shade100 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
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
              padding: const EdgeInsets.only(left: 20, right: 12),
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
                onTap: () {
                  setState(() {
                    _selectedAnswers[_currentQuestion] = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    question.options[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAnswers[_currentQuestion] = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _currentQuestion == 0
                            ? null
                            : () {
                                setState(() {
                                  _currentQuestion--;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Previous', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentQuestion < widget.questions.length - 1) {
                            setState(() {
                              _currentQuestion++;
                            });
                          } else {
                            _showScore();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          _currentQuestion == widget.questions.length - 1 ? 'Submit' : 'Next',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
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

  void _showScore() {
    int score = 0;
    widget.questions.asMap().forEach((i, q) {
      if (_selectedAnswers[i] == q.correctIndex) score++;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('Your score: $score / ${widget.questions.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
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
