import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';
import 'auth_local_storage.dart';

/// Base API client with Dio configuration
/// Singleton managed by Riverpod (apiClientProvider with keepAlive: true)
class ApiClient {
  late final Dio _dio;
  CookieJar? _cookieJar;
  bool _initialized = false;
  Future<String?>? _refreshFuture;

  // Base URL from centralized config
  static const String _baseUrl = AppConfig.apiBaseUrl;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));
    
    // Add logging interceptor
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_AuthRefreshInterceptor(this));
  }

  /// Initialize persistent cookie jar (call this at app startup)
  Future<void> init() async {
    if (_initialized) return; // Prevent double initialization

    // dio_cookie_manager is not supported on web. Skip cookie manager setup.
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDocPath = appDocDir.path;
      _cookieJar = PersistCookieJar(
        storage: FileStorage('$appDocPath/.cookies/'),
      );

      _dio.interceptors.add(CookieManager(_cookieJar!));
      _initialized = true;
    } catch (e) {
      // Do not block app startup because of cookie storage initialization.
      if (kDebugMode) {
        print('ApiClient.init failed: $e');
      }
      _initialized = true;
    }
  }

  Dio get dio => _dio;
  
  /// Debug: Print all stored cookies for a URI
  Future<void> debugPrintCookies(Uri uri) async {
    if (_cookieJar == null) {
      if (kDebugMode) print('🍪 [DEBUG] CookieJar not initialized');
      return;
    }
    final cookies = await _cookieJar!.loadForRequest(uri);
    if (kDebugMode) {
      print('🍪 [DEBUG] Cookies for $uri:');
      for (final cookie in cookies) {
        print('  - ${cookie.name}: ${cookie.value.substring(0, 20)}...');
      }
      if (cookies.isEmpty) print('  - (no cookies)');
    }
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Clear all cookies (including refresh_token)
  void clearCookies() {
    _cookieJar?.deleteAll();
  }

  Future<String?> refreshAccessToken() {
    _refreshFuture ??= _performRefreshAccessToken();
    return _refreshFuture!.whenComplete(() => _refreshFuture = null);
  }

  Future<String?> _performRefreshAccessToken() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/auth/token/refresh');
      final body = response.data;

      final success = body?['success'] == true;
      if (!success) {
        await _clearAuthStateOnRefreshFailure();
        return null;
      }

      final tokenData = body?['data']?['tokens'] as Map<String, dynamic>?;
      final accessToken = tokenData?['accessToken'] as String?;
      final expiresIn = tokenData?['expiresIn'] as int?;

      if (accessToken == null || accessToken.isEmpty || expiresIn == null) {
        await _clearAuthStateOnRefreshFailure();
        return null;
      }

      await AuthLocalStorage.saveAccessToken(accessToken);
      await AuthLocalStorage.saveTokenExpiry(
        DateTime.now().add(Duration(seconds: expiresIn)),
      );
      setAuthToken(accessToken);

      return accessToken;
    } on DioException {
      await _clearAuthStateOnRefreshFailure();
      return null;
    }
  }

  Future<void> _clearAuthStateOnRefreshFailure() async {
    clearAuthToken();
    clearCookies();
    await AuthLocalStorage.clearAuthData();
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

class _AuthRefreshInterceptor extends QueuedInterceptor {
  final ApiClient _apiClient;

  _AuthRefreshInterceptor(this._apiClient);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final request = err.requestOptions;

    if (statusCode != 401 || !_shouldTryRefresh(request)) {
      handler.next(err);
      return;
    }

    final newToken = await _apiClient.refreshAccessToken();
    if (newToken == null) {
      handler.next(err);
      return;
    }

    try {
      final retryHeaders = Map<String, dynamic>.from(request.headers);
      retryHeaders['Authorization'] = 'Bearer $newToken';

      final retryOptions = Options(
        method: request.method,
        headers: retryHeaders,
        responseType: request.responseType,
        contentType: request.contentType,
        receiveDataWhenStatusError: request.receiveDataWhenStatusError,
        followRedirects: request.followRedirects,
        validateStatus: request.validateStatus,
        receiveTimeout: request.receiveTimeout,
        sendTimeout: request.sendTimeout,
        extra: {
          ...request.extra,
          '_retryAfterRefresh': true,
        },
      );

      final response = await _apiClient.dio.request<dynamic>(
        request.path,
        data: request.data,
        queryParameters: request.queryParameters,
        options: retryOptions,
        cancelToken: request.cancelToken,
        onReceiveProgress: request.onReceiveProgress,
        onSendProgress: request.onSendProgress,
      );

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldTryRefresh(RequestOptions request) {
    if (request.extra['_retryAfterRefresh'] == true) {
      return false;
    }

    const excludedPaths = {
      '/auth/token/refresh',
      '/auth/signin',
      '/auth/authority/signin',
      '/auth/signup',
      '/auth/verify',
      '/auth/resend-code',
      '/auth/password/forgot',
    };

    return !excludedPaths.contains(request.path);
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ REQUEST: ${options.method} ${options.uri}');
      print('│ Headers: ${options.headers}');
      if (options.data != null) {
        print('│ Body: ${options.data}');
      }
      print('└─────────────────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
      print('│ Data: ${response.data}');
      print('└─────────────────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ ERROR: ${err.type} ${err.requestOptions.uri}');
      print('│ Message: ${err.message}');
      print('│ Response: ${err.response?.data}');
      print('└─────────────────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}

/// API Exception for handling errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;
    dynamic data = error.response?.data;

    // Try to extract message from response
    if (data is Map<String, dynamic> && data['message'] != null) {
      message = data['message'];
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          message = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          message = 'Receive timeout';
          break;
        case DioExceptionType.badResponse:
          message = _getMessageFromStatusCode(statusCode);
          break;
        case DioExceptionType.cancel:
          message = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection';
          break;
        default:
          message = 'Something went wrong';
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  static String _getMessageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation error';
      case 500:
        return 'Internal server error';
      default:
        return 'Something went wrong';
    }
  }

  @override
  String toString() => message;
}
