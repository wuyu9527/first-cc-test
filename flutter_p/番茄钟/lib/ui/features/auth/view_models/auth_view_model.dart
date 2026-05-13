import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/api_service.dart';
import '../../../../domain/models/user.dart';

/// 认证状态
enum AuthStatus { initial, loading, authenticated, unauthenticated }

/// 认证 UI 状态
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 认证状态管理
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _authRepo => ref.read(authRepositoryProvider);

  /// 应用启动时尝试自动登录
  Future<void> tryAutoLogin() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _authRepo.tryAutoLogin();
      state = state.copyWith(
        status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        user: user,
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// 登录
  Future<bool> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _authRepo.login(username, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: '网络连接失败，请检查网络设置',
      );
      return false;
    }
  }

  /// 注册
  Future<bool> register(
      String username, String email, String password, String? phone) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authRepo.register(username, email, password, phone);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: '网络连接失败，请检查网络设置',
      );
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    await _authRepo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider: 认证状态
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
