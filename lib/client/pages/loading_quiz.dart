import 'package:flutter/material.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/take_Quiz.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String playerName;
  final String profilePic;
  final String quizCode;

  const WaitingRoomScreen({
    super.key,
    required this.playerName,
    required this.profilePic,
    required this.quizCode,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  String? _playerId;

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
    final socketService = LiveSocketService();
    socketService.connect("http://34.235.122.140:4000"); // Fixed: Service handles /live namespace

    // Join session as player
    socketService.joinAsPlayer(
      code: widget.quizCode,
      name: widget.playerName,
      callback: (response) {
        if (response["success"] != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(response["message"] ?? "Failed to join session")),
          );
        } else {
          // Save playerId for submitting answers later
          _playerId = response["playerId"];
        }
      },
    );

    // Listen for host starting the quiz
    socketService.onQuestionShow((questionData) {
      if (!mounted || _playerId == null) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TakeQuizScreen(
            quizId: widget.quizCode,
            nickname: widget.playerName,
          ),
        ),
      );
    });

    // Optional: listen for lobby updates (player list)
    socketService.onLobbyUpdate((players) {
      setState(() {
        // Can display dynamic player list if needed
      });
    });
  }

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
              const Text(
                'Waiting Room',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(widget.profilePic),
              ),
              const SizedBox(height: 15),
              Text(
                widget.playerName,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 0.3, color: Colors.black),
              const SizedBox(height: 20),
              Text(
                "Quiz Code: ${widget.quizCode}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.black),
              const SizedBox(height: 16),
              const Text(
                "Waiting for host to start...",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}