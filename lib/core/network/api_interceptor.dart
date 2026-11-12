import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../constants/api_endpoints.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;

  AuthInterceptor({
    required SecureStorageService secureStorage,
    required Dio dio,
  })  : _secureStorage = secureStorage,
        _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token if not an unauthenticated endpoint
    final isAuthEndpoint = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register');

    if (!isAuthEndpoint) {
      final token = await _secureStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized for token refresh
    if (err.response?.statusCode == 401) {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt token refresh
          final response = await _dio.post(
            ApiEndpoints.refreshToken,
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccess = response.data['access_token'] as String;
            final newRefresh = response.data['refresh_token'] as String;

            await _secureStorage.saveAuthTokens(
              accessToken: newAccess,
              refreshToken: newRefresh,
            );

            // Retry original request with new token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccess';

            final retryResponse = await _dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (refreshError) {
          // Refresh failed, clear session and force login
          await _secureStorage.clearSession();
        }
      }
    }

    return handler.next(err);
  }
}

