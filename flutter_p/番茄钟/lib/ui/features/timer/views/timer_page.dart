import 'package:flutter/material.dart';
import '../../../../domain/models/timer_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/circular_timer_progress.dart';
import '../view_models/timer_view_model.dart';

/// 番茄钟主页面
class TimerPage extends StatelessWidget {
  const TimerPage({super.key, required this.viewModel});

  final TimerViewmodel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('番茄钟'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () =>
                    Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildTodayProgress(context),
                const SizedBox(height: 48),
                _buildTimerRing(context),
                const SizedBox(height: 48),
                _buildControlButtons(context),
                const Spacer(),
                _buildSessionTypeSelector(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayProgress(BuildContext context) {
    final vm = viewModel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '今日已完成 ${vm.todayFocusCount} 个番茄钟',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildTimerRing(BuildContext context) {
    final vm = viewModel;
    final state = vm.timerState;
    final isRunning = vm.isRunning || vm.isPaused;

    Color ringColor;
    String statusText;
    if (state.sessionType == SessionType.focus) {
      ringColor = AppTheme.primaryRed;
      statusText = isRunning ? '专注中' : '准备开始';
    } else if (state.sessionType == SessionType.longBreak) {
      ringColor = AppTheme.primaryBlue;
      statusText = '长休息';
    } else {
      ringColor = AppTheme.primaryGreen;
      statusText = '短休息';
    }

    return CircularTimerProgress(
      progress: state.progress,
      remainingText: state.formattedRemaining,
      statusText: vm.isPaused ? '已暂停' : statusText,
      color: ringColor,
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    final vm = viewModel;

    if (vm.isIdle) {
      return ElevatedButton.icon(
        onPressed: () => vm.start(),
        icon: const Icon(Icons.play_arrow, size: 28),
        label: const Text('开始专注'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(180, 56),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (vm.isRunning)
          _buildSmallButton(
            context,
            icon: Icons.pause,
            label: '暂停',
            onTap: () => vm.pause(),
          )
        else
          _buildSmallButton(
            context,
            icon: Icons.play_arrow,
            label: '继续',
            onTap: () => vm.start(),
          ),
        const SizedBox(width: 16),
        _buildSmallButton(
          context,
          icon: Icons.stop,
          label: '重置',
          onTap: () => vm.reset(),
        ),
        const SizedBox(width: 16),
        _buildSmallButton(
          context,
          icon: Icons.skip_next,
          label: '跳过',
          onTap: () => vm.skip(),
        ),
      ],
    );
  }

  Widget _buildSmallButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: IconButton(
            icon: Icon(icon),
            onPressed: onTap,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildSessionTypeSelector(BuildContext context) {
    final vm = viewModel;
    final state = vm.timerState;
    final isBreak = state.sessionType != SessionType.focus;

    // 仅在空闲时显示切换
    if (vm.isRunning || vm.isPaused || isBreak) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTypeChip(
            context,
            icon: Icons.timer,
            label: '专注 ${vm.settings.focusDurationMinutes}min',
            isActive: true,
            color: AppTheme.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : color.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
