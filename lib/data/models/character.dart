class Character {
  final String id;
  final String bookId;
  final String name;
  final String role;
  final String description;
  final DateTime createdAt;

  Character({
    String? id,
    required this.bookId,
    required this.name,
    required this.role,
    required this.description,
    DateTime? createdAt,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'name': name,
      'role': role,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Character copyWith({
    String? id,
    String? bookId,
    String? name,
    String? role,
    String? description,
    DateTime? createdAt,
  }) {
    return Character(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      role: role ?? this.role,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 