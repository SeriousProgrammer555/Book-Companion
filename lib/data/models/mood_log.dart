class MoodLog {
  final String id;
  final String bookId;
  final String mood;
  final String note;
  final DateTime createdAt;
  final int? pageNumber;
  final String? chapter;
  final List<String> tags;

  MoodLog({
    required this.id,
    required this.bookId,
    required this.mood,
    required this.note,
    DateTime? createdAt,
    this.pageNumber,
    this.chapter,
    List<String>? tags,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    tags = tags ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'mood': mood,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'pageNumber': pageNumber,
      'chapter': chapter,
      'tags': tags,
    };
  }

  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      mood: json['mood'] as String,
      note: json['note'] as String,
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      pageNumber: json['pageNumber'] as int?,
      chapter: json['chapter'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  MoodLog copyWith({
    String? id,
    String? bookId,
    String? mood,
    String? note,
    DateTime? createdAt,
    int? pageNumber,
    String? chapter,
    List<String>? tags,
  }) {
    return MoodLog(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      pageNumber: pageNumber ?? this.pageNumber,
      chapter: chapter ?? this.chapter,
      tags: tags ?? this.tags,
    );
  }
} 