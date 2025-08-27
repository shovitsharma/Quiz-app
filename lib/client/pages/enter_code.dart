import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quiz_app/login.dart';

class EnterQuizCodeScreen extends StatelessWidget {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Example list of profile pictures (you can replace with your asset images)
  final List<String> _profilePictures = [
    "https://i.pravatar.cc/150?img=1",
    "https://i.pravatar.cc/150?img=2",
    "https://i.pravatar.cc/150?img=3",
    "https://i.pravatar.cc/150?img=4",
    "https://i.pravatar.cc/150?img=5",
  ];

  EnterQuizCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QuizPageTemplate(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter Quiz Code',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // --- Name Field ---
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- Quiz Code Field ---
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: 'Enter code here',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Divider(thickness: 0.3,color: Colors.black,),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  final random = Random();
                  final randomPic = _profilePictures[random.nextInt(_profilePictures.length)];

                  final playerName = _nameController.text.trim();
                  final quizCode = _codeController.text.trim();

                  if (playerName.isEmpty || quizCode.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter both name and quiz code")),
                    );
                    return;
                  }

                  // TODO: Pass playerName, randomPic, and quizCode to next screen
                  // Example:
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (_) => TakeQuizScreen(
                  //     name: playerName,
                  //     profilePic: randomPic,
                  //     code: quizCode,
                  //   ),
                  // ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  maximumSize: const Size(200, 70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: const Text(
                  'ENTER',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
