import 'package:flutter/foundation.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/api_service.dart';
import '../../../../domain/models/user.dart';

/// 认证状态
enum AuthStatus { initial, loading, authenticated, unauthenticated }

/// 认证状态管理
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // --- Getters ---
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  /// 应用启动时尝试自动登录
  Future<void> tryAutoLogin() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      _user = await _authRepository.tryAutoLogin();
      _status =
          _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    _errorMessage = null;
    notifyListeners();
  }

  /// 登录
  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(username, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = '网络连接失败，请检查网络设置';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// 注册
  Future<bool> register(
      String username, String email, String password, String? phone) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(username, email, password, phone);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = '网络连接失败，请检查网络设置';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
