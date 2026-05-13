import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/timer_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/audio_service.dart';
import 'data/services/auth_storage_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'domain/use_cases/complete_pomodoro_use_case.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/auth/views/login_page.dart';
import 'ui/features/history/view_models/history_view_model.dart';
import 'ui/features/history/views/history_page.dart';
import 'ui/features/settings/view_models/settings_view_model.dart';
import 'ui/features/settings/views/settings_page.dart';
import 'ui/features/timer/view_models/timer_view_model.dart';
import 'ui/features/timer/views/timer_page.dart';

/// 番茄钟应用
class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 服务层（单例）
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<AudioService>(create: (_) => AudioService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthStorageService>(
          create: (context) => AuthStorageService(),
        ),

        // 仓储层
        Provider<SettingsRepository>(
          create: (context) => SettingsRepository(
            storageService: context.read<StorageService>(),
          ),
        ),
        Provider<HistoryRepository>(
          create: (context) => HistoryRepository(
            storageService: context.read<StorageService>(),
          ),
        ),
        Provider<TimerRepository>(create: (_) => TimerRepository()),
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            apiService: context.read<ApiService>(),
            storageService: context.read<AuthStorageService>(),
          ),
        ),

        // 用例层
        Provider<CompletePomodoroUseCase>(
          create: (context) => CompletePomodoroUseCase(
            timerRepository: context.read<TimerRepository>(),
            historyRepository: context.read<HistoryRepository>(),
            audioService: context.read<AudioService>(),
            notificationService: context.read<NotificationService>(),
          ),
        ),

        // ViewModel 层
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<TimerViewmodel>(
          create: (context) => TimerViewmodel(
            timerRepository: context.read<TimerRepository>(),
            historyRepository: context.read<HistoryRepository>(),
            settingsRepository: context.read<SettingsRepository>(),
            completePomodoroUseCase: context.read<CompletePomodoroUseCase>(),
          ),
        ),
        ChangeNotifierProvider<HistoryViewmodel>(
          create: (context) => HistoryViewmodel(
            historyRepository: context.read<HistoryRepository>(),
          ),
        ),
        ChangeNotifierProvider<SettingsViewmodel>(
          create: (context) => SettingsViewmodel(
            settingsRepository: context.read<SettingsRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: '番茄钟',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
        routes: {
          '/history': (_) => _buildHistoryPage(),
          '/settings': (_) => _buildSettingsPage(),
        },
      ),
    );
  }

  Widget _buildHistoryPage() {
    return Builder(
      builder: (context) {
        final vm = context.watch<HistoryViewmodel>();
        return HistoryPage(viewModel: vm);
      },
    );
  }

  Widget _buildSettingsPage() {
    return Builder(
      builder: (context) {
        final vm = context.watch<SettingsViewmodel>();
        return SettingsPage(viewModel: vm);
      },
    );
  }
}

/// 认证网关 — 根据登录状态决定显示登录页或主页
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // 启动时尝试自动登录
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (_, authVm, __) {
        switch (authVm.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 64, color: AppTheme.primaryRed),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: AppTheme.primaryRed),
                  ],
                ),
              ),
            );
          case AuthStatus.authenticated:
            return _MainScaffold();
          case AuthStatus.unauthenticated:
            return const LoginPage();
        }
      },
    );
  }
}

/// 主页面 — 包含底部导航栏和用户信息
class _MainScaffold extends StatefulWidget {
  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    _TimerPageWrapper(),
    _HistoryPageWrapper(),
    _SettingsPageWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('番茄钟'),
        actions: [
          if (user != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle),
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(user.email,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'logout', child: Text('退出登录')),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: '计时'),
          NavigationDestination(icon: Icon(Icons.history), label: '历史'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthViewModel>().logout();
            },
            child: const Text('确定', style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }
}

/// Timer 页面包装器
class _TimerPageWrapper extends StatelessWidget {
  const _TimerPageWrapper();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimerViewmodel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.initialize();
    });
    return TimerPage(viewModel: vm);
  }
}

/// History 页面包装器
class _HistoryPageWrapper extends StatelessWidget {
  const _HistoryPageWrapper();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewmodel>();
    return HistoryPage(viewModel: vm);
  }
}

/// Settings 页面包装器
class _SettingsPageWrapper extends StatelessWidget {
  const _SettingsPageWrapper();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewmodel>();
    return SettingsPage(viewModel: vm);
  }
}
