// models/live_models.dart

class LobbyPlayer {
  final String name;
  final int score;

  LobbyPlayer({required this.name, required this.score});

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      name: json['name'] ?? 'Unknown',
      score: json['score'] ?? 0,
    );
  }
}

class LiveQuestion {
  final int index;
  final String text;
  final List<String> options;
  final int timeLimitSec;

  LiveQuestion({
    required this.index,
    required this.text,
    required this.options,
    required this.timeLimitSec,
  });

  factory LiveQuestion.fromJson(Map<String, dynamic> json) {
    return LiveQuestion(
      index: json['index'] ?? 0,
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      timeLimitSec: json['timeLimitSec'] ?? 30,
    );
  }
}