class Activity {
  final String id;
  final String userId;
  final String type; // e.g., 'book_added', 'reading_session', 'quote_added', etc.
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    metadata = metadata ?? {};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      metadata: (json['metadata'] as Map<Object?, Object?>?)?.map(
        (key, value) => MapEntry(key.toString(), value),
      ) ?? {},
    );
  }

  Activity copyWith({
    String? id,
    String? userId,
    String? type,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
} 