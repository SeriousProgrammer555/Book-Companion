import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/error/app_error.dart';
import '../../models/user.dart' as app_user;
import '../../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;
  final Connectivity _connectivity = Connectivity();
  
  // Constants for validation
  static const int _minPasswordLength = 8;
  static const int _maxLoginAttempts = 5;
  static const Duration _loginAttemptWindow = Duration(minutes: 15);
  static const Duration _offlineRetryDelay = Duration(seconds: 2);
  static const int _maxOfflineRetries = 3;

  AuthService({
    required FirebaseAuth auth,
    required FirebaseDatabase database,
  }) : _auth = auth,
       _database = database;

  // Get current user synchronously
  User? get currentUserSync => _auth.currentUser;

  // Get current user as stream
  Stream<User?> get currentUser => _auth.authStateChanges();

  Future<bool> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      AppConfig.logger.e('Error checking connectivity', error: e);
      return false;
    }
  }

  bool _isPasswordStrong(String password) {
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= _minPasswordLength;

    return hasUpperCase && hasLowerCase && hasDigits && hasSpecialChars && hasMinLength;
  }

  Future<void> _checkLoginAttempts(String email) async {
    if (!await _checkConnectivity()) {
      AppConfig.logger.w('Skipping login attempt check - device is offline');
      return;
    }

    try {
      final ref = _database.ref().child('loginAttempts/$email');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final count = data['count'] as int? ?? 0;
        final lastAttempt = data['lastAttempt'] as int?;
        
        if (lastAttempt != null && 
            DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastAttempt)) < _loginAttemptWindow &&
            count >= _maxLoginAttempts) {
          throw AppError(
            code: 'too-many-attempts',
            message: 'Too many login attempts. Please try again later.',
          );
        }
      }
    } catch (e) {
      if (e is AppError) rethrow;
      AppConfig.logger.w('Error checking login attempts', error: e);
    }
  }

  Future<void> _recordLoginAttempt(String email, bool success) async {
    if (!await _checkConnectivity()) {
      AppConfig.logger.w('Skipping login attempt recording - device is offline');
      return;
    }

    try {
      final ref = _database.ref().child('loginAttempts/$email');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final count = data['count'] as int? ?? 0;
        final lastAttempt = data['lastAttempt'] as int?;
        
        if (lastAttempt == null || 
            DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastAttempt)) >= _loginAttemptWindow) {
          // Reset count if window has passed
          await ref.set({
            'count': success ? 0 : 1,
            'lastAttempt': ServerValue.timestamp,
          });
        } else {
          // Increment count if within window
          await ref.update({
            'count': success ? 0 : count + 1,
            'lastAttempt': ServerValue.timestamp,
          });
        }
      } else {
        // First attempt
        await ref.set({
          'count': success ? 0 : 1,
          'lastAttempt': ServerValue.timestamp,
        });
      }
    } catch (e) {
      AppConfig.logger.w('Error recording login attempt', error: e);
    }
  }

  Future<app_user.User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!await _checkConnectivity()) {
      throw AppError(
        code: 'offline',
        message: 'No internet connection. Please check your connection and try again.',
      );
    }

    if (!_isPasswordStrong(password)) {
      throw AppError.validation(
        message: 'Password must be at least $_minPasswordLength characters long and contain uppercase, lowercase, numbers, and special characters'
      );
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AppError.auth(message: 'Failed to create user account');
      }

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Create user profile in Realtime Database
      final userRef = _database.ref().child('users/${userCredential.user!.uid}');
      await userRef.set({
        'name': name,
        'email': email,
        'createdAt': ServerValue.timestamp,
        'lastLogin': ServerValue.timestamp,
        'role': UserRole.user.name,
        'isEmailVerified': false,
        'isActive': true,
      });

      return app_user.User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: UserRole.user,
        isEmailVerified: false,
        isActive: true,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw AppError.auth(message: 'An unexpected error occurred during registration');
    }
  }

  Future<app_user.User> login({
    required String email,
    required String password,
  }) async {
    if (!await _checkConnectivity()) {
      throw AppError(
        code: 'offline',
        message: 'No internet connection. Please check your connection and try again.',
      );
    }

    await _checkLoginAttempts(email);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AppError.auth(message: 'Failed to sign in');
      }

      // Get user profile from Realtime Database
      final userRef = _database.ref().child('users/${userCredential.user!.uid}');
      final snapshot = await userRef.get();

      if (!snapshot.exists) {
        throw AppError.auth(message: 'User profile not found');
      }

      final data = snapshot.value as Map<dynamic, dynamic>;

      // Update last login
      await userRef.update({
        'lastLogin': ServerValue.timestamp,
        'isEmailVerified': userCredential.user!.emailVerified,
      });

      await _recordLoginAttempt(email, true);

      return app_user.User(
        id: userCredential.user!.uid,
        name: data['name'] as String,
        email: data['email'] as String,
        role: UserRole.values.firstWhere(
          (role) => role.name == (data['role'] as String),
          orElse: () => UserRole.user,
        ),
        isEmailVerified: userCredential.user!.emailVerified,
        isActive: data['isActive'] as bool? ?? true,
      );
    } on FirebaseAuthException catch (e) {
      await _recordLoginAttempt(email, false);
      throw _handleAuthError(e);
    } catch (e) {
      await _recordLoginAttempt(email, false);
      throw AppError.auth(message: 'An unexpected error occurred during login');
    }
  }

  AppError _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return AppError.auth(message: 'Invalid email or password');
      case 'invalid-email':
        return AppError.auth(message: 'Invalid email address');
      case 'user-disabled':
        return AppError.auth(message: 'This account has been disabled');
      case 'email-already-in-use':
        return AppError.auth(message: 'This email is already registered');
      case 'operation-not-allowed':
        return AppError.auth(message: 'Email/password accounts are not enabled');
      case 'weak-password':
        return AppError.auth(message: 'Please choose a stronger password');
      default:
        return AppError.auth(message: e.message ?? 'An authentication error occurred');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      AppConfig.clearAuthToken();
      AppConfig.logger.i('User logged out successfully');
    } catch (e) {
      throw AppError.auth(message: 'Failed to sign out');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AppError.auth(message: 'No account found with this email');
        case 'invalid-email':
          throw AppError.validation(message: 'Invalid email address');
        default:
          throw AppError.auth(message: 'Failed to send password reset email', code: e.code);
      }
    } catch (e) {
      throw AppError.auth(message: 'Failed to send password reset email');
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AppError.auth(message: 'No user is currently signed in');
    }
    if (user.emailVerified) {
      throw AppError.auth(message: 'Email is already verified');
    }
    try {
      await user.sendEmailVerification();
    } catch (e) {
      throw AppError.auth(message: 'Failed to send verification email');
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      await _database.ref().child('users/$userId').update({
        'isActive': true,
      });
    } catch (e) {
      throw AppError.auth(message: 'Failed to activate user');
    }
  }

  Future<void> deactivateUser(String userId) async {
    try {
      await _database.ref().child('users/$userId').update({
        'isActive': false,
      });
    } catch (e) {
      throw AppError.auth(message: 'Failed to deactivate user');
    }
  }

  Future<void> changeUserRole(String userId, UserRole newRole) async {
    try {
      await _database.ref().child('users/$userId').update({
        'role': newRole.name,
      });
    } catch (e) {
      throw AppError.auth(message: 'Failed to change user role');
    }
  }
} 