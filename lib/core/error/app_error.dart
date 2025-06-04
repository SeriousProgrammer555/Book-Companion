import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';

final errorProvider = StateNotifierProvider<ErrorNotifier, AppError?>((ref) {
  return ErrorNotifier();
});

class AppError {
  final String message;
  final String? code;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    this.code,
    this.type = ErrorType.unknown,
    this.originalError,
    this.stackTrace,
  });

  // Convenience constructor for simple error messages
  AppError.simple({required String message}) : this(
    message: message,
    type: ErrorType.unknown,
  );

  // Convenience constructor for auth errors
  AppError.auth({required String message, String? code}) : this(
    message: message,
    code: code,
    type: ErrorType.auth,
  );

  // Convenience constructor for validation errors
  AppError.validation({required String message, String? code}) : this(
    message: message,
    code: code,
    type: ErrorType.validation,
  );

  // Convenience constructor for network errors
  AppError.network({required String message, String? code}) : this(
    message: message,
    code: code,
    type: ErrorType.network,
  );

  // Convenience constructor for storage errors
  AppError.storage({required String message, String? code}) : this(
    message: message,
    code: code,
    type: ErrorType.storage,
  );

  @override
  String toString() => 'AppError: $message (${type.name})${code != null ? ' [$code]' : ''}';

  factory AppError.fromException(dynamic error, StackTrace? stackTrace) {
    if (error is AppError) return error;

    final type = _getErrorType(error);
    final message = _getErrorMessage(error, type);
    final code = _getErrorCode(error);

    return AppError(
      message: message,
      code: code,
      type: type,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static ErrorType _getErrorType(dynamic error) {
    if (error is NetworkException) return ErrorType.network;
    if (error is StorageException) return ErrorType.storage;
    if (error is AuthException) return ErrorType.auth;
    if (error is ValidationException) return ErrorType.validation;
    return ErrorType.unknown;
  }

  static String _getErrorMessage(dynamic error, ErrorType type) {
    if (error is AppException) return error.message;
    
    switch (type) {
      case ErrorType.network:
        return 'Network error occurred. Please check your connection.';
      case ErrorType.storage:
        return 'Storage error occurred. Please try again.';
      case ErrorType.auth:
        return 'Authentication error occurred. Please log in again.';
      case ErrorType.validation:
        return 'Invalid input. Please check your data.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  static String? _getErrorCode(dynamic error) {
    if (error is AppException) return error.code;
    return null;
  }
}

class ErrorNotifier extends StateNotifier<AppError?> {
  ErrorNotifier() : super(null);

  void setError(dynamic error, [StackTrace? stackTrace]) {
    final appError = AppError.fromException(error, stackTrace);
    state = appError;
    _logError(appError);
  }

  void clearError() {
    state = null;
  }

  void _logError(AppError error) {
    AppConfig.logger.e(
      error.toString(),
      error: error.originalError,
      stackTrace: error.stackTrace,
    );
  }
}

enum ErrorType {
  network,
  storage,
  auth,
  validation,
  unknown,
}

abstract class AppException implements Exception {
  String get message;
  String? get code;
}

class NetworkException extends AppException {
  @override
  final String message;
  @override
  final String? code;

  NetworkException(this.message, {this.code});
}

class StorageException extends AppException {
  @override
  final String message;
  @override
  final String? code;

  StorageException(this.message, {this.code});
}

class AuthException extends AppException {
  @override
  final String message;
  @override
  final String? code;

  AuthException(this.message, {this.code});
}

class ValidationException extends AppException {
  @override
  final String message;
  @override
  final String? code;

  ValidationException(this.message, {this.code});
}

// Error Widget
class ErrorView extends ConsumerWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(error.type),
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (error.code != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error Code: ${error.code}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.storage:
        return Icons.storage;
      case ErrorType.auth:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.unknown:
        return Icons.error;
    }
  }
} 