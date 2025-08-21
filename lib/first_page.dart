import 'package:flutter/material.dart';


import 'package:quiz_app/circles.dart';
import 'package:quiz_app/logo.dart';
import 'package:quiz_app/second_page.dart'; // Keep this for the rotation angle

class QuizFirstPage extends StatelessWidget {
  const QuizFirstPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The background with overlapping, blended circles.
          const BackgroundCircles(),

          // The main content (logo and buttons) centered on the screen.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const QuizLogo(), // This now uses the corrected logo
                  const SizedBox(height: 80),
                  _buildPrimaryButton(
                    text: 'Enter the Quiz',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildSecondaryButton(
                    text: 'Host the Quiz',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const QuizSecondPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the primary action button with a solid background.
  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Builds the secondary action button with an outline style.
  Widget _buildSecondaryButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.black, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Builds the decorative background with blended circles.
//   Widget _buildBackgroundCircles() {
//     return Stack(
//       children: [
//         // Top-left circles
//         Positioned(
//           top: -100,
//           left: -150,
//           child: _BlendedCircle(color: Colors.yellow.shade600, size: 300),
//         ),
//         Positioned(
//           top: -80,
//           left: -100,
//           right: 2,
//           child: _BlendedCircle(color: Colors.red.shade400, size: 200),
//         ),
//         // Bottom-right circles
//         Positioned(
//           bottom: -100,
//           right: -150,
//           child: _BlendedCircle(color: Colors.green.shade400, size: 300),
//         ),
//         Positioned(
//           bottom: -80,
//           right: -100,
//           left: 2,
//           child: _BlendedCircle(color: Colors.blue.shade300, size: 200),
//         ),
//       ],
//     );
//   }
// }

// /// A widget that approximates the "QUIZ" logo with a tilted question mark.
// class _QuizLogo extends StatelessWidget {
//   const _QuizLogo();

//   @override
//   Widget build(BuildContext context) {
//     const double fontSize = 80.0;
//     const FontWeight fontWeight = FontWeight.w900;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center, // Better vertical alignment
//       children: [
//         // Tilted Question Mark
//         Transform.rotate(
//           angle: -math.pi / 12, // The tilt angle
//           child: Text(
//             '?',
//             style: TextStyle(
//               fontSize: fontSize + 15, // Make font slightly larger to match UIZ
//               fontWeight: fontWeight,
//               color: Colors.blue.shade700,
//             ),
//           ),
//         ),
//         // 'UIZ' with different colors using RichText
//         RichText(
//           text: TextSpan(
//             style: TextStyle(
//               fontSize: fontSize,
//               fontWeight: fontWeight,
//               fontFamily: DefaultTextStyle.of(context).style.fontFamily,
//             ),
//             children: <TextSpan>[
//               TextSpan(text: 'U', style: TextStyle(color: Colors.red.shade600)),
//               TextSpan(text: 'I', style: TextStyle(color: Colors.yellow.shade700)),
//               TextSpan(text: 'Z', style: TextStyle(color: Colors.green.shade600)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


// /// A widget to create a colored circle with a blend mode.
// class _BlendedCircle extends StatelessWidget {
//   final Color color;
//   final double size;

//   const _BlendedCircle({required this.color, required this.size});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: color.withAlpha(230), // slight transparency for better blending
//         shape: BoxShape.circle,
//         backgroundBlendMode: BlendMode.multiply, // This creates the darker intersection
//       ),
//     );
//   }
}

