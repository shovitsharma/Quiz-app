import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/leaderboard.dart';

class TakeQuizScreen extends StatefulWidget {
  final String sessionId;
  final String playerId;
  final String playerName;
  final LiveQuestion initialQuestion;

  const TakeQuizScreen({
    super.key,
    required this.sessionId,
    required this.playerId,
    required this.playerName,
    required this.initialQuestion,
  });

  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  final _socketService = LiveSocketService.instance;
  late LiveQuestion _currentQuestion;
  List<LobbyPlayer> _leaderboard = [];

  /// Tracks submitted answers: {questionIndex: answerIndex}
  final Map<int, int> _submittedAnswers = {};
  /// Tracks the currently selected option for the current question before submission.
  int? _tempSelectedAnswerIndex;

  StreamSubscription? _questionSubscription;
  StreamSubscription? _leaderboardSubscription;
  StreamSubscription? _quizEndedSubscription;

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.initialQuestion;
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _questionSubscription?.cancel();
    _leaderboardSubscription?.cancel();
    _quizEndedSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _questionSubscription = _socketService.questions.listen((question) {
      if (mounted) {
        setState(() {
          _currentQuestion = question;
          _tempSelectedAnswerIndex = null; // Reset selection for new question
        });
      }
    });

    _leaderboardSubscription = _socketService.leaderboardUpdates.listen((leaderboard) {
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
        });
      }
    });

    _quizEndedSubscription = _socketService.quizEnded.listen((data) {
      if (mounted) {
        final finalLeaderboard = (data['leaderboard'] as List)
            .map((p) => LobbyPlayer.fromJson(p))
            .toList();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => FinalLeaderboardScreen(
              finalLeaderboard: finalLeaderboard,
              currentPlayerName: widget.playerName,
            ),
          ),
        );
      }
    });
  }

  /// Sets the temporary selected answer index when a user taps an option.
  void _selectOption(int index) {
    if (_submittedAnswers.containsKey(_currentQuestion.index)) return;
    setState(() {
      _tempSelectedAnswerIndex = index;
    });
  }

  /// Submits the currently selected answer to the server.
  Future<void> _submitAnswer() async {
    final questionIndex = _currentQuestion.index;
    final answerIndex = _tempSelectedAnswerIndex;

    // Guard against submitting without a selection or re-submitting.
    if (answerIndex == null || _submittedAnswers.containsKey(questionIndex)) return;

    // Lock the answer in the UI immediately for a responsive feel.
    setState(() {
      _submittedAnswers[questionIndex] = answerIndex;
    });

    try {
      // Submit to the server in the background. No feedback is shown.
      await _socketService.submitAnswer(
        questionIndex: questionIndex,
        answerIndex: answerIndex,
      );
    } on SocketException catch (e) {
      if (mounted) {
        // If submission fails, unlock the UI to allow the user to try again.
        setState(() {
          _submittedAnswers.remove(questionIndex);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final hasAnswered = _submittedAnswers.containsKey(_currentQuestion.index);
    final optionColors = [
      Colors.blue.shade700,
      Colors.yellow.shade700,
      Colors.green.shade600,
      Colors.red.shade600,
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildBackground(), // The red curved background
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuestionCard(
                    '${_currentQuestion.index + 1}.',
                    _currentQuestion.text,
                  ),
                  const SizedBox(height: 30),
                  ...List.generate(_currentQuestion.options.length, (index) {
                    return _buildOptionTile(
                      text: _currentQuestion.options[index],
                      index: index,
                      isSelected: _tempSelectedAnswerIndex == index,
                      hasAnswered: hasAnswered,
                      borderColor: optionColors[index % optionColors.length],
                    );
                  }),
                  const Spacer(),
                  // Conditionally show Submit button or "Waiting..." text
                  if (!hasAnswered)
                    ElevatedButton(
                      // Button is disabled until an option is selected
                      onPressed: _tempSelectedAnswerIndex != null ? _submitAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                  else
                    const Center(
                      child: Text(
                        'Waiting for the next question...',
                        style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
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

  /// Builds the red curved shape in the background.
  Widget _buildBackground() {
    return ClipPath(
      clipper: _BackgroundClipper(),
      child: Container(
        height: 200,
        color: Colors.red.shade400,
      ),
    );
  }

  /// Builds the question card with number, timer, and text.
  Widget _buildQuestionCard(String questionNumber, String questionText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                questionNumber,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  '00:00', // Placeholder for timer
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            questionText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Builds an option tile with a colored border.
  Widget _buildOptionTile({
    required String text,
    required int index,
    required bool isSelected,
    required bool hasAnswered,
    required Color borderColor,
  }) {
    Color getBackgroundColor() {
      // Highlight the option if it's the currently selected one.
      if (isSelected) return borderColor.withOpacity(0.1);
      return Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        // Allow tapping only if the answer has not been submitted for this question.
        onTap: hasAnswered ? null : () => _selectOption(index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                '${String.fromCharCode(65 + index)}. ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: borderColor),
              ),
              Expanded(
                child: Text(text, style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom clipper to create the curved background shape.
class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}