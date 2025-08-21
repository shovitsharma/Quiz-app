import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuizLogo extends StatelessWidget {
  const QuizLogo({super.key});

  @override
  Widget build(BuildContext context) {
    const double fontSize = 80.0;
    const FontWeight fontWeight = FontWeight.w900;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Tilted Question Mark
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
        // 'UIZ'
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
