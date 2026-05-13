import '../../data/repositories/history_repository.dart';
import '../../data/repositories/timer_repository.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/notification_service.dart';
import '../models/pomodoro_session.dart';
import '../models/timer_settings.dart';

/// 完成番茄钟的用例 —— 协调计时器、历史记录、音效和通知
class CompletePomodoroUseCase {
  CompletePomodoroUseCase({
    required TimerRepository timerRepository,
    required HistoryRepository historyRepository,
    required AudioService audioService,
    required NotificationService notificationService,
  })  : _timerRepository = timerRepository,
        _historyRepository = historyRepository,
        _audioService = audioService,
        _notificationService = notificationService;

  final TimerRepository _timerRepository;
  final HistoryRepository _historyRepository;
  final AudioService _audioService;
  final NotificationService _notificationService;

  /// 标记当前专注会话完成，并执行后续操作
  Future<PomodoroSession> execute({
    required String sessionId,
    required DateTime startTime,
    required int durationSeconds,
    required TimerSettings settings,
  }) async {
    // 创建完成记录
    final session = PomodoroSession(
      id: sessionId,
      startTime: startTime,
      endTime: DateTime.now(),
      durationSeconds: durationSeconds,
      type: SessionType.focus,
      isCompleted: true,
    );

    // 持久化到历史记录
    await _historyRepository.addSession(session);

    // 播放完成音效
    if (settings.soundEnabled) {
      await _audioService.playCompletionSound();
    }

    // 发送通知
    if (settings.notificationEnabled) {
      await _notificationService.showPomodoroComplete(
        title: '番茄钟完成！',
        body: '你已完成了一个 ${settings.focusDurationMinutes} 分钟的专注会话，当前共完成 ${_timerRepository.currentState.completedSessions + 1} 个',
      );
    }

    return session;
  }

  /// 开始休息阶段
  void startBreak() {
    _timerRepository.startBreak();
  }
}
