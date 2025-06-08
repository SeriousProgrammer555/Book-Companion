


// Remove this if you're not directly using Flutter widgets or Material-specific types
// in this file. It's often not needed in pure model files.
// import 'package:flutter/material.dart'; // <--- This is the 'Unused import'

// Define your BookStatus enum here or import it if it's in a separate file.
enum BookStatus {
  reading,
  completed,
  wishlist,
  // Add other statuses as needed
}

class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final int currentPage;
  final int totalPages;
  final BookStatus status; // Using the enum
  final DateTime? lastReadAt;
  final DateTime? createdAt;

  // Primary constructor
  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.currentPage = 0,
    this.totalPages = 0,
    this.status = BookStatus.reading,
    this.lastReadAt,
    this.createdAt,
  });

  // Factory constructor to create a Book instance from a JSON map
  factory Book.fromJson(Map<String, dynamic> json) {
    // Helper function for safe DateTime parsing
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    // THIS IS THE CRUCIAL PART:
    // A factory constructor returns an instance by calling the primary constructor
    // It DOES NOT use 'this.' for field assignment inside the factory body.
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['coverUrl'] as String?,
      currentPage: json['currentPage'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      status: BookStatus.values.firstWhere(
            (e) => e.name == (json['status'] as String? ?? 'reading'),
        orElse: () => BookStatus.reading,
      ),
      lastReadAt: parseDateTime(json['lastReadAt']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }

  // Method to convert a Book instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'status': status.name,
      'lastReadAt': lastReadAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}