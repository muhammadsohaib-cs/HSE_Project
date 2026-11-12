import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'api_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient({required SecureStorageService secureStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        secureStorage: secureStorage,
        dio: dio,
      ),
    );

    // Optional logging interceptor in debug mode
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          // print in dev
        },
      ),
    );
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
    ApiEndpoints.setBaseUrl(newUrl);
  }
}

