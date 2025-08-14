import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:toastification/toastification.dart';

import 'token.service.dart';

// --- IMPORTANT ---
// You must define a global navigatorKey in your main.dart file
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// And assign it to your MaterialApp(navigatorKey: navigatorKey, ...)
// Adjust this import to where your navigatorKey is defined.

// --- Custom Exceptions for API Errors ---

/// A custom exception class to represent API-related errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Response? response;

  ApiException({required this.message, this.statusCode, this.response});

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}

/// Exception for when a resource is not found (404).
class NotFoundException extends ApiException {
  NotFoundException(String message, {super.response})
    : super(message: message, statusCode: 404);
}

/// Exception for authorization errors (401 or 403).
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {super.response})
    : super(message: message, statusCode: response?.statusCode ?? 401);
}

// --- Main API Service ---

class ApiService {
  final Dio _dio;

  ApiService._(this._dio);

  static final ApiService _instance = ApiService._(
    Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000/',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    ),
  );

  factory ApiService() {
    return _instance;
  }

  void initialize() {
    _dio.interceptors.addAll([
      _authInterceptor(),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      RetryInterceptor(
        dio: _dio,
        logPrint: (message) {
          // Show a toast for every retry attempt
          if (message.contains('Retrying request')) {
            _showToast(
              'Connection not available',
              ToastificationType.warning,
              description: 'Trying again...',
            );
          }
        },
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        // Only retry for connection-related errors
        retryableExtraStatuses: {
          // Add any other status codes you want to retry for
        },
      ),
    ]);
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = JwtService().token ?? '';
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (DioException err, handler) async {
        if (err.response?.statusCode == 401) {
          try {
            // final newTokens = await _refreshToken();
            // await _tokenStorage.saveTokens(
            //   token: newTokens['accessToken'],
            //   refreshToken: newTokens['refreshToken'],
            // );
            err.requestOptions.headers['Authorization'] =
                'Bearer ${['accessToken']}';
            final opts = Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            );
            final cloneReq = await _dio.request(
              err.requestOptions.path,
              options: opts,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );
            return handler.resolve(cloneReq);
          } on DioException catch (e) {
            // If refresh fails, show toast, log out, and reject the error.
            _showToast(
              'Session Expired',
              ToastificationType.error,
              description: 'Please log in again.',
            );
            // await _tokenStorage.deleteAllTokens();
            // You should have a global auth service to navigate to the login screen.
            // Example: Get.find<AuthService>().logout();
            return handler.reject(
              UnauthorizedException(
                    "Session expired. Please log in again.",
                    response: e.response,
                  )
                  as DioException,
            );
          }
        }
        // For other errors, just pass them along. They will be handled by the _handleDioError method.
        return handler.next(err);
      },
    );
  }

  // Future<Map<String, dynamic>> _refreshToken() async {
  //   final refreshToken = await _tokenStorage.getRefreshToken();
  //   if (refreshToken == null) {
  //     throw UnauthorizedException("No refresh token available.");
  //   }
  //   try {
  //     final dioRefresh = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
  //     final response = await dioRefresh.post(
  //       '/auth/refresh',
  //       data: {'refreshToken': refreshToken},
  //     );
  //     if (response.statusCode == 200 && response.data != null) {
  //       return {
  //         'access_token': response.data['access_token'],
  //         'refreshToken': response.data['refreshToken'],
  //       };
  //     } else {
  //       throw UnauthorizedException(
  //         "Failed to refresh token.",
  //         response: response,
  //       );
  //     }
  //   } on DioException catch (e) {
  //     throw UnauthorizedException(
  //       "Token refresh failed.",
  //       response: e.response,
  //     );
  //   }
  // }

  /// Handles final Dio errors after all retries, showing a toast.
  ApiException _handleDioError(DioException error) {
    // Handle connection-related errors
    if (DioExceptionTypeExtension.connectionErrorType.contains(error.type)) {
      _showToast(
        'Connection Error',
        ToastificationType.error,
        description:
            'Could not connect to the server. Please check your internet connection.',
      );
      return ApiException(
        message: "Connection timeout. Please check your internet connection.",
      );
    }

    if (error.type == DioExceptionType.cancel) {
      return ApiException(message: "Request was cancelled.");
    }

    // Handle errors with a response from the server
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      switch (statusCode) {
        case 401:
        case 403:
          return UnauthorizedException(
            "Access denied.",
            response: error.response,
          );
        case 404:
          _showToast(
            'Not Found',
            ToastificationType.error,
            description: 'The requested resource was not found.',
          );
          return NotFoundException(
            "The requested resource was not found.",
            response: error.response,
          );
        case 500:
        default:
          _showToast(
            'Server Error',
            ToastificationType.error,
            description:
                'An unexpected server error occurred. Please try again later.',
          );
          return ApiException(
            message: "Server error. Please try again later.",
            statusCode: statusCode,
            response: error.response,
          );
      }
    }

    // For any other unexpected errors
    _showToast(
      'Error',
      ToastificationType.error,
      description: 'An unexpected error occurred.',
    );
    return ApiException(message: "An unexpected error occurred.");
  }

  /// Helper method to show a toast message.
  void _showToast(
    String title,
    ToastificationType type, {
    String? description,
  }) {
    toastification.show(
      title: Text(title),
      description: description != null ? Text(description) : null,
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topRight,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // --- Public API Methods ---

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(String path, dynamic data) async {
    try {
      return await _dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(String path, dynamic data) async {
    try {
      return await _dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}

/// Extension to check for connection-related DioException types.
extension DioExceptionTypeExtension on DioExceptionType {
  static const Set<DioExceptionType> connectionErrorType = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };
}
