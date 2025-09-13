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

  // --- STATE VARIABLES ---
  final Map<int, int> _submittedAnswers = {};
  int? _tempSelectedAnswerIndex;
  // ✨ ADDED: Stores the correct answer's index after the server reveals it.
  int? _revealedCorrectAnswerIndex;

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
          _tempSelectedAnswerIndex = null;
          // ✨ ADDED: Reset the revealed answer for the new question.
          _revealedCorrectAnswerIndex = null;
        });
      }
    });

    _leaderboardSubscription = _socketService.leaderboardUpdates.listen((leaderboard) {
      if (mounted) {
        setState(() => _leaderboard = leaderboard);
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

  void _selectOption(int index) {
    if (_submittedAnswers.containsKey(_currentQuestion.index)) return;
    setState(() {
      _tempSelectedAnswerIndex = index;
    });
  }

  /// ✨ MODIFIED: Now processes the server response to reveal the correct answer.
  Future<void> _submitAnswer() async {
    final questionIndex = _currentQuestion.index;
    final answerIndex = _tempSelectedAnswerIndex;

    if (answerIndex == null || _submittedAnswers.containsKey(questionIndex)) return;

    setState(() {
      _submittedAnswers[questionIndex] = answerIndex;
    });

    try {
      // Get the response from the server.
      final response = await _socketService.submitAnswer(
        questionIndex: questionIndex,
        answerIndex: answerIndex,
      );

      // Process the response to update the UI.
      if (mounted) {
        final int? correctAnswerFromServer = response['correctAnswerIndex'];
        setState(() {
          _revealedCorrectAnswerIndex = correctAnswerFromServer;
        });
      }
    } on SocketException catch (e) {
      if (mounted) {
        setState(() => _submittedAnswers.remove(questionIndex));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnswered = _submittedAnswers.containsKey(_currentQuestion.index);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildBackground(),
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
                      hasSubmitted: hasAnswered,
                      revealedCorrectIndex: _revealedCorrectAnswerIndex,
                    );
                  }),
                  const Spacer(),
                  if (!hasAnswered)
                    ElevatedButton(
                      onPressed: _tempSelectedAnswerIndex != null ? _submitAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E9),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                      child: const Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
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
  
  // --- UI WIDGETS ---

  Widget _buildBackground() {
    return ClipPath(
      clipper: _BackgroundClipper(),
      child: Container(height: 200, color: Colors.red.shade400),
    );
  }

  Widget _buildQuestionCard(String questionNumber, String questionText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(questionNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  
  /// ✨ MODIFIED: This widget now has advanced logic to color the options correctly.
  Widget _buildOptionTile({
    required String text,
    required int index,
    required bool isSelected,
    required bool hasSubmitted,
    int? revealedCorrectIndex,
  }) {
    final optionColors = [
      Colors.blue.shade700,
      Colors.yellow.shade700,
      Colors.green.shade600,
      Colors.red.shade600,
    ];

    Color getBackgroundColor() {
      // After the correct answer is revealed...
      if (revealedCorrectIndex != null) {
        if (index == revealedCorrectIndex) {
          return Colors.green.shade50; // Correct answer is light green
        } else if (isSelected) {
          return Colors.red.shade50; // User's wrong choice is light red
        }
      }
      // Before submission, highlight the temporarily selected option.
      if (isSelected && !hasSubmitted) return const Color.fromARGB(255, 211, 229, 245);
      
      return Colors.white; // Default
    }

    Color getBorderColor() {
       if (revealedCorrectIndex != null) {
        if (index == revealedCorrectIndex) {
          return Colors.green.shade600; // Strong green for correct
        } else if (isSelected) {
          return Colors.red.shade600; // Strong red for incorrect
        }
        return Colors.grey.shade300; // Muted for other options
      }
      return optionColors[index % optionColors.length];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: hasSubmitted ? null : () => _selectOption(index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            border: Border.all(color: getBorderColor(), width: 2.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                '${String.fromCharCode(65 + index)}. ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: getBorderColor()),
              ),
              Expanded(
                child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        ),
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
