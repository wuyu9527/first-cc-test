import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/pomodoro_session.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/history_view_model.dart';

/// 历史记录页面
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.viewModel});

  final HistoryViewmodel viewModel;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          appBar: AppBar(
            title: const Text('历史记录'),
            actions: [
              if (vm.sessions.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmClearAll(context),
                ),
            ],
          ),
          body: _buildBody(vm),
        );
      },
    );
  }

  Widget _buildBody(HistoryViewmodel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '暂无番茄钟记录',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '开始你的第一个专注会话吧',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatsBar(vm),
        Expanded(child: _buildGroupedList(vm)),
      ],
    );
  }

  Widget _buildStatsBar(HistoryViewmodel vm) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('总次数', '${vm.totalFocusCount} 次'),
          _buildStat('总时长', '${vm.totalFocusMinutes} 分钟'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryRed,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildGroupedList(HistoryViewmodel vm) {
    final groups = vm.groupedSessions;
    final keys = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final dateKey = keys[index];
        final sessions = groups[dateKey]!;
        return _buildDayGroup(dateKey, sessions, vm);
      },
    );
  }

  Widget _buildDayGroup(
    String dateKey,
    List<PomodoroSession> sessions,
    HistoryViewmodel vm,
  ) {
    final date = DateTime.parse(dateKey);
    final today = DateTime.now();
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final dateLabel = isToday ? '今天' : DateFormat('MM月dd日 EEEE', 'zh_CN').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ...sessions.map((session) => _buildSessionCard(session, vm)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSessionCard(
    PomodoroSession session,
    HistoryViewmodel vm,
  ) {
    final isFocus = session.type == SessionType.focus;
    final color = isFocus ? AppTheme.primaryRed : AppTheme.primaryGreen;
    final icon = isFocus ? Icons.timer : Icons.free_breakfast;
    final label = isFocus ? '专注' : '休息';
    final timeStr = DateFormat('HH:mm').format(session.startTime);
    final durationMin = session.durationSeconds ~/ 60;

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.deleteSession(session.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.primaryRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label · $durationMin 分钟',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${timeStr}${session.isCompleted ? " · 已完成" : " · 未完成"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有历史记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              widget.viewModel.clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('清空', style: TextStyle(color: AppTheme.primaryRed)),
          ),
        ],
      ),
    );
  }
}
