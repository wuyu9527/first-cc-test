import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/history_repository.dart';
import '../../../../domain/models/pomodoro_session.dart';

/// 历史记录 UI 状态
class HistoryUiState {
  final List<PomodoroSession> sessions;
  final bool isLoading;

  const HistoryUiState({
    this.sessions = const [],
    this.isLoading = false,
  });

  HistoryUiState copyWith({
    List<PomodoroSession>? sessions,
    bool? isLoading,
  }) {
    return HistoryUiState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// 按天分组
  Map<String, List<PomodoroSession>> get groupedSessions {
    final groups = <String, List<PomodoroSession>>{};
    for (final session in sessions) {
      final key =
          '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}-${session.startTime.day.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(session);
    }
    return groups;
  }

  /// 总专注分钟数
  int get totalFocusMinutes => sessions
      .where((s) => s.type == SessionType.focus && s.isCompleted)
      .fold(0, (sum, s) => sum + s.durationSeconds ~/ 60);

  /// 总专注次数
  int get totalFocusCount => sessions
      .where((s) => s.type == SessionType.focus && s.isCompleted)
      .length;
}

/// 历史记录状态管理
class HistoryNotifier extends Notifier<HistoryUiState> {
  @override
  HistoryUiState build() => const HistoryUiState();

  HistoryRepository get _repo => ref.read(historyRepositoryProvider);

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final sessions = await _repo.loadHistory();
    state = state.copyWith(sessions: sessions, isLoading: false);
  }

  Future<void> deleteSession(String id) async {
    await _repo.deleteSession(id);
    state = state.copyWith(
      sessions: state.sessions.where((s) => s.id != id).toList(),
    );
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    state = state.copyWith(sessions: []);
  }
}

/// Provider: 历史记录状态
final historyProvider =
    NotifierProvider<HistoryNotifier, HistoryUiState>(HistoryNotifier.new);
