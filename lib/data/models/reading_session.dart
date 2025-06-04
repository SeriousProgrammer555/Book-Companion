
class ReadingSession {
  final String id;
  final String bookId;
  final DateTime startTime;
  final DateTime endTime;
  final int startPage;
  final int endPage;
  final int pagesRead;
  final String mood;
  final List<String> notes;

  ReadingSession({
    required this.id,
    required this.bookId,
    required this.startTime,
    required this.endTime,
    required this.startPage,
    required this.endPage,
    required this.pagesRead,
    required this.mood,
    List<String>? notes,
  }) : notes = notes ?? [];

  Duration get duration => endTime.difference(startTime);

  int get minutesRead => duration.inMinutes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'startPage': startPage,
    'endPage': endPage,
    'pagesRead': pagesRead,
    'mood': mood,
    'notes': notes,
  };

  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
    id: json['id'] as String,
    bookId: json['bookId'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    startPage: json['startPage'] as int,
    endPage: json['endPage'] as int,
    pagesRead: json['pagesRead'] as int,
    mood: json['mood'] as String,
    notes: (json['notes'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}
