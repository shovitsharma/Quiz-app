import 'package:flutter/material.dart';

class QuizUI extends StatelessWidget {
  final String questionText;
  final int questionIndex;
  final List<String> options;
  final int? selectedAnswer;
  final bool hasAnswered;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;
  final Function(int) onSelectOption;

  const QuizUI({
    super.key,
    required this.questionText,
    required this.questionIndex,
    required this.options,
    required this.selectedAnswer,
    required this.hasAnswered,
    this.onPrevious,
    this.onNext,
    this.onSubmit,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // --- Question Card with Timer ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${questionIndex + 1}.',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // ⏱️ Timer placeholder
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "00:00",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  questionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Options ---
          ...List.generate(options.length, (index) {
            return _buildStyledOptionTile(
              text: options[index],
              index: index,
              isSelected: selectedAnswer == index,
              hasAnswered: hasAnswered,
              onTap: () => onSelectOption(index),
            );
          }),

          const Spacer(),

          // --- Bottom Buttons ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavButton("Previous", Colors.amber, Colors.black,
                  onTap: onPrevious),
              _buildNavButton("Next", Colors.green, Colors.white,
                  onTap: onNext),
            ],
          ),
          const SizedBox(height: 12),
          _buildNavButton("Submit", Colors.blue, Colors.white,
              isFullWidth: true, onTap: onSubmit),
        ],
      ),
    );
  }

  /// --- OPTION TILE (with colored borders like A,B,C,D) ---
  Widget _buildStyledOptionTile({
    required String text,
    required int index,
    required bool isSelected,
    required bool hasAnswered,
    required VoidCallback onTap,
  }) {
    final borderColors = [
      Colors.blue,
      Colors.amber,
      Colors.green,
      Colors.red,
    ];
    final color = borderColors[index % borderColors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: hasAnswered ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.6),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                '${String.fromCharCode(65 + index)}. ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- NAVIGATION BUTTON ---
  Widget _buildNavButton(String label, Color bgColor, Color textColor,
      {bool isFullWidth = false, VoidCallback? onTap}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : 140,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
