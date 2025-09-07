import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/after_startquiz.dart';
import 'package:quiz_app/auth/live_models.dart';
import 'package:quiz_app/auth/socket_service.dart';

class HostLobbyScreen extends StatefulWidget {
  final String sessionId;
  final String hostKey;
  final String joinCode;

  const HostLobbyScreen({
    super.key,
    required this.sessionId,
    required this.hostKey,
    required this.joinCode,
  });

  @override
  State<HostLobbyScreen> createState() => _HostLobbyScreenState();
}

class _HostLobbyScreenState extends State<HostLobbyScreen> {
  // --- STATE ---
  final _socketService = LiveSocketService.instance;
  StreamSubscription? _lobbySubscription;
  StreamSubscription? _questionSubscription;
  List<LobbyPlayer> _players = [];
  bool _isStartingQuiz = false;

  @override
  void initState() {
    super.initState();
    _connectAndJoin(); // FIX 1: Connect to the server when the screen loads

    // Listen for players joining/leaving the lobby
    _lobbySubscription = _socketService.lobbyUpdates.listen((players) {
      if (mounted) {
        setState(() {
          _players = players;
        });
      }
    });

    // Listen for the first question event to navigate
    _questionSubscription = _socketService.questions.listen((firstQuestion) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HostQuestionScreen(initialQuestion: firstQuestion),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // Clean up all subscriptions to prevent memory leaks
    _lobbySubscription?.cancel();
    _questionSubscription?.cancel();
    super.dispose();
  }

  // --- LOGIC ---
  Future<void> _connectAndJoin() async {
    final socketService = LiveSocketService.instance;
    final connectionCompleter = Completer<void>();

    StreamSubscription? connectionSub;
    connectionSub = socketService.connectionStatus.listen((isConnected) {
      if (isConnected && !connectionCompleter.isCompleted) {
        connectionCompleter.complete();
        connectionSub?.cancel();
      }
    });

    socketService.connect();

    try {
      await connectionCompleter.future.timeout(const Duration(seconds: 10));
      await socketService.joinAsHost(
        sessionId: widget.sessionId,
        hostKey: widget.hostKey,
      );
    } on TimeoutException {
      if (mounted) _showErrorDialog("Could not connect to the server in time. Please try again.");
    } on SocketException catch (e) {
      if (mounted) _showErrorDialog(e.message);
    } finally {
      connectionSub.cancel();
    }
  }

  /// Sends the command to the server to start the quiz for all players.
  Future<void> _handleStartQuiz() async {
    setState(() => _isStartingQuiz = true);
    try {
      await _socketService.startQuiz();
      // FIX 2: Navigation is now handled by the listener in initState.
      // The line below has been REMOVED.
      // Navigator.of(context).pushReplacement(...);

    } on SocketException catch (e) {
      if (mounted) {
        _showErrorDialog(e.message);
        setState(() => _isStartingQuiz = false);
      }
    }
  }
  
  // --- UI FEEDBACK ---
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Lobby'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildJoinCodeCard(),
              const SizedBox(height: 24),
              _buildPlayerList(),
              const SizedBox(height: 24),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildJoinCodeCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Players use this code to join:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.joinCode,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.grey),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.joinCode));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code copied!")));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerList() {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Players in Lobby (${_players.length})",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _players.isEmpty
                  ? const Center(child: Text("Waiting for players...", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(_players[index].name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton.icon(
      icon: _isStartingQuiz ? Container() : const Icon(Icons.play_arrow),
      label: _isStartingQuiz
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
          : const Text("Start Quiz"),
      // FIX 3: The button now correctly checks the player list
      onPressed: (_players.isEmpty || _isStartingQuiz) ? null : _handleStartQuiz,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        disabledBackgroundColor: Colors.grey.shade600,
      ),
    );
  }
}