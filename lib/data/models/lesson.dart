class Lesson {
  final String id;
  final String bookId;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> tags;

  Lesson({
    required this.id,
    required this.bookId,
    required this.title,
    required this.content,
    DateTime? createdAt,
    List<String>? tags,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    tags = tags ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'tags': tags,
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Lesson copyWith({
    String? id,
    String? bookId,
    String? title,
    String? content,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return Lesson(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }
} 