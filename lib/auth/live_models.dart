import 'package:flutter/foundation.dart';

@immutable
class LobbyPlayer {
  final String name;
  final int score;

  const LobbyPlayer({required this.name, required this.score});

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      name: json['name'] as String? ?? 'Unknown',
      score: json['score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
    };
  }

  LobbyPlayer copyWith({
    String? name,
    int? score,
  }) {
    return LobbyPlayer(
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LobbyPlayer &&
      other.name == name &&
      other.score == score;
  }

  @override
  int get hashCode => name.hashCode ^ score.hashCode;
}

@immutable
class LiveQuestion {
  final int index;
  final String text;
  final List<String> options;
  final int timeLimitSec;

  const LiveQuestion({
    required this.index,
    required this.text,
    required this.options,
    required this.timeLimitSec,
  });

  factory LiveQuestion.fromJson(Map<String, dynamic> json) {
    return LiveQuestion(
      index: json['index'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      options: List<String>.from(json['options'] as List<dynamic>? ?? []),
      timeLimitSec: json['timeLimitSec'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'text': text,
      'options': options,
      'timeLimitSec': timeLimitSec,
    };
  }

  LiveQuestion copyWith({
    int? index,
    String? text,
    List<String>? options,
    int? timeLimitSec,
  }) {
    return LiveQuestion(
      index: index ?? this.index,
      text: text ?? this.text,
      options: options ?? this.options,
      timeLimitSec: timeLimitSec ?? this.timeLimitSec,
    );
  }

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LiveQuestion &&
        other.index == index &&
        other.text == text &&
        listEquals(other.options, options) &&
        other.timeLimitSec == timeLimitSec;
  }

  @override
  int get hashCode =>
      index.hashCode ^
      text.hashCode ^
      options.hashCode ^
      timeLimitSec.hashCode;
}
