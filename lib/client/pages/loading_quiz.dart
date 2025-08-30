import 'package:flutter/material.dart';
import 'package:quiz_app/login.dart'; 

class WaitingRoomScreen extends StatelessWidget {
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

              // Profile pic
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(profilePic),
              ),
              const SizedBox(height: 15),

              Text(
                playerName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),
              Divider(thickness: 0.3, color: Colors.black),
              const SizedBox(height: 20),

              Text(
                "Quiz Code: $quizCode",
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
