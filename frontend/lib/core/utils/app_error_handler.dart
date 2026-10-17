import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../network/api_exceptions.dart';

class AppErrorHandler {
  /// Converts any exception, Dio error, or raw network error into a short,
  /// user-friendly message such as "No Internet", "Internal Server Error",
  /// "Something Went Wrong", "An error occurred", etc.
  static String toShortMessage(dynamic error) {
    if (error == null) return 'Something Went Wrong';

    // 1. Handle DioException
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return 'No Internet';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              return 'Internal Server Error';
            } else if (statusCode == 404) {
              return 'Not Found';
            } else if (statusCode == 401) {
              return 'Unauthorized';
            } else if (statusCode == 403) {
              return 'Access Denied';
            } else if (statusCode == 400) {
              final data = error.response?.data;
              if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
                final msg = (data['message'] as String).trim();
                // If the backend returns a short, readable message, use it; otherwise fallback
                if (msg.length <= 40 && !msg.contains('Exception') && !msg.contains('Stack')) {
                  return msg;
                }
              }
              return 'Something Went Wrong';
            }
          }
          return 'Something Went Wrong';

        case DioExceptionType.cancel:
          return 'Request Cancelled';

        case DioExceptionType.badCertificate:
          return 'Connection Error';

        case DioExceptionType.unknown:
        default:
          if (error.error is SocketException || error.error is HttpException) {
            return 'No Internet';
          }
          return 'Something Went Wrong';
      }
    }

    // 2. Handle Custom ApiExceptions
    if (error is UnauthorizedException) {
      return 'Unauthorized';
    }
    if (error is NotFoundException) {
      return 'Not Found';
    }
    if (error is NetworkException) {
      return 'No Internet';
    }
    if (error is ServerException) {
      return 'Internal Server Error';
    }
    if (error is ApiException) {
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Internal Server Error';
      }
      return 'Something Went Wrong';
    }

    // 3. Handle System Network Exceptions
    if (error is SocketException || error is HttpException || error is TimeoutException) {
      return 'No Internet';
    }

    // 4. String-based fallback heuristics for wrapped errors
    final str = error.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('network is unreachable') ||
        str.contains('connection refused') ||
        str.contains('connection reset') ||
        str.contains('connection timed out') ||
        str.contains('no internet') ||
        str.contains('networkerror') ||
        str.contains('connection error')) {
      return 'No Internet';
    }

    if (str.contains('500') ||
        str.contains('502') ||
        str.contains('503') ||
        str.contains('504') ||
        str.contains('internal server error')) {
      return 'Internal Server Error';
    }

    if (str.contains('404') || str.contains('not found')) {
      return 'Not Found';
    }

    if (str.contains('401') || str.contains('unauthorized')) {
      return 'Unauthorized';
    }

    if (str.contains('403') || str.contains('forbidden')) {
      return 'Access Denied';
    }

    // Default short form
    return 'Something Went Wrong';
  }
}
