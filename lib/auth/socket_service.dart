import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveSocketService {
  static final LiveSocketService _instance = LiveSocketService._internal();
  factory LiveSocketService() => _instance;
  LiveSocketService._internal();

  IO.Socket? _socket;

  /// Connect to the live namespace
  void connect(String serverUrl) {
    _socket = IO.io(
      '$serverUrl/live',
      IO.OptionBuilder()
          .setTransports(['websocket']) // use websocket only
          .disableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      print("Connected to live server");
    });

    _socket?.onDisconnect((_) {
      print("Disconnected from live server");
    });

    _socket?.onConnectError((data) {
      print("Connect error: $data");
    });

    _socket?.onError((data) {
      print("Socket error: $data");
    });

    _socket?.connect();
  }

  /// Disconnect
  void disconnect() {
    _socket?.disconnect();
  }

  /// -------------------------
  /// Player joins a session
  /// -------------------------
  void joinAsPlayer({
    required String code,
    required String name,
    required Function(Map<String, dynamic>) callback,
  }) {
    _socket?.emitWithAck(
      'player:join',
      {'code': code, 'name': name},
      ack: (data) => callback(Map<String, dynamic>.from(data)),
    );
  }

  /// -------------------------
  /// Host joins a session
  /// -------------------------
  void joinAsHost({
    required String sessionId,
    required String hostKey,
    required Function(Map<String, dynamic>) callback,
  }) {
    _socket?.emitWithAck(
      'host:join',
      {'sessionId': sessionId, 'hostKey': hostKey},
      ack: (data) => callback(Map<String, dynamic>.from(data)),
    );
  }

  /// -------------------------
  /// Host starts the quiz
  /// -------------------------
  void startQuiz({required Function(Map<String, dynamic>) callback}) {
    _socket?.emitWithAck('host:start', null, ack: (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  /// -------------------------
  /// Host goes to next question
  /// -------------------------
  void nextQuestion({required Function(Map<String, dynamic>) callback}) {
    _socket?.emitWithAck('host:next', null, ack: (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  /// -------------------------
  /// Player submits answer
  /// -------------------------
  void submitAnswer({
    required int questionIndex,
    required int answerIndex,
    required Function(Map<String, dynamic>) callback,
  }) {
    _socket?.emitWithAck(
      'player:answer',
      {'questionIndex': questionIndex, 'answerIndex': answerIndex},
      ack: (data) => callback(Map<String, dynamic>.from(data)),
    );
  }

  /// -------------------------
  /// Listen for live events
  /// -------------------------
  void onLobbyUpdate(Function(List<Map<String, dynamic>>) callback) {
    _socket?.on('lobby:update', (data) {
      final players = (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      callback(players);
    });
  }

  void onQuestionShow(Function(Map<String, dynamic>) callback) {
    _socket?.on('question:show', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  void onLeaderboardUpdate(Function(List<Map<String, dynamic>>) callback) {
    _socket?.on('leaderboard:update', (data) {
      final leaderboard = (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
      callback(leaderboard);
    });
  }

  void onSessionEnded(Function(Map<String, dynamic>) callback) {
    _socket?.on('session:ended', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }
}
