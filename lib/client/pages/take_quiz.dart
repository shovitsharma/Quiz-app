import 'package:flutter/material.dart';
import 'package:quiz_app/login.dart';

class QuizQuestion {
  String question;
  List<String> options;
  int correctIndex;

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

    return QuizPageTemplate(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.question,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Manual Radio Group
          Column(
            children: List.generate(question.options.length, (index) {
              return Row(
                children: [
                  Radio<int>(
                    value: index,
                    groupValue: _selectedAnswers[_currentQuestion],
                    onChanged: (int? val) {
                      if (val != null) {
                        setState(() {
                          _selectedAnswers[_currentQuestion] = val;
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAnswers[_currentQuestion] = index;
                        });
                      },
                      child: Text(
                        question.options[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),

          const Spacer(),

          // Navigation Buttons
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
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_currentQuestion < widget.questions.length - 1) {
                    setState(() {
                      _currentQuestion++;
                    });
                  } else {
                    _submitQuiz();
                  }
                },
                child: Text(
                    _currentQuestion == widget.questions.length - 1
                        ? 'Submit'
                        : 'Next'),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _submitQuiz() {
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
