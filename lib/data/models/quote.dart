class Quote {
  final String id;
  final String bookId;
  final String text;
  final int? pageNumber;
  final String? note;
  final DateTime createdAt;
  final bool isFavorite;
  final List<String> tags;
  final String category;
  final double? rating;

  Quote({
    required this.id,
    required this.bookId,
    required this.text,
    this.pageNumber,
    this.note,
    DateTime? createdAt,
    this.isFavorite = false,
    List<String>? tags,
    this.category = 'general',
    this.rating,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    tags = tags ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'text': text,
      'pageNumber': pageNumber,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isFavorite': isFavorite,
      'tags': tags,
      'category': category,
      'rating': rating,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      text: json['text'] as String,
      pageNumber: json['pageNumber'] as int?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String? ?? 'general',
      rating: json['rating'] as double?,
    );
  }

  Quote copyWith({
    String? id,
    String? bookId,
    String? text,
    int? pageNumber,
    String? note,
    DateTime? createdAt,
    bool? isFavorite,
    List<String>? tags,
    String? category,
    double? rating,
  }) {
    return Quote(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      text: text ?? this.text,
      pageNumber: pageNumber ?? this.pageNumber,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      rating: rating ?? this.rating,
    );
  }
} 