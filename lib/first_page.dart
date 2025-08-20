import 'package:flutter/material.dart';
class QuizFirstPage extends StatelessWidget {
  const QuizFirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background with colored circles
          _buildBackgroundCircles(),

          // Main content: Logo and Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The logo is the most complex part. Using an SVG would be ideal for a
                  // perfect replica, but we can get very close with Flutter widgets.
                  const _QuizLogo(),
                  const SizedBox(height: 80),

                  // "Enter the Quiz" Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Enter the Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "Host the Quiz" Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Host the Quiz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the decorative circles in the background.
  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        // Top-left circles
        Positioned(
          top: -100,
          left: -150,
          child: _Circle(color: Colors.yellow.shade600, size: 350),
        ),
        Positioned(
          top: -150,
          left: -80,
          child: _Circle(color: Colors.red.shade400, size: 300),
        ),

        // Bottom-right circles
        Positioned(
          bottom: -150,
          right: -150,
          child: _Circle(color: Colors.green.shade400, size: 380),
        ),
        Positioned(
          bottom: -120,
          right: -200,
          child: _Circle(color: Colors.blue.shade300, size: 320),
        ),
      ],
    );
  }
}

/// A simple widget to create a colored circle.
class _Circle extends StatelessWidget {
  final Color color;
  final double size;

  const _Circle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A widget that approximates the "QUIZ" logo.
class _QuizLogo extends StatelessWidget {
  const _QuizLogo();

  @override
  Widget build(BuildContext context) {
    const double fontSize = 80.0;
    const FontWeight fontWeight = FontWeight.w900;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stylized 'Q' as a question mark
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '?',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: Colors.blue.shade700,
              ),
            ),
            Positioned(
              bottom: 11,
              right: 20,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        ),

        // 'UIZ' with different colors using RichText
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