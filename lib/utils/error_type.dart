// File: lib/utils/error_type.dart

enum ErrorType {
  network,      // No internet connection
  authentication, // Auth/session errors
  server,       // Server errors (500, 404, etc.)
  unknown       // Other errors
}

class AppError {
  final ErrorType type;
  final String message;
  final String? technicalMessage; // For debugging

  AppError({
    required this.type,
    required this.message,
    this.technicalMessage,
  });

  static AppError fromException(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Check for network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return AppError(
        type: ErrorType.network,
        message: 'No internet connection. Please check your network and try again.',
        technicalMessage: error.toString(),
      );
    }
    
    // Check for authentication errors
    if (errorString.contains('jwt') ||
        errorString.contains('unauthorized') ||
        errorString.contains('invalid token') ||
        errorString.contains('session') ||
        errorString.contains('auth')) {
      return AppError(
        type: ErrorType.authentication,
        message: 'Your session has expired. Please login again.',
        technicalMessage: error.toString(),
      );
    }
    
    // Check for server errors
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('404') ||
        errorString.contains('server error')) {
      return AppError(
        type: ErrorType.server,
        message: 'Server error occurred. Please try again later.',
        technicalMessage: error.toString(),
      );
    }
    
    // Default to unknown error
    return AppError(
      type: ErrorType.unknown,
      message: 'Something went wrong. Please try again.',
      technicalMessage: error.toString(),
    );
  }
}