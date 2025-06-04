class ReadingSession {
  final String id;
  final String bookId;
  final DateTime startTime;
  final DateTime endTime;
  final int pagesRead;
  final String? notes;
  final String? mood; // 'happy', 'focused', 'tired', 'distracted', etc.
  final String? location; // Optional location where reading took place

  ReadingSession({
    required this.id,
    required this.bookId,
    required this.startTime,
    required this.endTime,
    required this.pagesRead,
    this.notes,
    this.mood,
    this.location,
  });

  Duration get duration => endTime.difference(startTime);

  ReadingSession copyWith({
    String? id,
    String? bookId,
    DateTime? startTime,
    DateTime? endTime,
    int? pagesRead,
    String? notes,
    String? mood,
    String? location,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pagesRead: pagesRead ?? this.pagesRead,
      notes: notes ?? this.notes,
      mood: mood ?? this.mood,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'pagesRead': pagesRead,
      'notes': notes,
      'mood': mood,
      'location': location,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      pagesRead: json['pagesRead'] as int,
      notes: json['notes'] as String?,
      mood: json['mood'] as String?,
      location: json['location'] as String?,
    );
  }
} 