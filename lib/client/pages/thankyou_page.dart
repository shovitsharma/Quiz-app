import 'package:flutter/material.dart';
import 'package:quiz_app/client/pages/credits.dart';
import 'dart:math' as math; // For the logo
import 'package:quiz_app/first_page.dart'; // Import your home page file

// --- This is the new page ---
class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QuizPageTemplate(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Using the smaller text logo for this page
          const QuizTextLogo(fontSize: 60),
          const SizedBox(height: 50),
          const Text(
            'Thank You for Playing!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () {
              // CORRECTED NAVIGATION:
              // This pushes the QuizFirstPage and removes all previous screens.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const CreditsPage()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
            child: const Text(
              'About the Developers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}


// --- SUPPORTING WIDGETS (You should have these in your project already) ---

// The "QUIZ" text logo widget
class QuizTextLogo extends StatelessWidget {
  final double fontSize;
  const QuizTextLogo({super.key, this.fontSize = 80.0});

  @override
  Widget build(BuildContext context) {
    const FontWeight fontWeight = FontWeight.w900;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: -math.pi / 12,
          child: Text(
            '?',
            style: TextStyle(
              fontSize: fontSize + 15,
              fontWeight: fontWeight,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
            ),
            children: <TextSpan>[
              TextSpan(text: 'U', style: TextStyle(color: Colors.red.shade600)),
              TextSpan(text: 'I', style: TextStyle(color: Colors.yellow.shade700)),
              TextSpan(text: 'Z', style: TextStyle(color: Colors.green.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}

// The reusable page template with the background
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
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        backgroundBlendMode: BlendMode.multiply,
      ),
    );
  }
}

