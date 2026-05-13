import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/core/theme/app_theme.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/auth/views/login_page.dart';
import 'ui/features/history/views/history_page.dart';
import 'ui/features/settings/views/settings_page.dart';
import 'ui/features/timer/views/timer_page.dart';

/// 番茄钟应用
class PomodoroApp extends ConsumerWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '番茄钟',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      routes: {
        '/history': (_) => const HistoryPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}

/// 认证网关 — 根据登录状态决定显示登录页或主页
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
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
        return const _MainScaffold();
      case AuthStatus.unauthenticated:
        return const LoginPage();
    }
  }
}

/// 主页面 — 包含底部导航栏和用户菜单
class _MainScaffold extends ConsumerStatefulWidget {
  const _MainScaffold();

  @override
  ConsumerState<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<_MainScaffold> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    TimerPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('番茄钟'),
        actions: [
          if (user != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle),
              onSelected: (value) {
                if (value == 'logout') _showLogoutDialog();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Text(user.email,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
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
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: '计时'),
          NavigationDestination(icon: Icon(Icons.history), label: '历史'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('确定',
                style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }
}
