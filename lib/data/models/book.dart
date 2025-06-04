
import '../../models/reading_session.dart';
// lib/models/reading_session.dart

class ReadingSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int startPage; // Define this parameter
  final int endPage;   // Define this parameter
  final String bookId;
  final int pagesRead;

  ReadingSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.startPage, // Make it required
    required this.endPage,   // Make it required
    required this.bookId,
    required this.pagesRead,
  });

  // Add toJson and fromJson methods if you need to serialize/deserialize
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'startPage': startPage,
      'endPage': endPage,
      'bookId': bookId,
      'pagesRead': pagesRead,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      // Ensure these are handled correctly in fromJson as well
      startPage: json['startPage'] as int? ?? 0, // Provide a default or handle null
      endPage: json['endPage'] as int? ?? 0,     // Provide a default or handle null
      bookId: json['bookId'] as String,
      pagesRead: json['pagesRead'] as int? ?? 0,
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final int totalPages;
  int currentPage;
  final String? coverUrl;
  final DateTime startDate;
  DateTime? finishDate;
  String status;
  bool isFavorite;
  final int? dailyGoal;
  final DateTime? lastReadDate;
  final Map<String, int> readingHistory;
  final List<String> highlights;
  final String? review;
  final double? rating;
  final List<ReadingSession> readingSessions;
  final DateTime? lastReadingStart;
  final int totalReadingTimeMinutes;
  final String? pdfPath;
  final List<int> bookmarks;
  final Map<String, int> readingStreak;
  final DateTime? lastReadingSession;
  final String? category;
  final String? language;
  final String? description;
  final String? isbn;
  final String? publisher;
  final DateTime? publishedDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.totalPages,
    this.currentPage = 0,
    this.coverUrl,
    DateTime? startDate,
    this.finishDate,
    required this.status,
    this.isFavorite = false,
    this.dailyGoal,
    this.lastReadDate,
    Map<String, int>? readingHistory,
    List<String>? highlights,
    this.review,
    this.rating,
    List<ReadingSession>? readingSessions,
    this.lastReadingStart,
    this.totalReadingTimeMinutes = 0,
    this.pdfPath,
    List<int>? bookmarks,
    Map<String, int>? readingStreak,
    this.lastReadingSession,
    this.category,
    this.language,
    this.description,
    this.isbn,
    this.publisher,
    this.publishedDate,
  }) :
    startDate = startDate ?? DateTime.now(),
    readingHistory = readingHistory ?? {},
    highlights = highlights ?? [],
    readingSessions = readingSessions ?? [],
    bookmarks = bookmarks ?? [],
    readingStreak = readingStreak ?? {};

  double get progressPercentage => (currentPage / totalPages) * 100;

  int get pagesRead => currentPage;

  int get pagesRemaining => totalPages - currentPage;

  int get daysReading {
    final end = finishDate ?? DateTime.now();
    return end.difference(startDate).inDays + 1;
  }

  double get averagePagesPerDay {
    if (daysReading == 0) return 0;
    return pagesRead / daysReading;
  }

  bool get isOnTrack {
    if (dailyGoal == null || daysReading == 0) return true;
    return averagePagesPerDay >= dailyGoal!;
  }

  int get totalReadingTime => totalReadingTimeMinutes;

  Duration get averageReadingTimePerSession {
    if (readingSessions.isEmpty) return Duration.zero;
    return Duration(minutes: totalReadingTimeMinutes ~/ readingSessions.length);
  }

  Duration get averageReadingTimePerPage {
    if (currentPage == 0) return Duration.zero;
    return Duration(minutes: totalReadingTimeMinutes ~/ currentPage);
  }
  // models/reading_session.dart

  ReadingSession? get currentSession => lastReadingStart != null
  ? ReadingSession(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  startTime: lastReadingStart!,
  endTime: DateTime.now(),
  startPage: currentPage, // Pass the current page as the start page
  endPage: currentPage,   // Pass the current page as the end page (for a session that's still active)
  bookId: id,
  pagesRead: 0, // When a session is active, pagesRead might be 0 until it's finished.
  )
      : null;

  int get currentStreak {
    if (readingStreak.isEmpty) return 0;

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final todayStr = today.toIso8601String().split('T')[0];
    final yesterdayStr = yesterday.toIso8601String().split('T')[0];

    if (readingStreak.containsKey(todayStr)) {
      return readingStreak[todayStr]!;
    } else if (readingStreak.containsKey(yesterdayStr)) {
      return readingStreak[yesterdayStr]!;
    }
    return 0;
  }

  int get longestStreak {
    if (readingStreak.isEmpty) return 0;
    return readingStreak.values.reduce((a, b) => a > b ? a : b);
  }

  Duration get averageReadingTimePerDay {
    if (daysReading == 0) return Duration.zero;
    return Duration(minutes: totalReadingTimeMinutes ~/ daysReading);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'coverUrl': coverUrl,
      'startDate': startDate.millisecondsSinceEpoch,
      'finishDate': finishDate?.millisecondsSinceEpoch,
      'status': status,
      'isFavorite': isFavorite,
      'dailyGoal': dailyGoal,
      'lastReadDate': lastReadDate?.millisecondsSinceEpoch,
      'readingHistory': readingHistory,
      'highlights': highlights,
      'review': review,
      'rating': rating,
      'readingSessions': readingSessions.map((s) => s.toJson()).toList(),
      'lastReadingStart': lastReadingStart?.millisecondsSinceEpoch,
      'totalReadingTimeMinutes': totalReadingTimeMinutes,
      'pdfPath': pdfPath,
      'bookmarks': bookmarks,
      'readingStreak': readingStreak,
      'lastReadingSession': lastReadingSession?.millisecondsSinceEpoch,
      'category': category,
      'language': language,
      'description': description,
      'isbn': isbn,
      'publisher': publisher,
      'publishedDate': publishedDate?.millisecondsSinceEpoch,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
      coverUrl: json['coverUrl'] as String?,
      startDate: json['startDate'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int)
          : DateTime.now(),
      finishDate: json['finishDate'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['finishDate'] as int)
          : null,
      status: json['status'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      dailyGoal: json['dailyGoal'] as int?,
      lastReadDate: json['lastReadDate'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['lastReadDate'] as int)
          : null,
      readingHistory: (json['readingHistory'] as Map<Object?, Object?>?)?.map(
        (key, value) => MapEntry(key.toString(), value as int),
      ) ?? {},
      highlights: (json['highlights'] as List<dynamic>?)?.cast<String>() ?? [],
      review: json['review'] as String?,
      rating: json['rating'] as double?,
      readingSessions: (json['readingSessions'] as List<dynamic>?)
          ?.map((s) => ReadingSession.fromJson(s as Map<String, dynamic>))
          .toList() ?? [],
      lastReadingStart: json['lastReadingStart'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['lastReadingStart'] as int)
          : null,
      totalReadingTimeMinutes: json['totalReadingTimeMinutes'] as int? ?? 0,
      pdfPath: json['pdfPath'] as String?,
      bookmarks: (json['bookmarks'] as List<dynamic>?)?.cast<int>() ?? [],
      readingStreak: (json['readingStreak'] as Map<Object?, Object?>?)?.map(
        (key, value) => MapEntry(key.toString(), value as int),
      ) ?? {},
      lastReadingSession: json['lastReadingSession'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['lastReadingSession'] as int)
          : null,
      category: json['category'] as String?,
      language: json['language'] as String?,
      description: json['description'] as String?,
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      publishedDate: json['publishedDate'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['publishedDate'] as int)
          : null,
    );

  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    int? totalPages,
    int? currentPage,
    String? coverUrl,
    DateTime? startDate,
    DateTime? finishDate,
    String? status,
    bool? isFavorite,
    int? dailyGoal,
    DateTime? lastReadDate,
    Map<String, int>? readingHistory,
    List<String>? highlights,
    String? review,
    double? rating,
    List<ReadingSession>? readingSessions,
    DateTime? lastReadingStart,
    int? totalReadingTimeMinutes,
    String? pdfPath,
    List<int>? bookmarks,
    Map<String, int>? readingStreak,
    DateTime? lastReadingSession,
    String? category,
    String? language,
    String? description,
    String? isbn,
    String? publisher,
    DateTime? publishedDate,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      coverUrl: coverUrl ?? this.coverUrl,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      readingHistory: readingHistory ?? this.readingHistory,
      highlights: highlights ?? this.highlights,
      review: review ?? this.review,
      rating: rating ?? this.rating,
      readingSessions: readingSessions ?? this.readingSessions,
      lastReadingStart: lastReadingStart ?? this.lastReadingStart,
      totalReadingTimeMinutes: totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      pdfPath: pdfPath ?? this.pdfPath,
      bookmarks: bookmarks ?? this.bookmarks,
      readingStreak: readingStreak ?? this.readingStreak,
      lastReadingSession: lastReadingSession ?? this.lastReadingSession,
      category: category ?? this.category,
      language: language ?? this.language,
      description: description ?? this.description,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
    );
  }
}


