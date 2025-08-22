import 'package:flutter/material.dart';

// 1. Converted to a StatefulWidget
class QuizQuestionPage extends StatefulWidget {
  const QuizQuestionPage({super.key});

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  // 2. Added a state variable to track the selected option
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // A light grey background
      body: Stack(
        children: [
          // The red curved background element
          _buildBackground(),

          // The main content is now in a Column to allow for bottom-anchoring
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // This Expanded widget with a SingleChildScrollView allows
                  // the content to scroll if it overflows, while the buttons
                  // remain fixed at the bottom.
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32), // Top padding
                          _buildQuestionTextField(),
                          const SizedBox(height: 50),
                          // 3. Using the new stateful option widget
                          _buildOption(label: 'A.', borderColor: Colors.blue.shade700),
                          const SizedBox(height: 16),
                          _buildOption(label: 'B.', borderColor: Colors.yellow.shade700),
                          const SizedBox(height: 16),
                          _buildOption(label: 'C.', borderColor: Colors.green.shade600),
                          const SizedBox(height: 16),
                          _buildOption(label: 'D.', borderColor: Colors.red.shade600),
                        ],
                      ),
                    ),
                  ),

                  // This section contains the buttons at the bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      children: [
                        _buildNavigationButtons(),
                        const SizedBox(height: 16),
                        _buildSubmitButton(),
                      ],
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

  /// Builds the red curved shape in the background.
  Widget _buildBackground() {
    return ClipPath(
      clipper: _BackgroundClipper(),
      child: Container(
        height: 250,
        color: Colors.red.shade400,
      ),
    );
  }

  /// Builds the text field for entering the question.
  Widget _buildQuestionTextField() {
    return Container(
      height: 200, // Increased height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Corrected deprecated method
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const TextField(
        maxLines: null, // Allows for multiline input
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: 'Enter your question',
          contentPadding: EdgeInsets.all(20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  /// 4. NEW WIDGET: Builds a tappable option that changes color.
  Widget _buildOption({required String label, required Color borderColor}) {
    final bool isSelected = _selectedOption == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedOption = null; // Deselect if tapped again
          } else {
            _selectedOption = label; // Select this option
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade100 : Colors.white,
          border: Border.all(
            color: isSelected ? const Color.fromARGB(255, 58, 168, 63) : borderColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter option',
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the row with "Previous" and "Next" buttons.
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 2,
            ),
            child: const Text('Previous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 2,
            ),
            child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  /// Builds the final "Submit" button.
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54), // Full width
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 2,
      ),
      child: const Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

/// A custom clipper to create the curved background shape.
class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
