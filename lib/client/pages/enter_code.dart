import 'package:flutter/material.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/login.dart';  

class EnterQuizCodeScreen extends StatefulWidget {
  const EnterQuizCodeScreen({super.key});

  @override
  State<EnterQuizCodeScreen> createState() => _EnterQuizCodeScreenState();
}

class _EnterQuizCodeScreenState extends State<EnterQuizCodeScreen> {
  // --- STATE ---
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --- LOGIC ---

  /// Handles the entire process of a player joining a quiz.
  Future<void> _handleJoinQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final socketService = LiveSocketService.instance;
    final playerName = _nameController.text.trim();
    final quizCode = _codeController.text.trim().toUpperCase();

    try {
      // Connect to the real-time server and join the session in one step.
      socketService.connect();
        final response = await socketService.joinAsPlayer(
        code: quizCode,
        name: playerName,
      );

      if (mounted) {
        // TODO: Replace this with navigation to the PlayerLobbyScreen
        _showSuccessDialog(playerName, quizCode);
        /*
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PlayerLobbyScreen(
              sessionId: response['sessionId'],
              playerId: response['playerId'],
              playerName: playerName,
            ),
          ),
        );
        */
      }
    } on SocketException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- UI FEEDBACK ---
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Failed to Join'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  void _showSuccessDialog(String name, String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Joined Successfully!'),
        content: Text('Welcome, $name! You have joined quiz $code. Waiting for the host to start.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }


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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Join a Game', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Name cannot be empty.";
                    if (value.length < 2) return "Name must be at least 2 characters.";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    hintText: 'Enter quiz code',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Code cannot be empty.";
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleJoinQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('ENTER', style: TextStyle(fontSize: 17)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}