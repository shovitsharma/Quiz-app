import 'package:flutter/material.dart';
import 'dart:math' as math; // For the logo

class QuizCreatedPage extends StatelessWidget {
  // You would pass the actual unique code to this page
  final String quizCode;

  const QuizCreatedPage({super.key, this.quizCode = "6D CODE"});

  @override
  Widget build(BuildContext context) {
    // Reusing the template for a consistent background
    return QuizPageTemplate(
      child: Column(
        // UPDATED: Changed from .center to .start to move content to the top
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50), // Added padding from the top
          const _QuizLogo(),
          const SizedBox(height: 40),
          const Text(
            'Your quiz has been successfully created.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            'Your unique code is:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildCodeDisplay(quizCode),
        ],
      ),
    );
  }

  /// Builds the display box for the unique quiz code.
  Widget _buildCodeDisplay(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Text(
        code,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 4, // Adds space between characters
        ),
      ),
    );
  }
}


// --- WIDGETS USED ON THIS PAGE ---

class _QuizLogo extends StatelessWidget {
  const _QuizLogo();

  @override
  Widget build(BuildContext context) {
    const double fontSize = 50.0; // Smaller logo for this page
    const FontWeight fontWeight = FontWeight.w400;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: -math.pi / 12,
          child: Text(
            '?',
            style: TextStyle(
              fontSize: fontSize + 10,
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


// --- This is the TEMPLATE WIDGET from the previous step ---

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
          _buildBackgroundShapes(),
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

  Widget _buildBackgroundShapes() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -150,
          child: _TiltedRectangle(color: Colors.yellow.shade600, width: 300, height: 300),
        ),
        Positioned(
          top: 10,
          right: -220,
          child: _TiltedRectangle(color: Colors.blue.shade600, width: 300, height: 350),
        ),
        Positioned(
          bottom: 10,
          left: -180,
          child: _TiltedRectangle(color: Colors.green.shade600, width: 300, height: 350),
        ),
        Positioned(
          bottom: -100,
          right: -200,
          child: _TiltedRectangle(color: Colors.red.shade600, width: 300, height: 300),
        ),
      ],
    );
  }
}

class _TiltedRectangle extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _TiltedRectangle({required this.color, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 8, // tilt
      child: Container(
        width: width,
        height: height,
        // UPDATED: Corrected deprecated method
        color: color.withValues(alpha: 0.8),
      ),
    );
  }
}
