/// 计时器运行状态
enum TimerStatus {
  /// 空闲
  idle,

  /// 运行中
  running,

  /// 已暂停
  paused,
}

/// 计时器状态
class TimerState {
  final TimerStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final SessionType sessionType;
  final int completedSessions;

  const TimerState({
    this.status = TimerStatus.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.sessionType = SessionType.focus,
    this.completedSessions = 0,
  });

  /// 进度比例（0.0 ~ 1.0）
  double get progress {
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  /// 格式化的剩余时间字符串 (MM:SS)
  String get formattedRemaining {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  TimerState copyWith({
    TimerStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    SessionType? sessionType,
    int? completedSessions,
  }) {
    return TimerState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      sessionType: sessionType ?? this.sessionType,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }
}
