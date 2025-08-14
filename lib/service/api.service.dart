import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000/',
      contentType: "application/json",
      validateStatus: (_) => true,
    ),
  );

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionError) {
            _showToast(
              'Connection Error',
              ToastificationType.error,
              description:
                  'The Server is Unreachable Check your network connection ${error.toString()}',
            );
          }
          return handler.next(error);
        },
        onRequest: (options, handler) {
          // Retrieve the token from SharedPreferences

          final token = JwtService().token ?? '';
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future post(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

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
