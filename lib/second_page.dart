import 'package:flutter/material.dart';


import 'package:quiz_app/circles.dart';
import 'package:quiz_app/logo.dart'; 
class QuizSecondPage extends StatelessWidget {
  const QuizSecondPage({super.key});

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
                    text: 'Sign Up',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildSecondaryButton(
                    text: 'Log In',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    }
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