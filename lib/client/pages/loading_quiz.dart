import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/take_quiz.dart';

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
  // --- STATE ---
  final _socketService = LiveSocketService.instance;
  StreamSubscription? _lobbySubscription;
  StreamSubscription? _questionSubscription;
  List<LobbyPlayer> _players = [];

  @override
  void initState() {
    super.initState();
    // This screen's job is to LISTEN to events for the session we just joined.
    _subscribeToEvents();
  }

  @override
  void dispose() {
    // Clean up subscriptions to prevent memory leaks.
    _lobbySubscription?.cancel();
    _questionSubscription?.cancel();
    // We DO NOT disconnect here, as the connection is needed for the quiz screen.
    super.dispose();
  }

  // --- LOGIC ---

  // In player_lobby_screen.dart

  /// Subscribes to the streams from the LiveSocketService.
  void _subscribeToEvents() {
    // Listen for updates to the player list.
    _lobbySubscription = _socketService.lobbyUpdates.listen((players) {
      setState(() {
        _players = players;
      });
    });

    // Listen for the 'question:show' event, which signals the start of the quiz.
    _questionSubscription = _socketService.questions.listen((question) {
      if (mounted) {
        // When the first question arrives, navigate to the quiz screen.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TakeQuizScreen(
              sessionId: widget.sessionId,
              playerId: widget.playerId,
              playerName: widget.playerName, // ✨ ADD THIS LINE
              initialQuestion: question,
            ),
          ),
        );
      }
    });
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
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
              const Text("Waiting for the host to start...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER ---

  /// A live-updating list of players in the lobby.
  Widget _buildPlayerList() {
    return Container(
      height: 200, // Give the list a fixed height within the card
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