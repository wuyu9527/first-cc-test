import '../../data/services/storage_service.dart';
import '../../domain/models/pomodoro_session.dart';

/// 历史记录仓储
class HistoryRepository {
  HistoryRepository({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  /// 加载全部历史记录，按时间倒序
  Future<List<PomodoroSession>> loadHistory() async {
    final jsonList =
        await _storageService.loadJsonList(_storageService.historyKey);
    return jsonList
        .map((json) => PomodoroSession.fromJson(json))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// 新增一条完成记录
  Future<void> addSession(PomodoroSession session) async {
    final history = await loadHistory();
    history.insert(0, session);
    await _saveAll(history);
  }

  /// 删除指定记录
  Future<void> deleteSession(String id) async {
    final history = await loadHistory();
    history.removeWhere((s) => s.id == id);
    await _saveAll(history);
  }

  /// 清空全部历史
  Future<void> clearAll() async {
    await _storageService.saveJsonList(_storageService.historyKey, []);
  }

  /// 获取今日完成的专注会话数
  Future<int> getTodayFocusCount() async {
    final history = await loadHistory();
    final today = DateTime.now();
    return history
        .where((s) =>
            s.type == SessionType.focus &&
            s.isCompleted &&
            s.startTime.year == today.year &&
            s.startTime.month == today.month &&
            s.startTime.day == today.day)
        .length;
  }

  /// 批量保存
  Future<void> _saveAll(List<PomodoroSession> sessions) async {
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _storageService.saveJsonList(_storageService.historyKey, jsonList);
  }
}
