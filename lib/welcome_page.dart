import 'package:flutter/material.dart';
import 'package:quiz_app/ui_question_page.dart';

// Note: Make sure the 'QuizPageTemplate' widget is accessible from this file.
// If it's in another file, you will need to import it.

class WelcomePage extends StatelessWidget {
  // You can pass the user's name to this page after they log in
  final String name;

  const WelcomePage({super.key, this.name = "Name"}); // Default name is "Name"

  @override
  Widget build(BuildContext context) {
    // Reusing the template for a consistent background
    return QuizPageTemplate(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
        children: [
          Text(
            'Welcome $name!',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Features:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureListItem(
            title: 'Creates Quiz Easily:',
            description: 'Add title, description, and multiple-choice questions with options. Set correct answers.',
          ),
          const SizedBox(height: 24),
          _buildFeatureListItem(
            title: 'Unique Quiz Code:',
            description: 'Each quiz generates a unique join code for participants.',
          ),
          const SizedBox(height: 24),
          _buildFeatureListItem(
            title: 'Leaderboard Control:',
            description: 'Display final rankings in leaderboard at the end of the quiz.',
          ),
          const SizedBox(height: 50),
          _buildCreateQuizButton(context),
        ],
      )
    );
  }

  /// A reusable widget for displaying a feature item.
  Widget _buildFeatureListItem({required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4, // Improves readability
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the main "Create Quiz" button.
  Widget _buildCreateQuizButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const QuizQuestionPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
        child: const Text(
          'Create Quiz',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


// --- This is the TEMPLATE WIDGET from the previous step ---
// You would typically have this in its own file and import it.

class QuizPageTemplate extends StatelessWidget {
  final Widget child;
  const QuizPageTemplate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundCircles(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -150,
          child: _BlendedCircle(color: Colors.yellow.shade600, size: 300),
        ),
        Positioned(
          top: -80,
          left: -100,
          right: 2,
          child: _BlendedCircle(color: Colors.red.shade400, size: 200),
        ),
        Positioned(
          bottom: -100,
          right: -150,
          child: _BlendedCircle(color: Colors.green.shade400, size: 300),
        ),
        Positioned(
          bottom: -80,
          right: -100,
          left: 2,
          child: _BlendedCircle(color: Colors.blue.shade300, size: 200),
        ),
      ],
    );
  }
}

class _BlendedCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlendedCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(230),
        shape: BoxShape.circle,
        backgroundBlendMode: BlendMode.multiply,
      ),
    );
  }
}
