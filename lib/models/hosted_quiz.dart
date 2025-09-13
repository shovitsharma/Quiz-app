/// Represents a single quiz created by a host, fetched from the server.
class HostedQuiz {
  final String id; // The unique ID from the database
  final String name;
  final String quizCode;
  final DateTime date;

  HostedQuiz({
    required this.id,
    required this.name,
    required this.quizCode,
    required this.date,
  });

  /// A factory constructor to create a HostedQuiz instance from JSON.
  factory HostedQuiz.fromJson(Map<String, dynamic> json) {
    return HostedQuiz(
      id: json['_id'] ?? '', // MongoDB typically uses '_id'
      name: json['name'] ?? 'Untitled Quiz',
      quizCode: json['quizCode'] ?? 'N/A',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}
