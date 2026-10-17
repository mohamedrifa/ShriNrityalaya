class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Unauthorized access. Please log in again.'})
      : super(statusCode: 401);
}

class NetworkException extends ApiException {
  const NetworkException({super.message = 'Network connection failed. Please check your internet.'});
}

class ServerException extends ApiException {
  const ServerException({super.message = 'A server error occurred. Please try again later.', super.statusCode = 500});
}

class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Requested resource not found.'})
      : super(statusCode: 404);
}
