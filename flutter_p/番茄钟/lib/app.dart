import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/history_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/timer_repository.dart';
import 'data/services/audio_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'domain/use_cases/complete_pomodoro_use_case.dart';
import 'ui/core/theme/app_theme.dart';
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
        // 路由配置
        initialRoute: '/',
        routes: {
          '/': (_) => _buildTimerPage(),
          '/history': (_) => _buildHistoryPage(),
          '/settings': (_) => _buildSettingsPage(),
        },
      ),
    );
  }

  Widget _buildTimerPage() {
    return Builder(
      builder: (context) {
        final vm = context.watch<TimerViewmodel>();
        // 初始化 ViewModel
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.initialize();
        });
        return TimerPage(viewModel: vm);
      },
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
