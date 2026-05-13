import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/settings_view_model.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.viewModel});

  final SettingsViewmodel viewModel;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        if (vm.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('设置')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final s = vm.settings;
        return Scaffold(
          appBar: AppBar(title: const Text('设置')),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              _buildSectionTitle('计时设置'),
              _buildDurationTile(
                icon: Icons.timer,
                title: '专注时长',
                value: '${s.focusDurationMinutes} 分钟',
                onTap: () => _showDurationPicker(
                  context,
                  current: s.focusDurationMinutes,
                  onSelected: (v) => vm.setFocusDuration(v),
                ),
              ),
              _buildDurationTile(
                icon: Icons.free_breakfast,
                title: '短休息时长',
                value: '${s.shortBreakDurationMinutes} 分钟',
                onTap: () => _showDurationPicker(
                  context,
                  current: s.shortBreakDurationMinutes,
                  onSelected: (v) => vm.setShortBreakDuration(v),
                ),
              ),
              _buildDurationTile(
                icon: Icons.bedtime,
                title: '长休息时长',
                value: '${s.longBreakDurationMinutes} 分钟',
                onTap: () => _showDurationPicker(
                  context,
                  current: s.longBreakDurationMinutes,
                  onSelected: (v) => vm.setLongBreakDuration(v),
                ),
              ),
              _buildDurationTile(
                icon: Icons.repeat,
                title: '长休息间隔',
                value: '每 ${s.sessionsBeforeLongBreak} 次专注',
                onTap: () => _showCountPicker(
                  context,
                  current: s.sessionsBeforeLongBreak,
                  onSelected: (v) => vm.setSessionsBeforeLongBreak(v),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('通知与音效'),
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: '完成音效',
                subtitle: '番茄钟完成时播放提示音',
                value: s.soundEnabled,
                onChanged: (_) => vm.toggleSound(),
              ),
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: '推送通知',
                subtitle: '番茄钟完成时发送系统通知',
                value: s.notificationEnabled,
                onChanged: (_) => vm.toggleNotification(),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '番茄钟 v1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDurationTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryRed),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppTheme.primaryRed),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryRed,
      ),
    );
  }

  void _showDurationPicker(
    BuildContext context, {
    required int current,
    required ValueChanged<int> onSelected,
  }) {
    final options = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];
    _showPickerSheet(
      context,
      title: '选择时长',
      options: options,
      current: current,
      formatter: (v) => '$v 分钟',
      onSelected: onSelected,
    );
  }

  void _showCountPicker(
    BuildContext context, {
    required int current,
    required ValueChanged<int> onSelected,
  }) {
    final options = [2, 3, 4, 5, 6];
    _showPickerSheet(
      context,
      title: '选择间隔',
      options: options,
      current: current,
      formatter: (v) => '每 $v 次专注',
      onSelected: onSelected,
    );
  }

  void _showPickerSheet(
    BuildContext context, {
    required String title,
    required List<int> options,
    required int current,
    required String Function(int) formatter,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const Divider(height: 1),
            ...options.map((option) {
              final isSelected = option == current;
              return ListTile(
                title: Text(
                  formatter(option),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected ? AppTheme.primaryRed : AppTheme.textPrimary,
                  ),
                ),
                trailing:
                    isSelected ? const Icon(Icons.check, color: AppTheme.primaryRed) : null,
                onTap: () {
                  onSelected(option);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
