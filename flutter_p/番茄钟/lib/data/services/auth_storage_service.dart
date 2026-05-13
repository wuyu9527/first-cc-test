import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/auth_tokens.dart';

/// 认证令牌本地持久化服务
class AuthStorageService {
  static const _tokenKey = 'auth_tokens';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// 保存令牌到本地
  Future<void> saveTokens(AuthTokens tokens) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, jsonEncode(tokens.toJson()));
  }

  /// 读取本地令牌
  Future<AuthTokens?> loadTokens() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_tokenKey);
    if (raw == null) return null;
    try {
      return AuthTokens.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// 获取访问令牌（用于自动登录）
  Future<String?> getAccessToken() async {
    final tokens = await loadTokens();
    return tokens?.accessToken;
  }

  /// 清除本地令牌
  Future<void> clearTokens() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }
}
