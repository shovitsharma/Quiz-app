import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/auth/socket_service.dart';
import 'package:quiz_app/client/pages/loading_quiz.dart';
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
      // --- IMPROVED CONNECTION LOGIC ---
      // 1. Create a Completer to await the connection status.
      final connectionCompleter = Completer<void>();
      StreamSubscription? connectionSub;

      // Listen for the connection stream to emit 'true'.
      connectionSub = socketService.connectionStatus.listen((isConnected) {
        if (isConnected && !connectionCompleter.isCompleted) {
          connectionCompleter.complete();
          connectionSub?.cancel(); // Clean up the listener once connected.
        }
      });

      // 2. Initiate the connection.
      socketService.connect();

      // 3. Wait for the connection to complete, with a 10-second timeout.
      await connectionCompleter.future.timeout(const Duration(seconds: 10));

      // 4. Now that we are connected, join the game.
      final response = await socketService.joinAsPlayer(
        code: quizCode,
        name: playerName,
      );

      // 5. Navigate to the lobby screen on success.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PlayerLobbyScreen(
              sessionId: response['sessionId'],
              playerId: response['playerId'],
              playerName: playerName,
              quizCode: quizCode,
            ),
          ),
        );
      }
    } on TimeoutException {
       if (mounted) _showErrorDialog("Connection timed out. Please check your internet and try again.");
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