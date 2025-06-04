
import 'package:book_traders/data/models/user_role.dart';

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? profilePictureUrl;
  final Map<String, dynamic> preferences;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role = UserRole.user,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastLoginAt,
    this.isActive = true,
    this.profilePictureUrl,
    Map<String, dynamic>? preferences,
    this.isEmailVerified = false,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now(),
    preferences = preferences ?? {};

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'isActive': isActive,
      'profilePictureUrl': profilePictureUrl,
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == (json['role'] as String),
        orElse: () => UserRole.user,
      ),
      createdAt: json['createdAt'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      updatedAt: json['updatedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt'] as int)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      preferences: (json['preferences'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ?? {},
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isActive,
    String? profilePictureUrl,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
} 