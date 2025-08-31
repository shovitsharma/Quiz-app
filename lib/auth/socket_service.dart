import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveSocketService {
  static final LiveSocketService _instance = LiveSocketService._internal();
  factory LiveSocketService() => _instance;
  LiveSocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  /// Get connection status
  bool get isConnected => _isConnected;

  /// Connect to the live namespace - Fixed to use /live namespace
  void connect(String serverUrl) {
    // Disconnect existing connection
    disconnect();

    _socket = IO.io(
      '$serverUrl/live', // Fixed: Backend uses /live namespace
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setTimeout(30000)
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    _setupEventListeners();
    _socket?.connect();
  }

  /// Setup basic event listeners
  void _setupEventListeners() {
    _socket?.onConnect((_) {
      print("Connected to live server");
      _isConnected = true;
    });

    _socket?.onDisconnect((_) {
      print("Disconnected from live server");
      _isConnected = false;
    });

    _socket?.onConnectError((data) {
      print("Connect error: $data");
      _isConnected = false;
    });

    _socket?.onError((data) {
      print("Socket error: $data");
    });
  }

  /// Disconnect
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  /// Check if socket is connected before emitting
  bool _checkConnection() {
    if (!_isConnected || _socket == null) {
      print("Socket not connected. Please connect first.");
      return false;
    }
    return true;
  }

  /// -------------------------
  /// Player joins a session - Fixed to match backend response format
  /// -------------------------
  void joinAsPlayer({
    required String code,
    required String name,
    required Function(Map<String, dynamic>) callback,
  }) {
    if (!_checkConnection()) return;

    _socket?.emitWithAck(
      'player:join',
      {'code': code, 'name': name},
      ack: (data) {
        // Backend returns: { ok: true, sessionId, playerId, status }
        // Convert to frontend expected format
        final response = Map<String, dynamic>.from(data);
        if (response['ok'] == true) {
          callback({
            "success": true, // Convert ok to success
            "playerId": response['playerId'],
            "sessionId": response['sessionId'],
            "status": response['status'],
          });
        } else {
          callback({
            "success": false,
            "message": response['error'] ?? 'Failed to join session',
          });
        }
      },
    );
  }

  /// -------------------------
  /// Host joins a session - Fixed to match backend response format
  /// -------------------------
  void joinAsHost({
    required String sessionId,
    required String hostKey,
    required Function(Map<String, dynamic>) callback,
  }) {
    if (!_checkConnection()) return;

    _socket?.emitWithAck(
      'host:join',
      {'sessionId': sessionId, 'hostKey': hostKey},
      ack: (data) {
        // Backend returns: { ok: true, code, status, currentQuestionIndex }
        final response = Map<String, dynamic>.from(data);
        if (response['ok'] == true) {
          callback({
            "success": true, // Convert ok to success
            "code": response['code'],
            "status": response['status'],
            "currentQuestionIndex": response['currentQuestionIndex'],
          });
        } else {
          callback({
            "success": false,
            "message": response['error'] ?? 'Failed to join as host',
          });
        }
      },
    );
  }

  /// -------------------------
  /// Host starts the quiz - Fixed response format
  /// -------------------------
  void startQuiz({required Function(Map<String, dynamic>) callback}) {
    if (!_checkConnection()) return;

    _socket?.emitWithAck('host:start', null, ack: (data) {
      final response = Map<String, dynamic>.from(data);
      if (response['ok'] == true) {
        callback({
          "success": true,
          "message": "Quiz started successfully",
        });
      } else {
        callback({
          "success": false,
          "message": response['error'] ?? 'Failed to start quiz',
        });
      }
    });
  }

  /// -------------------------
  /// Host goes to next question - Fixed response format
  /// -------------------------
  void nextQuestion({required Function(Map<String, dynamic>) callback}) {
    if (!_checkConnection()) return;

    _socket?.emitWithAck('host:next', null, ack: (data) {
      final response = Map<String, dynamic>.from(data);
      if (response['ok'] == true) {
        callback({
          "success": true,
          "ended": response['ended'] ?? false,
          "message": response['ended'] == true ? "Quiz ended" : "Next question loaded",
        });
      } else {
        callback({
          "success": false,
          "message": response['error'] ?? 'Failed to go to next question',
        });
      }
    });
  }

  /// -------------------------
  /// Player submits answer - Fixed to match backend expected format
  /// -------------------------
  void submitAnswer({
    required int questionIndex,
    required int answerIndex,
    required Function(Map<String, dynamic>) callback,
  }) {
    if (!_checkConnection()) return;

    // Backend expects: { questionIndex, answerIndex }
    // No playerId needed - backend uses socket.id
    _socket?.emitWithAck(
      'player:answer',
      {
        'questionIndex': questionIndex,
        'answerIndex': answerIndex,
      },
      ack: (data) {
        final response = Map<String, dynamic>.from(data);
        if (response['ok'] == true) {
          callback({
            "success": true,
            "correct": response['correct'],
            "message": "Answer submitted successfully",
          });
        } else {
          callback({
            "success": false,
            "message": response['error'] ?? 'Failed to submit answer',
          });
        }
      },
    );
  }

  /// -------------------------
  /// Listen for live events - Fixed field names to match backend
  /// -------------------------
  void onLobbyUpdate(Function(List<Map<String, dynamic>>) callback) {
    _socket?.on('lobby:update', (data) {
      try {
        final players = (data as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        callback(players);
      } catch (e) {
        print("Error parsing lobby update: $e");
      }
    });
  }

  void onQuestionShow(Function(Map<String, dynamic>) callback) {
    _socket?.on('question:show', (data) {
      try {
        // Backend emits: { index, text, options, timeLimitSec }
        final questionData = Map<String, dynamic>.from(data);
        callback({
          "index": questionData['index'],
          "questionText": questionData['text'], // Convert text to questionText
          "options": questionData['options'],
          "timeLimitSec": questionData['timeLimitSec'],
        });
      } catch (e) {
        print("Error parsing question show: $e");
      }
    });
  }

  void onLeaderboardUpdate(Function(List<Map<String, dynamic>>) callback) {
    _socket?.on('leaderboard:update', (data) {
      try {
        final leaderboard = (data as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        callback(leaderboard);
      } catch (e) {
        print("Error parsing leaderboard update: $e");
      }
    });
  }

  void onSessionEnded(Function(Map<String, dynamic>) callback) {
    _socket?.on('session:ended', (data) {
      try {
        callback(Map<String, dynamic>.from(data));
      } catch (e) {
        print("Error parsing session ended: $e");
      }
    });
  }
}