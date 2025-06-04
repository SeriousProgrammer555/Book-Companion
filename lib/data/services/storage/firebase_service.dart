import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path/path.dart' as path;
// import '../../../models/reading_session.dart';
import '../../models/book.dart';
import '../../models/character.dart';
import '../../models/lesson.dart';
import '../../models/mood_log.dart';
import '../../models/quote.dart';
import '../../models/user.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Database references
  DatabaseReference get _booksRef => _database.ref().child('books');
  DatabaseReference get _usersRef => _database.ref().child('users');
  DatabaseReference get _quotesRef => _database.ref().child('quotes');
  DatabaseReference get _readingSessionsRef => _database.ref().child('reading_sessions');

  // User Operations
  Future<User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _usersRef.child(user.uid).get();
    if (!snapshot.exists) return null;
    
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data['id'] = snapshot.key;
    return User.fromJson(data);
  }

  Future<void> createUser(User user) async {
    await _usersRef.child(user.id).set(user.toJson());
  }

  Future<void> updateUser(User user) async {
    await _usersRef.child(user.id).update(user.toJson());
  }

  Future<void> deleteUser(String id) async {
    await _usersRef.child(id).remove();
  }

  // Book Operations
  Future<List<Book>> getAllBooks() async {
    try {
      final snapshot = await _booksRef.get();
      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final bookData = Map<String, dynamic>.from(entry.value as Map);
        bookData['id'] = entry.key;
        return Book.fromJson(bookData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load books: $e');
    }
  }

  Future<Book> getBook(String id) async {
    try {
      final snapshot = await _booksRef.child(id).get();
      if (!snapshot.exists) {
        throw Exception('Book not found');
      }
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data['id'] = snapshot.key;
      return Book.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load book: $e');
    }
  }

  Future<void> addBook(Book book) async {
    try {
      final newRef = _booksRef.push();
      await newRef.set(book.toJson());
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await _booksRef.child(book.id).update(book.toJson());
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _booksRef.child(id).remove();
      // Also delete all reading sessions for this book
      final snapshot = await _readingSessionsRef.orderByChild('bookId').equalTo(id).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        for (var key in data.keys) {
          await _readingSessionsRef.child(key).remove();
        }
      }
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // Quote Operations
  Future<List<Quote>> getQuotesForBook(String bookId) async {
    final snapshot = await _quotesRef.orderByChild('bookId').equalTo(bookId).get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final quoteData = Map<String, dynamic>.from(entry.value as Map);
      quoteData['id'] = entry.key;
      return Quote.fromJson(quoteData);
    }).toList();
  }

  Future<void> addQuote(Quote quote) async {
    await _quotesRef.child(quote.id).set(quote.toJson());
  }

  Future<void> updateQuote(Quote quote) async {
    await _quotesRef.child(quote.id).update(quote.toJson());
  }

  Future<void> deleteQuote(String id) async {
    await _quotesRef.child(id).remove();
  }

  // Reading Session Operations
  Future<List<ReadingSession>> getReadingSessions(String bookId) async {
    try {
      final snapshot = await _readingSessionsRef
          .orderByChild('bookId')
          .equalTo(bookId)
          .get();
      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final sessionData = Map<String, dynamic>.from(entry.value as Map);
        sessionData['id'] = entry.key;
        return ReadingSession.fromJson(sessionData);
      }).toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      throw Exception('Failed to load reading sessions: $e');
    }
  }

  Future<void> addReadingSession(ReadingSession session) async {
    try {
      final newRef = _readingSessionsRef.push();
      await newRef.set(session.toJson());
    } catch (e) {
      throw Exception('Failed to add reading session: $e');
    }
  }

  Future<void> updateReadingSession(ReadingSession session) async {
    try {
      await _readingSessionsRef.child(session.id).update(session.toJson());
    } catch (e) {
      throw Exception('Failed to update reading session: $e');
    }
  }

  Future<void> deleteReadingSession(String id) async {
    try {
      await _readingSessionsRef.child(id).remove();
    } catch (e) {
      throw Exception('Failed to delete reading session: $e');
    }
  }

  // Character Operations
  Future<List<Character>> getCharacters(String bookId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _database
        .ref()
        .child('users')
        .child(user.uid)
        .child('books')
        .child(bookId)
        .child('characters')
        .get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final characterData = Map<String, dynamic>.from(entry.value as Map);
      characterData['id'] = entry.key;
      return Character.fromJson(characterData);
    }).toList();
  }

  Future<void> addCharacter(String bookId, Character character) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _database
        .ref()
        .child('users')
        .child(user.uid)
        .child('books')
        .child(bookId)
        .child('characters')
        .child(character.id)
        .set(character.toJson());
  }

  // Mood Log Operations
  Future<List<MoodLog>> getMoodLogs(String bookId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _database
        .ref()
        .child('users')
        .child(user.uid)
        .child('books')
        .child(bookId)
        .child('mood_logs')
        .get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final logData = Map<String, dynamic>.from(entry.value as Map);
      logData['id'] = entry.key;
      return MoodLog.fromJson(logData);
    }).toList();
  }

  Future<void> addMoodLog(String bookId, MoodLog moodLog) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _database
        .ref()
        .child('users')
        .child(user.uid)
        .child('books')
        .child(bookId)
        .child('mood_logs')
        .child(moodLog.id)
        .set(moodLog.toJson());
  }

  // Lesson Operations
  Future<List<Lesson>> getLessons(String bookId) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _database
        .ref()
        .child('users')
        .child(user.uid)
        .child('books')
        .child(bookId)
        .child('lessons')
        .get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final lessonData = Map<String, dynamic>.from(entry.value as Map);
      lessonData['id'] = entry.key;
      return Lesson.fromJson(lessonData);
    }).toList();
  }

  Future<void> addLesson(String bookId, Lesson lesson) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _database
        .ref()
        .child('users')
        .child(user.uid)
        .child('books')
        .child(bookId)
        .child('lessons')
        .child(lesson.id)
        .set(lesson.toJson());
  }

  // File Storage Operations
  Future<String> uploadFile(String path, Uint8List bytes) async {
    final ref = _storage.ref().child(path);
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }

  // Stream operations for real-time updates
  Stream<List<Book>> watchBooks() {
    return _booksRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      return data.entries.map((entry) {
        final bookData = Map<String, dynamic>.from(entry.value as Map);
        bookData['id'] = entry.key;
        return Book.fromJson(bookData);
      }).toList();
    });
  }

  Stream<User?> watchCurrentUser() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final snapshot = await _usersRef.child(user.uid).get();
      if (!snapshot.exists) return null;
      
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data['id'] = snapshot.key;
      return User.fromJson(data);
    });
  }

  Stream<List<Quote>> watchQuotesForBook(String bookId) {
    return _quotesRef
        .orderByChild('bookId')
        .equalTo(bookId)
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return [];

          return data.entries.map((entry) {
            final quoteData = Map<String, dynamic>.from(entry.value as Map);
            quoteData['id'] = entry.key;
            return Quote.fromJson(quoteData);
          }).toList();
        });
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await _usersRef.get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final userData = Map<String, dynamic>.from(entry.value as Map);
      userData['id'] = entry.key;
      return User.fromJson(userData);
    }).toList();
  }

  Stream<Book?> getBookStream(String bookId) {
    return _booksRef
        .child(bookId)
        .onValue
        .map((event) {
          if (!event.snapshot.exists) return null;
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          data['id'] = event.snapshot.key;
          return Book.fromJson(data);
        });
  }

  // PDF Operations
  Future<Book> uploadPdfBook({
    required Book book,
    required File file,
    void Function(double)? onProgress,
  }) async {
    try {
      // Validate file exists
      if (!await file.exists()) {
        throw Exception('PDF file does not exist');
      }

      // Check file size (limit to 50MB)
      final fileSize = await file.length();
      const maxSize = 50 * 1024 * 1024; // 50MB in bytes
      if (fileSize > maxSize) {
        throw Exception('PDF file is too large. Maximum size is 50MB');
      }

      // Validate file extension
      final extension = path.extension(file.path).toLowerCase();
      if (extension != '.pdf') {
        throw Exception('Only PDF files are allowed');
      }

      // Create a unique filename to prevent collisions
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFilename = '${timestamp}_${path.basename(file.path)}';
      final storageRef = _storage.ref().child('books/${book.id}/$uniqueFilename');

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        customMetadata: {
          'uploadedBy': _auth.currentUser?.uid ?? 'unknown',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload file with progress tracking
      final uploadTask = storageRef.putFile(file, metadata);
      
      // Handle upload state changes
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed: ${snapshot.state}');
      }

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update book with PDF path
      final updatedBook = book.copyWith(
        pdfPath: downloadUrl,
        totalPages: 0, // TODO: Implement PDF page count
      );

      // Save book to Realtime Database
      await _booksRef.child(book.id).set(updatedBook.toJson());

      return updatedBook;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception('You are not authorized to upload files');
        case 'storage/canceled':
          throw Exception('Upload was canceled');
        case 'storage/unknown':
          throw Exception('An unknown error occurred during upload');
        case 'storage/invalid-checksum':
          throw Exception('File upload failed due to invalid checksum');
        case 'storage/quota-exceeded':
          throw Exception('Storage quota exceeded');
        default:
          throw Exception('Firebase storage error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }
} 