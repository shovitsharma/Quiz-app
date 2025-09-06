import 'dart:async';
import 'package:quiz_app/auth/live_models.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// A custom exception for Socket.IO related errors.
class SocketException implements Exception {
  final String message;
  SocketException(this.message);

  @override
  String toString() => message;
}

/// Manages the real-time connection to the game server.
/// Uses Streams to broadcast game events to the UI.
class LiveSocketService {
  // --- Singleton Setup ---
  LiveSocketService._internal();
  static final LiveSocketService instance = LiveSocketService._internal();

  // --- Private Properties ---
  IO.Socket? _socket;
  static const String _serverUrl = "https://team-01-u90d.onrender.com";

  // --- Stream Controllers ---
  // These will broadcast events to any listening widgets in your app.
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _lobbyUpdateController = StreamController<List<LobbyPlayer>>.broadcast();
  final _questionController = StreamController<LiveQuestion>.broadcast();
  final _leaderboardController = StreamController<List<LobbyPlayer>>.broadcast();
  final _quizEndedController = StreamController<Map<String, dynamic>>.broadcast();

  // --- Public Stream Getters ---
  // Your UI will listen to these streams.
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  Stream<List<LobbyPlayer>> get lobbyUpdates => _lobbyUpdateController.stream;
  Stream<LiveQuestion> get questions => _questionController.stream;
  Stream<List<LobbyPlayer>> get leaderboardUpdates => _leaderboardController.stream;
  Stream<Map<String, dynamic>> get quizEnded => _quizEndedController.stream;

  // --- Core Methods ---

  /// Connects to the server's '/live' namespace.
  void connect() {
    if (_socket?.connected ?? false) {
      print("Already connected.");
      return;
    }
    
    disconnect(); // Ensure any old socket is disposed

    _socket = IO.io(
      '$_serverUrl/live',
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    _setupEventListeners();
    _socket!.connect();
  }

  /// Disconnects from the server and cleans up resources.
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionStatusController.add(false);
  }

  void _setupEventListeners() {
    _socket!
      ..onConnect((_) {
        print("Socket connected successfully.");
        _connectionStatusController.add(true);
      })
      ..onDisconnect((_) {
        print("Socket disconnected.");
        _connectionStatusController.add(false);
      })
      ..onConnectError((data) {
        print("Connection Error: $data");
        _connectionStatusController.add(false);
      });

    // Listen for server-sent events and add them to the appropriate stream
    _socket!.on('lobby:update', (data) {
      final players = (data as List).map((p) => LobbyPlayer.fromJson(p)).toList();
      _lobbyUpdateController.add(players);
    });
    
    _socket!.on('question:show', (data) {
      final question = LiveQuestion.fromJson(data);
      _questionController.add(question);
    });

    _socket!.on('leaderboard:update', (data) {
       final leaderboard = (data as List).map((p) => LobbyPlayer.fromJson(p)).toList();
      _leaderboardController.add(leaderboard);
    });

    _socket!.on('quiz:ended', (data) {
      _quizEndedController.add(Map<String, dynamic>.from(data));
    });
  }

  /// Helper to convert ACK callbacks into a Future.
  Future<T> _emitWithAck<T>(String event, dynamic data) {
    final completer = Completer<T>();
    if (_socket?.connected != true) {
      completer.completeError(SocketException("Not connected to the server."));
      return completer.future;
    }

    _socket!.emitWithAck(event, data, ack: (response) {
      if (response['ok'] == true) {
        completer.complete(response as T);
      } else {
        completer.completeError(SocketException(response['error'] ?? 'Unknown socket error'));
      }
    });

    return completer.future;
  }
  
  // --- Actions (Emit Events) ---

  Future<Map<String, dynamic>> joinAsPlayer({required String code, required String name}) =>
      _emitWithAck('player:join', {'code': code, 'name': name});

  Future<Map<String, dynamic>> joinAsHost({required String sessionId, required String hostKey}) =>
      _emitWithAck('host:join', {'sessionId': sessionId, 'hostKey': hostKey});

  Future<Map<String, dynamic>> startQuiz() => _emitWithAck('host:start', null);
  
  Future<Map<String, dynamic>> nextQuestion() => _emitWithAck('host:next', null);

  Future<Map<String, dynamic>> submitAnswer({required int questionIndex, required int answerIndex}) =>
      _emitWithAck('player:answer', {'questionIndex': questionIndex, 'answerIndex': answerIndex});

  /// Call this when the service is no longer needed to prevent memory leaks.
  void dispose() {
    _connectionStatusController.close();
    _lobbyUpdateController.close();
    _questionController.close();
    _leaderboardController.close();
    _quizEndedController.close();
    disconnect();
  }
}