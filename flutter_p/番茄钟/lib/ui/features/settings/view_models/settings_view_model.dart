import 'package:flutter/foundation.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/models/timer_settings.dart';

/// 设置页面 ViewModel
class SettingsViewmodel extends ChangeNotifier {
  SettingsViewmodel({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  TimerSettings _settings = const TimerSettings();
  bool _isLoading = false;

  TimerSettings get settings => _settings;
  bool get isLoading => _isLoading;

  /// 加载设置
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _settingsRepository.loadSettings();

    _isLoading = false;
    notifyListeners();
  }

  /// 更新专注时长
  Future<void> setFocusDuration(int minutes) async {
    _settings = _settings.copyWith(focusDurationMinutes: minutes);
    await _save();
  }

  /// 更新短休息时长
  Future<void> setShortBreakDuration(int minutes) async {
    _settings = _settings.copyWith(shortBreakDurationMinutes: minutes);
    await _save();
  }

  /// 更新长休息时长
  Future<void> setLongBreakDuration(int minutes) async {
    _settings = _settings.copyWith(longBreakDurationMinutes: minutes);
    await _save();
  }

  /// 更新长休息间隔
  Future<void> setSessionsBeforeLongBreak(int count) async {
    _settings = _settings.copyWith(sessionsBeforeLongBreak: count);
    await _save();
  }

  /// 切换音效
  Future<void> toggleSound() async {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    await _save();
  }

  /// 切换通知
  Future<void> toggleNotification() async {
    _settings = _settings.copyWith(
      notificationEnabled: !_settings.notificationEnabled,
    );
    await _save();
  }

  Future<void> _save() async {
    await _settingsRepository.saveSettings(_settings);
    notifyListeners();
  }
}
