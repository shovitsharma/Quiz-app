import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/leaderboard.dart';


class TakeQuizScreen extends StatefulWidget {
  // ... (constructor remains the same)
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
  // ... (state variables remain the same)
  final _socketService = LiveSocketService.instance;
  late LiveQuestion _currentQuestion;
  List<LobbyPlayer> _leaderboard = [];
  final Map<int, int> _selectedAnswers = {}; // Tracks {questionIndex: answerIndex}

  // Stream subscriptions to be cancelled on dispose
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
    // ... (questionSubscription and leaderboardSubscription remain the same)
      // Listen for the next question from the host.
    _questionSubscription = _socketService.questions.listen((question) {
      if (mounted) {
        setState(() {
          _currentQuestion = question;
        });
      }
    });

    // Listen for leaderboard updates between questions.
    _leaderboardSubscription = _socketService.leaderboardUpdates.listen((leaderboard) {
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
        });
      }
    });


    // ✨ MODIFIED PART: Listen for the signal that the quiz has ended.
    _quizEndedSubscription = _socketService.quizEnded.listen((data) {
      if (mounted) {
        final finalLeaderboard = (data['leaderboard'] as List)
            .map((p) => LobbyPlayer.fromJson(p))
            .toList();

        // Navigate to the new leaderboard screen instead of showing a dialog.
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
  
  // ✨ THIS ENTIRE METHOD IS NO LONGER NEEDED AND CAN BE DELETED
  // void _showFinalResults(List<LobbyPlayer> finalLeaderboard) { ... }

  // ... (the rest of the TakeQuizScreen code remains the same)
  
  Future<void> _submitAnswer(int answerIndex) async {
    final questionIndex = _currentQuestion.index;

    // Prevent re-answering the same question.
    if (_selectedAnswers.containsKey(questionIndex)) return;

    setState(() {
      _selectedAnswers[questionIndex] = answerIndex;
    });

    try {
      final response = await _socketService.submitAnswer(
        questionIndex: questionIndex,
        answerIndex: answerIndex,
      );
      if (mounted) {
        _showAnswerFeedback(response['correct'] ?? false);
      }
    } on SocketException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- UI FEEDBACK & DIALOGS ---

  void _showAnswerFeedback(bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct!" : "Incorrect!"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnswered = _selectedAnswers.containsKey(_currentQuestion.index);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuestionCard(_currentQuestion.text),
              const SizedBox(height: 30),
              ...List.generate(_currentQuestion.options.length, (index) {
                return _buildOptionTile(
                  text: _currentQuestion.options[index],
                  index: index,
                  isSelected: _selectedAnswers[_currentQuestion.index] == index,
                  hasAnswered: hasAnswered,
                );
              }),
              const Spacer(),
              if (hasAnswered)
                const Center(
                  child: Text(
                    'Waiting for the next question...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
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
      child: Center(
        child: Text(
          questionText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String text,
    required int index,
    required bool isSelected,
    required bool hasAnswered,
  }) {
    Color getBorderColor() {
      if (hasAnswered && isSelected) return Colors.blue.shade700;
      return Colors.grey.shade300;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: hasAnswered ? null : () => _submitAnswer(index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: getBorderColor(), width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Text(
                '${String.fromCharCode(65 + index)}. ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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