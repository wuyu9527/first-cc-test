import 'dart:convert';
import 'package:http/http.dart' as http;

/// 后台 API 通信服务
///
/// 封装 HTTP 请求、统一响应解析、JWT 令牌注入。
/// 所有 API 响应都被 [ResponseAdvice] 包装为 {code, message, data, timestamp}，
/// 本服务自动解包，code != 0 时抛出 [ApiException]。
class ApiService {
  // 开发环境地址；Android 模拟器用 10.0.2.2，iOS 模拟器/iOS 真机/Web 用实际 IP
  static const String _defaultBaseUrl = 'http://10.0.2.2:8080';

  final String baseUrl;
  final http.Client _client;
  String? _accessToken;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _defaultBaseUrl,
        _client = client ?? http.Client();

  /// 设置当前访问令牌（登录成功后调用）
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// 清除令牌（登出时调用）
  void clearToken() {
    _accessToken = null;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// 发送 GET 请求，返回解包后的 data 字段
  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? queryParams}) async {
    final uri = _buildUri(path, queryParams);
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// 发送 POST 请求，返回解包后的 data 字段
  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path);
    final response =
        await _client.post(uri, headers: _headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  /// 发送 PUT 请求，返回解包后的 data 字段
  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? body}) async {
    final uri = _buildUri(path);
    final response =
        await _client.put(uri, headers: _headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  /// 发送 DELETE 请求
  Future<void> delete(String path) async {
    final uri = _buildUri(path);
    final response = await _client.delete(uri, headers: _headers);
    _handleResponse(response);
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams != null) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// 解析统一响应格式 {code, message, data, timestamp}
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final code = body['code'] as int? ?? -1;

    if (code != 0) {
      throw ApiException(
        code: code,
        message: body['message'] as String? ?? '未知错误',
      );
    }

    // 部分接口（如 DELETE）可能无 data
    return (body['data'] as Map<String, dynamic>?) ?? {};
  }

  void dispose() {
    _client.close();
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
