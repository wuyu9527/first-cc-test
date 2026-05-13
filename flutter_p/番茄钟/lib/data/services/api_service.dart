import 'package:dio/dio.dart';

/// 后台 API 通信服务
///
/// 封装 Dio HTTP 请求、JWT 令牌注入、统一响应解包。
/// 所有 API 响应都被后端包装为 {code, message, data, timestamp}，
/// 本服务自动解包，code != 0 时抛出 [ApiException]。
class ApiService {
  static const String _defaultBaseUrl = 'http://10.0.2.2:8080';

  final Dio _dio;
  String? _accessToken;

  ApiService({String? baseUrl, Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
          baseUrl: baseUrl ?? _defaultBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    _dio.interceptors.add(_createInterceptor());
  }

  /// 设置当前访问令牌（登录成功后调用）
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// 清除令牌（登出时调用）
  void clearToken() {
    _accessToken = null;
  }

  /// 请求拦截器 —— 注入 JWT + 解包响应
  Interceptor _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        try {
          final body = response.data as Map<String, dynamic>;
          final code = body['code'] as int? ?? -1;
          if (code != 0) {
            handler.reject(DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: ApiException(
                code: code,
                message: body['message'] as String? ?? '未知错误',
              ),
            ));
            return;
          }
          // 解包 data 字段
          response.data = body['data'] ?? {};
          handler.next(response);
        } catch (e) {
          if (e is DioException) {
            handler.reject(e);
          } else {
            handler.next(response);
          }
        }
      },
      onError: (error, handler) {
        if (error.type == DioExceptionType.badResponse &&
            error.response?.data is Map<String, dynamic>) {
          final body = error.response!.data as Map<String, dynamic>;
          final code = body['code'] as int? ?? -1;
          if (code != 0) {
            error = DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: ApiException(
                code: code,
                message: body['message'] as String? ?? '未知错误',
              ),
            );
          }
        }
        handler.next(error);
      },
    );
  }

  /// GET 请求
  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response =
        await _dio.get(path, queryParameters: queryParameters);
    return response.data as Map<String, dynamic>;
  }

  /// POST 请求
  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    final response = await _dio.post(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  /// PUT 请求
  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    final response = await _dio.put(path, data: data);
    return response.data as Map<String, dynamic>;
  }

  /// DELETE 请求
  Future<void> delete(String path) async {
    await _dio.delete(path);
  }

  void dispose() {
    _dio.close();
  }
}

/// API 业务异常
class ApiException implements Exception {
  final int code;
  final String message;

  const ApiException({required this.code, required this.message});

  @override
  String toString() => 'ApiException($code): $message';
}
