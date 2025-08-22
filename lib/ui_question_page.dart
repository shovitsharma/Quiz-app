import 'package:flutter/material.dart';
class QuizQuestionPage extends StatelessWidget {
  const QuizQuestionPage({super.key});

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
                          _buildOptionTextField(label: 'A.', borderColor: Colors.blue.shade700),
                          const SizedBox(height: 16),
                          _buildOptionTextField(label: 'B.', borderColor: Colors.yellow.shade700),
                          const SizedBox(height: 16),
                          _buildOptionTextField(label: 'C.', borderColor: Colors.green.shade600),
                          const SizedBox(height: 16),
                          _buildOptionTextField(label: 'D.', borderColor: Colors.red.shade600),
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
            color: Colors.black.withValues(alpha: 0.3), // Corrected deprecated method
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

  /// Builds a reusable text field for the options.
  Widget _buildOptionTextField({required String label, required Color borderColor}) {
    return TextField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20), // Increased vertical padding
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 20, right: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: 'Enter option',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: borderColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Made border radius consistent
          borderSide: BorderSide(color: borderColor, width: 2.5),
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
        minimumSize: const Size(double.infinity, 50), // Full width
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
