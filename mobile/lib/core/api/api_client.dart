import 'package:dio/dio.dart';
import 'token_storage.dart';

/// URL del backend NestJS local. En Android emulator cambiar a 10.0.2.2.
const String kApiBaseUrl = 'http://localhost:3000';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this._tokenStorage)
      : dio = Dio(BaseOptions(baseUrl: kApiBaseUrl, connectTimeout: const Duration(seconds: 10))) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final TokenStorage _tokenStorage;

  ApiException toApiException(DioException error) {
    final data = error.response?.data;
    final message = data is Map && data['message'] != null
        ? (data['message'] is List ? data['message'].join(', ') : data['message'].toString())
        : 'No se pudo conectar con el servidor';
    return ApiException(message, statusCode: error.response?.statusCode);
  }
}
