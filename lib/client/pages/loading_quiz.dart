import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/auth/quiz_service.dart';
import 'package:quiz_app/client/pages/take_Quiz.dart';
import 'package:quiz_app/login.dart'; 

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
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _joinQuiz();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _joinQuiz() async {
    try {
      await QuizService.joinQuiz(
        quizCode: widget.quizCode,
        playerName: widget.playerName,
        profilePic: widget.profilePic,
      );
    } catch (e) {
      print("Error joining quiz: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to join quiz")),
      );
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final quizStarted = await QuizService.checkQuizStatus(quizCode: widget.quizCode);
        if (quizStarted) {
          _pollTimer?.cancel();
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TakeQuizScreen(quizId: widget.quizCode,nickname: widget.playerName,),
            ),
          );
        }
      } catch (e) {
        print("Polling error: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),
              Divider(thickness: 0.3, color: Colors.black),
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
