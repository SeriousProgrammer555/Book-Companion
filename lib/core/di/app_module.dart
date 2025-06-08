import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';

import '../../data/services/auth/auth_service.dart';
import '../../data/services/storage/firebase_service.dart';
import '../../data/services/storage/quote_service.dart';

// Core providers
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: firebase_auth.FirebaseAuth.instance,
    database: FirebaseDatabase.instance,
  );
});

final quoteServiceProvider = Provider<QuoteService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return QuoteService(firebaseService);
});

// Feature-specific providers will be added here
// Example:
// final bookRepositoryProvider = Provider<BookRepository>((ref) {
//   final firebaseService = ref.watch(firebaseServiceProvider);
//   return BookRepositoryImpl(firebaseService);
// });

// State providers
final appInitializedProvider = StateProvider<bool>((ref) => false);

// Initialize all dependencies
Future<bool> initializeDependencies(ProviderContainer container) async {
  try {
    // Initialize Firebase
    final firebaseService = FirebaseService();
    final authService = AuthService(
      auth: firebase_auth.FirebaseAuth.instance,
      database: FirebaseDatabase.instance,
    );

    // Verify Firebase is initialized and auth service is ready
    if (firebase_auth.FirebaseAuth.instance.currentUser != null) {
      await authService.getCurrentUser();
    }

    // Mark app as initialized
    container.read(appInitializedProvider.notifier).state = true;
    
    return true;
  } catch (e) {
    print('Error initializing dependencies: $e');
    // Keep app as not initialized on error
    container.read(appInitializedProvider.notifier).state = false;
    rethrow;
  }
} 