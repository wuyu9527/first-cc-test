import 'package:flutter/foundation.dart';
import '../../../../data/repositories/history_repository.dart';
import '../../../../domain/models/pomodoro_session.dart';

/// 历史记录 ViewModel
class HistoryViewmodel extends ChangeNotifier {
  HistoryViewmodel({required HistoryRepository historyRepository})
      : _historyRepository = historyRepository;

  final HistoryRepository _historyRepository;

  List<PomodoroSession> _sessions = [];
  bool _isLoading = false;

  List<PomodoroSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  /// 加载历史记录
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _sessions = await _historyRepository.loadHistory();

    _isLoading = false;
    notifyListeners();
  }

  /// 删除一条记录
  Future<void> deleteSession(String id) async {
    await _historyRepository.deleteSession(id);
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// 清空全部
  Future<void> clearAll() async {
    await _historyRepository.clearAll();
    _sessions.clear();
    notifyListeners();
  }

  /// 按天分组
  Map<String, List<PomodoroSession>> get groupedSessions {
    final groups = <String, List<PomodoroSession>>{};
    for (final session in _sessions) {
      final key =
          '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}-${session.startTime.day.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(session);
    }
    return groups;
  }

  /// 统计总专注时长（分钟）
  int get totalFocusMinutes {
    return _sessions
        .where((s) => s.type == SessionType.focus && s.isCompleted)
        .fold(0, (sum, s) => sum + s.durationSeconds ~/ 60);
  }

  /// 统计总专注次数
  int get totalFocusCount {
    return _sessions
        .where((s) => s.type == SessionType.focus && s.isCompleted)
        .length;
  }
}
