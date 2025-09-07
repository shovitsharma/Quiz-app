import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuizLogo extends StatelessWidget {
  const QuizLogo({super.key});

  @override
  Widget build(BuildContext context) {
    const double fontSize = 80.0;
    const FontWeight fontWeight = FontWeight.w900;

    // The Column allows you to stack the image and the text logo vertically.
    return Column(
      mainAxisSize: MainAxisSize.min, // Keeps the column size compact
      children: [
        // This widget displays the image from the provided URL.
        Image.network(
          'https://res.cloudinary.com/ddkocwzxf/image/upload/v1757168979/logo-CI53zb-j_qgresx.png',
          height: 100, // You can adjust the height as needed
          // This builder shows a loading spinner while the image is downloading.
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          // This builder shows an error icon if the image fails to load.
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red, size: 50);
          },
        ),
        const SizedBox(height: 16), // Adds some space between the image and the text

        // Your original text logo remains unchanged below the image.
        Row(
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
        ),
      ],
    );
  }
}