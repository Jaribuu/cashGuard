// Base exception for the app
class AppException implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  AppException(this.message, {this.details, this.stackTrace});

  @override
  String toString() {
    return 'AppException: $message${details != null ? '\nDetails: $details' : ''}';
  }
}

// Database exceptions
class DatabaseException extends AppException {
  DatabaseException(String message, {String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}

// Local storage exceptions
class LocalStorageException extends AppException {
  LocalStorageException(String message, {String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}

// Validation exceptions
class ValidationException extends AppException {
  ValidationException(String message, {String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}

// Budget limit exceptions
class BudgetLimitException extends AppException {
  BudgetLimitException(String message, {String? details, StackTrace? stackTrace})
      : super(message, details: details, stackTrace: stackTrace);
}