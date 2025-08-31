import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _socketService = LiveSocketService.instance;
  // ✨ We now need a subscription for the connection status
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _lobbySubscription;
  StreamSubscription? _questionSubscription;
  List<LobbyPlayer> _players = [];
  bool _isStartingQuiz = false;

  @override
  void initState() {
    super.initState();
    // ✨ First, subscribe to all events
    _subscribeToEvents();
    // ✨ Then, initiate the connection. The listener will handle the rest.
    _socketService.connect();
  }

  @override
  void dispose() {
    // ✨ Cancel the new subscription too
    _connectionSubscription?.cancel();
    _lobbySubscription?.cancel();
    _questionSubscription?.cancel();
    _socketService.disconnect();
    super.dispose();
  }

  // ✨ REFACTORED LOGIC to wait for connection
  void _subscribeToEvents() {
    // 1. Listen for the connection status itself.
    _connectionSubscription = _socketService.connectionStatus.listen((isConnected) {
      if (isConnected) {
        // 2. ONLY when connected, try to join as the host.
        print("Connection established. Now joining as host...");
        _joinAsHost();
      } else {
        print("Socket disconnected.");
      }
    });

    // These listeners will now only receive data after a successful connection.
    _lobbySubscription = _socketService.lobbyUpdates.listen((players) {
      setState(() { _players = players; });
    });

    _questionSubscription = _socketService.questions.listen((question) {
      if (mounted) {
        print("Quiz started! First question received.");
        // Navigator.of(context).pushReplacement(...);
      }
    });
  }

  Future<void> _joinAsHost() async {
    try {
      await _socketService.joinAsHost(
        sessionId: widget.sessionId,
        hostKey: widget.hostKey,
      );
      print("Successfully joined as host.");
    } on SocketException catch (e) {
      print("Error during host:join -> ${e.message}");
      if (mounted) _showErrorDialog(e.message);
    }
  }

  Future<void> _handleStartQuiz() async {
    // ... this method remains the same ...
    setState(() => _isStartingQuiz = true);
    try {
      await _socketService.startQuiz();
    } on SocketException catch (e) {
      if (mounted) _showErrorDialog(e.message);
    } finally {
      if (mounted) setState(() => _isStartingQuiz = false);
    }
  }

  void _showErrorDialog(String message) {
    // ... this method remains the same ...
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... the entire build method and its helpers remain unchanged ...
    return Scaffold(
      appBar: AppBar(title: const Text('Host Lobby')),
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