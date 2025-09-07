import 'package:flutter/material.dart';
// Import the screen you want to preview
import 'package:quiz_app/client/pages/take_quiz.dart'; 
// Import the data model needed
import 'package:quiz_app/auth/live_models.dart'; 

class TakeQuizPreview extends StatelessWidget {
  const TakeQuizPreview({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Create a fake "LiveQuestion" object with dummy data
    final mockQuestion = LiveQuestion(
      index: 0,
      text: "What is the main component of the sun?",
      options: ["Oxygen", "Helium", "Hydrogen", "Nitrogen"],
      timeLimitSec: 30, // Add a dummy time limit in seconds
    );

    // 2. Return the TakeQuizScreen and pass the mock data to it
    return TakeQuizScreen(
      sessionId: 'preview_session_123',
      playerId: 'preview_player_456',
      playerName: 'Preview Player',
      initialQuestion: mockQuestion,
    );
  }
}