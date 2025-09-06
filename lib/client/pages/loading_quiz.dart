import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/take_quiz.dart';
// ✨ ADD THIS IMPORT for the page template
import 'package:quiz_app/login.dart'; // Assuming QuizPageTemplate is in login.dart

class PlayerLobbyScreen extends StatefulWidget {
  final String sessionId;
  final String playerId;
  final String playerName;
  final String quizCode;

  const PlayerLobbyScreen({
    super.key,
    required this.sessionId,
    required this.playerId,
    required this.playerName,
    required this.quizCode,
  });

  @override
  State<PlayerLobbyScreen> createState() => _PlayerLobbyScreenState();
}

class _PlayerLobbyScreenState extends State<PlayerLobbyScreen> {
  // --- STATE (No changes here) ---
  final _socketService = LiveSocketService.instance;
  StreamSubscription? _lobbySubscription;
  StreamSubscription? _questionSubscription;
  List<LobbyPlayer> _players = [];

  // --- initState, dispose, _subscribeToEvents (No changes here) ---
  @override
  void initState() {
    super.initState();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _lobbySubscription?.cancel();
    _questionSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _lobbySubscription = _socketService.lobbyUpdates.listen((players) {
      setState(() {
        _players = players;
      });
    });

    _questionSubscription = _socketService.questions.listen((question) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TakeQuizScreen(
              sessionId: widget.sessionId,
              playerId: widget.playerId,
              playerName: widget.playerName,
              initialQuestion: question,
            ),
          ),
        );
      }
    });
  }

  // --- UI BUILD (CHANGES ARE HERE) ---

  @override
  Widget build(BuildContext context) {
    // ✨ CHANGED HERE: Replaced Scaffold with QuizPageTemplate
    return QuizPageTemplate(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Joined! - Code: ${widget.quizCode}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'You\'re in. See who else is here!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildPlayerList(),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.black),
              const SizedBox(height: 16),
              const Text("Waiting for the host to start...",
                  style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // --- _buildPlayerList (No changes here) ---
  Widget _buildPlayerList() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: _players.isEmpty
          ? const Center(child: Text("You're the first one here!"))
          : ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                final isYou = player.name == widget.playerName;
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    player.name,
                    style: TextStyle(
                      fontWeight: isYou ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isYou ? const Text(" (You)") : null,
                );
              },
            ),
    );
  }
}