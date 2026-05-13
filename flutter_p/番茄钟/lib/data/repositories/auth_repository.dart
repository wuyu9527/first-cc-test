import '../../domain/models/auth_tokens.dart';
import '../../domain/models/user.dart';
import '../services/api_service.dart';
import '../services/auth_storage_service.dart';

/// 认证仓储 — 协调 API 调用与本地令牌持久化
class AuthRepository {
  final ApiService _apiService;
  final AuthStorageService _storageService;

  AuthRepository({
    required ApiService apiService,
    required AuthStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// 登录：调用 API → 保存令牌 → 获取用户信息
  Future<User> login(String username, String password) async {
    final data = await _apiService.post('/api/v1/auth/login', body: {
      'username': username,
      'password': password,
    });

    final tokens = AuthTokens.fromJson(data);
    await _storageService.saveTokens(tokens);
    _apiService.setAccessToken(tokens.accessToken);

    return await fetchCurrentUser();
  }

  /// 注册：调用 API → 返回用户信息
  Future<User> register(
      String username, String email, String password, String? phone) async {
    final data = await _apiService.post('/api/v1/users', body: {
      'username': username,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
    });

    return User.fromJson(data);
  }

  /// 尝试用本地存储的令牌自动登录
  Future<User?> tryAutoLogin() async {
    final tokens = await _storageService.loadTokens();
    if (tokens == null) return null;

    _apiService.setAccessToken(tokens.accessToken);
    try {
      return await fetchCurrentUser();
    } on ApiException catch (e) {
      if (e.code == 10002) {
        // Token 过期，尝试刷新
        try {
          final newData =
              await _apiService.post('/api/v1/auth/refresh', body: {
            'refreshToken': tokens.refreshToken,
          });
          final newTokens = AuthTokens.fromJson(newData);
          await _storageService.saveTokens(newTokens);
          _apiService.setAccessToken(newTokens.accessToken);
          return await fetchCurrentUser();
        } catch (_) {
          await _storageService.clearTokens();
          _apiService.clearToken();
          return null;
        }
      }
      return null;
    }
  }

  /// 获取当前登录用户信息
  Future<User> fetchCurrentUser() async {
    final data = await _apiService.get('/api/v1/auth/me');
    return User.fromJson(data);
  }

  /// 登出：清除本地令牌
  Future<void> logout() async {
    await _storageService.clearTokens();
    _apiService.clearToken();
  }
}
