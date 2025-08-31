import 'package:flutter/material.dart';
import 'package:quiz_app/auth/socket_service.dart';

class TakeQuizScreen extends StatefulWidget {
  final String quizId;
  final String nickname;

  const TakeQuizScreen({
    super.key,
    required this.quizId,
    required this.nickname,
  });

  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  Map<int, int> _selectedAnswers = {};
  Map<String, dynamic>? _currentQuestion;
  bool _isLoading = true;
  String? _playerId;
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  @override
  void dispose() {
    LiveSocketService().disconnect();
    super.dispose();
  }

  void _connectSocket() {
    final socket = LiveSocketService();
    socket.connect("http://34.235.122.140:4000"); // Service handles /live namespace

    // Player joins the session
    socket.joinAsPlayer(
      code: widget.quizId,
      name: widget.nickname,
      callback: (resp) {
        if (resp["success"] == true) {
          setState(() {
            _playerId = resp["playerId"];
            _isLoading = false;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(resp["message"] ?? "Failed to join")),
            );
            Navigator.pop(context);
          }
        }
      },
    );

    // Receive next question
    socket.onQuestionShow((questionData) {
      if (!mounted) return;
      setState(() {
        _currentQuestion = questionData;
        _isLoading = false;
      });
    });

    // Listen for leaderboard updates
    socket.onLeaderboardUpdate((leaderboard) {
      if (!mounted) return;
      setState(() {
        _leaderboard = leaderboard;
      });
    });

    // Session ended, show final results
    socket.onSessionEnded((data) {
      if (!mounted) return;
      _showFinalResults(data);
    });
  }

  void _submitAnswer(int index) {
    if (_currentQuestion == null) return;

    final questionIndex = _currentQuestion!["index"];
    
    // Only allow one answer per question
    if (_selectedAnswers.containsKey(questionIndex)) {
      return;
    }
    
    setState(() {
      _selectedAnswers[questionIndex] = index;
    });

    // Submit answer via socket (backend uses socket.id as playerId)
    LiveSocketService().submitAnswer(
      questionIndex: questionIndex,
      answerIndex: index,
      callback: (response) {
        if (response["success"] == true) {
          // Show visual feedback for correct/incorrect answer
          _showAnswerFeedback(response["correct"] ?? false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response["message"] ?? "Failed to submit answer"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showAnswerFeedback(bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct!" : "Incorrect"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFinalResults(Map<String, dynamic> data) {
    // Calculate user's final position in leaderboard
    int userPosition = 0;
    int userScore = 0;
    
    for (int i = 0; i < _leaderboard.length; i++) {
      if (_leaderboard[i]['name'] == widget.nickname) {
        userPosition = i + 1;
        userScore = _leaderboard[i]['score'] ?? 0;
        break;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Score: $userScore'),
            Text('Your Position: ${userPosition > 0 ? "#$userPosition" : "Not ranked"}'),
            const SizedBox(height: 16),
            const Text('Final Leaderboard:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: _leaderboard.length,
                itemBuilder: (context, index) {
                  final player = _leaderboard[index];
                  final isCurrentUser = player['name'] == widget.nickname;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: isCurrentUser ? BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ) : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${index + 1}. ${player['name'] ?? 'Unknown'}'),
                        Text('${player['score'] ?? 0} pts'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentQuestion == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading quiz...'),
            ],
          ),
        ),
      );
    }

    final questionText = _currentQuestion!["questionText"];
    final options = List<String>.from(_currentQuestion!["options"]);
    final questionIndex = _currentQuestion!["index"];
    final selectedIndex = _selectedAnswers[questionIndex];
    final hasAnswered = _selectedAnswers.containsKey(questionIndex);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  _buildQuestionCard(questionText),
                  const SizedBox(height: 30),
                  Column(
                    children: List.generate(options.length, (index) {
                      final isSelected = selectedIndex == index;
                      final label = String.fromCharCode(65 + index);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.lightBlue.shade100
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(65, 0, 0, 0),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 12),
                                child: Text(
                                  '$label.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: hasAnswered ? null : () => _submitAnswer(index),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      options[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: hasAnswered ? Colors.grey : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: hasAnswered ? null : () => _submitAnswer(index),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? Colors.blue
                                        : (hasAnswered ? Colors.grey.shade300 : Colors.grey.shade400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  if (hasAnswered)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Answer submitted! Waiting for next question...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String questionText) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Center(
        child: Text(
          questionText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return ClipPath(
      clipper: _BackgroundClipper(),
      child: Container(height: 250, color: Colors.red.shade400),
    );
  }
}

class _BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}