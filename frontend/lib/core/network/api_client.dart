import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'api_interceptor.dart';
import 'api_exceptions.dart';

export 'api_exceptions.dart';
export 'api_interceptor.dart';
export 'network_info.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: AppConfig.connectTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
    sendTimeout: AppConfig.sendTimeout,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  final storage = ref.read(secureStorageProvider);

  // Auth & error handling interceptor
  dio.interceptors.add(AuthInterceptor(storage));

  // Console logging
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    final res = error.response;
    if (res != null) {
      final msg = res.data is Map && res.data['message'] != null
          ? res.data['message'].toString()
          : error.message ?? 'Server error';
      if (res.statusCode == 401) {
        return UnauthorizedException(message: msg);
      } else if (res.statusCode == 404) {
        return NotFoundException(message: msg);
      } else {
        return ServerException(message: msg, statusCode: res.statusCode);
      }
    }
    return NetworkException(message: error.message ?? 'Network error');
  }
}
