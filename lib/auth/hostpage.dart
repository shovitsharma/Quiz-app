import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/leaderboard.dart'; // For FinalLeaderboardScreen

// Enum to manage the host's current view
enum HostScreenState {
  showingQuestion,
  showingLeaderboard,
}

class HostQuizScreen extends StatefulWidget {
  final String sessionId;
  final LiveQuestion initialQuestion;

  const HostQuizScreen({
    super.key,
    required this.sessionId,
    required this.initialQuestion,
  });

  @override
  State<HostQuizScreen> createState() => _HostQuizScreenState();
}

class _HostQuizScreenState extends State<HostQuizScreen> {
  final _socketService = LiveSocketService.instance;
  HostScreenState _screenState = HostScreenState.showingQuestion;

  late LiveQuestion _currentQuestion;
  List<LobbyPlayer> _leaderboard = [];

  StreamSubscription? _leaderboardSubscription;
  StreamSubscription? _questionSubscription;
  StreamSubscription? _quizEndedSubscription;

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.initialQuestion;
    _subscribeToSocketEvents();
  }

  @override
  void dispose() {
    _leaderboardSubscription?.cancel();
    _questionSubscription?.cancel();
    _quizEndedSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToSocketEvents() {
    // Listen for the intermediate leaderboard updates from the server.
    _leaderboardSubscription = _socketService.leaderboardUpdates.listen((leaderboard) {
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _screenState = HostScreenState.showingLeaderboard; // Switch the view
        });
      }
    });

    // Listen for the next question to switch back to the question view.
    _questionSubscription = _socketService.questions.listen((question) {
      if (mounted) {
        setState(() {
          _currentQuestion = question;
          _screenState = HostScreenState.showingQuestion; // Switch back
        });
      }
    });

    // Listen for the final end-of-quiz signal.
    _quizEndedSubscription = _socketService.quizEnded.listen((data) {
      if (mounted) {
        final finalLeaderboard = (data['leaderboard'] as List)
            .map((p) => LobbyPlayer.fromJson(p))
            .toList();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => FinalLeaderboardScreen(
              finalLeaderboard: finalLeaderboard,
              currentPlayerName: 'Host', // Or a host name if you have one
            ),
          ),
        );
      }
    });
  }

  // --- HOST ACTIONS ---

  void _requestNextQuestion() {
    // Tell the server to send the next question to all players
    _socketService.hostNextQuestion();
  }

  void _requestEndQuiz() {
    // Tell the server to end the quiz for everyone
    _socketService.hostEndQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Using the same background for consistency
          ClipPath(
            clipper: _BackgroundClipper(),
            child: Container(height: 250, color: Colors.red.shade400),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              // Switch between the two views based on the current state
              child: _screenState == HostScreenState.showingQuestion
                  ? _buildQuestionView()
                  : _buildLeaderboardView(),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI FOR SHOWING THE QUESTION ---
  Widget _buildQuestionView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Question Sent to Players:",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              Text(
                '${_currentQuestion.index + 1}. ${_currentQuestion.text}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Display the correct answer to the host
              Text(
                "Correct Answer: ${_currentQuestion.options[_currentQuestion.correctAnswerIndex]}",
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              )
            ],
          ),
        ),
         const Spacer(),
         // This button would be hidden and automatically triggered by a timer on the server
         const Center(child: Text("Waiting for players to answer...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),))
      ],
    );
  }

  // --- UI FOR SHOWING THE LEADERBOARD ---
  Widget _buildLeaderboardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Live Leaderboard",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListView.builder(
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                final player = _leaderboard[index];
                return ListTile(
                  leading: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  title: Text(player.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  trailing: Text(
                    '${player.score} pts',
                    style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Host controls to proceed
        ElevatedButton(
          onPressed: _requestNextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Next Question', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _requestEndQuiz,
          child: const Text('End Quiz Now', style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
      ],
    );
  }
}

// Reusable background clipper
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
