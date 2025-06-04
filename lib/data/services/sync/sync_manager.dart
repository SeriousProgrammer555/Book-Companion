

import '../../models/book.dart';
import '../../models/user.dart';
import '../storage/firebase_service.dart';

class SyncManager {
  final FirebaseService _firebaseService;
  bool _isSyncing = false;

  SyncManager({
    required FirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

  bool get isSyncing => _isSyncing;

  Future<void> syncData() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;

      // Sync books
      final books = await _firebaseService.getAllBooks();
      for (final book in books) {
        await _firebaseService.updateBook(book);
      }

      // Sync users
      final users = await _firebaseService.getAllUsers();
      for (final user in users) {
        await _firebaseService.updateUser(user);
      }

      // Add more sync operations as needed
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncBook(Book book) async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      await _firebaseService.updateBook(book);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncUser(User user) async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      await _firebaseService.updateUser(user);
    } finally {
      _isSyncing = false;
    }
  }
} 