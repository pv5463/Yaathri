import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'exceptions.dart';

class GlobalErrorHandler {
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('Flutter Error', details.exception, details.stack);
      
      if (kReleaseMode) {
        // In release mode, send to crash reporting service
        _reportToCrashlytics(details.exception, details.stack);
      }
    };

    // Catch errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Platform Error', error, stack);
      
      if (kReleaseMode) {
        _reportToCrashlytics(error, stack);
      }
      
      return true;
    };
  }

  static void _logError(String type, Object error, StackTrace? stack) {
    developer.log(
      '$type: $error',
      error: error,
      stackTrace: stack,
      name: 'TravelSync',
    );
  }

  static void _reportToCrashlytics(Object error, StackTrace? stack) {
    // TODO: Implement Firebase Crashlytics reporting
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }

  static String getErrorMessage(Object error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is ServerException) {
      return error.message;
    } else if (error is NetworkException) {
      return 'Network connection error. Please check your internet connection.';
    } else if (error is AuthException) {
      return error.message;
    } else if (error is LocationException) {
      return error.message;
    } else if (error is MediaException) {
      return error.message;
    } else if (error is TripException) {
      return error.message;
    } else if (error is ExpenseException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Bad request. Please check your input.';
          case 401:
            return 'Authentication failed. Please login again.';
          case 403:
            return 'Access denied. You don\'t have permission for this action.';
          case 404:
            return 'Resource not found.';
          case 422:
            return 'Validation error. Please check your input.';
          case 500:
            return 'Server error. Please try again later.';
          case 503:
            return 'Service unavailable. Please try again later.';
          default:
            return 'Server error (${statusCode ?? 'Unknown'}). Please try again.';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your connection and try again.';
    }
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String title, String message) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<void> handleAsyncError(
    BuildContext context,
    Future<void> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    bool showLoading = true,
  }) async {
    if (!context.mounted) return;

    if (showLoading && loadingMessage != null) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(loadingMessage),
            ],
          ),
        ),
      );
    }

    try {
      await operation();
      
      if (showLoading && context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
      
      if (successMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
      
      if (context.mounted) {
        final errorMessage = getErrorMessage(error);
        showErrorSnackBar(context, errorMessage);
      }
      
      _logError('Async Operation Error', error, StackTrace.current);
    }
  }
}

// Custom error widget for better error display
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Network connectivity checker
class ConnectivityChecker {
  static Future<bool> hasConnection() async {
    try {
      // Simple connectivity check - in production, use connectivity_plus package
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }

  static void showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
