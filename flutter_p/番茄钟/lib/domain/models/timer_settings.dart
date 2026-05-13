/// 番茄钟设置
class TimerSettings {
  /// 专注时长（分钟）
  final int focusDurationMinutes;

  /// 短休息时长（分钟）
  final int shortBreakDurationMinutes;

  /// 长休息时长（分钟）
  final int longBreakDurationMinutes;

  /// 触发长休息前的专注会话数
  final int sessionsBeforeLongBreak;

  /// 是否启用音效
  final bool soundEnabled;

  /// 是否启用通知
  final bool notificationEnabled;

  const TimerSettings({
    this.focusDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.notificationEnabled = true,
  });

  TimerSettings copyWith({
    int? focusDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? sessionsBeforeLongBreak,
    bool? soundEnabled,
    bool? notificationEnabled,
  }) {
    return TimerSettings(
      focusDurationMinutes:
          focusDurationMinutes ?? this.focusDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationEnabled:
          notificationEnabled ?? this.notificationEnabled,
    );
  }
}
