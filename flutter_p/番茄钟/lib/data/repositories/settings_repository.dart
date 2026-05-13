import '../../data/services/storage_service.dart';
import '../../domain/models/timer_settings.dart';

/// 设置仓储
class SettingsRepository {
  SettingsRepository({required StorageService storageService})
      : _storageService = storageService;

  final StorageService _storageService;

  /// 加载用户设置，无保存记录时返回默认值
  Future<TimerSettings> loadSettings() async {
    final json = await _storageService.loadJson(_storageService.settingsKey);
    if (json == null) return const TimerSettings();

    return TimerSettings(
      focusDurationMinutes: json['focusDurationMinutes'] as int? ?? 25,
      shortBreakDurationMinutes:
          json['shortBreakDurationMinutes'] as int? ?? 5,
      longBreakDurationMinutes:
          json['longBreakDurationMinutes'] as int? ?? 15,
      sessionsBeforeLongBreak:
          json['sessionsBeforeLongBreak'] as int? ?? 4,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
    );
  }

  /// 持久化用户设置
  Future<void> saveSettings(TimerSettings settings) async {
    await _storageService.saveJson(_storageService.settingsKey, {
      'focusDurationMinutes': settings.focusDurationMinutes,
      'shortBreakDurationMinutes': settings.shortBreakDurationMinutes,
      'longBreakDurationMinutes': settings.longBreakDurationMinutes,
      'sessionsBeforeLongBreak': settings.sessionsBeforeLongBreak,
      'soundEnabled': settings.soundEnabled,
      'notificationEnabled': settings.notificationEnabled,
    });
  }
}
