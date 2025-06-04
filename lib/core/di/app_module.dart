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

// Error handling provider
final errorProvider = StateProvider<String?>((ref) => null);

// Initialize all dependencies
Future<void> initializeDependencies({ProviderContainer? container}) async {
  try {
    if (container != null) {
      // Initialize Firebase if needed
      container.read(appInitializedProvider.notifier).state = true;
    }
  } catch (e) {
    print('Error initializing dependencies: $e');
    rethrow;
  }
} 