import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/leaderboard.dart';
import 'package:quiz_app/login.dart'; // Assuming QuizPageTemplate is here

class HostQuestionScreen extends StatefulWidget {
  // We can pass the initial question from the lobby to prevent a loading flicker
  final LiveQuestion? initialQuestion;

  const HostQuestionScreen({super.key, this.initialQuestion});

  @override
  State<HostQuestionScreen> createState() => _HostQuestionScreenState();
}

class _HostQuestionScreenState extends State<HostQuestionScreen> {
  // --- STATE ---
  final _socketService = LiveSocketService.instance;
  StreamSubscription? _questionSubscription;
  StreamSubscription? _leaderboardSubscription;
  StreamSubscription? _quizEndedSubscription;

  LiveQuestion? _currentQuestion;
  List<LobbyPlayer> _leaderboard = [];
  bool _isLoadingNext = false;

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

  // --- LOGIC ---
  void _subscribeToEvents() {
    // Listen for new questions from the server
    _questionSubscription = _socketService.questions.listen((question) {
      setState(() {
        _currentQuestion = question;
        _leaderboard.clear(); // Clear old leaderboard for the new question
      });
    });

    // Listen for leaderboard updates after a question is finished
    _leaderboardSubscription = _socketService.leaderboardUpdates.listen((leaderboard) {
      setState(() => _leaderboard = leaderboard);
    });

    // Listen for the final "quiz ended" signal to navigate
    _quizEndedSubscription = _socketService.quizEnded.listen((finalData) {
      if (mounted) {
        final finalLeaderboard = (finalData['leaderboard'] as List)
            .map((p) => LobbyPlayer.fromJson(p))
            .toList();
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => FinalLeaderboardScreen(
              finalLeaderboard: finalLeaderboard,
              currentPlayerName: "Host", // Host isn't a player
            ),
          ),
        );
      }
    });
  }

  Future<void> _handleNextQuestion() async {
    setState(() => _isLoadingNext = true);
    try {
      await _socketService.nextQuestion();
      // On success, the 'question:show' stream listener will handle the UI update.
    } on SocketException catch (e) {
      if (mounted) _showErrorDialog(e.message);
    } finally {
      if (mounted) setState(() => _isLoadingNext = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'))
              ],
            ));
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return QuizPageTemplate(
      child: Center(
        child: _currentQuestion == null
            ? const CircularProgressIndicator(color: Colors.white)
            : _buildQuestionControlCard(),
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildQuestionControlCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_currentQuestion!.index + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            _currentQuestion!.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
          const Divider(height: 48),
          Text(
            _leaderboard.isEmpty ? 'Waiting for answers...' : 'Live Leaderboard',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildLeaderboardList(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoadingNext ? null : _handleNextQuestion,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: _isLoadingNext
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white))
                : const Text('Next Question'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return SizedBox(
      height: 150, // Fixed height for the list
      child: _leaderboard.isEmpty
          ? const Center(child: Text("Scores will appear here after the question."))
          : ListView.builder(
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                final player = _leaderboard[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(player.name),
                  trailing: Text('${player.score} pts',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
    );
  }
}