// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static Dio? _instance;
  static const _storage = FlutterSecureStorage();

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      // 에뮬레이터: 10.0.2.2 / 실기기: PC IP 주소
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type':
                'application/json',
                'Accept': 'application/json',
                'ngrok-skip-browser-warning': 'true'},
    ));

    dio.interceptors.add(_AuthInterceptor());
    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.delete(key: 'jwt_token');
      // TODO: 로그인 화면으로 리다이렉트
    }
    handler.next(err);
  }
}