import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/models/timer_settings.dart';

/// 设置 UI 状态
class SettingsUiState {
  final TimerSettings settings;
  final bool isLoading;

  const SettingsUiState({
    this.settings = const TimerSettings(),
    this.isLoading = false,
  });

  SettingsUiState copyWith({TimerSettings? settings, bool? isLoading}) {
    return SettingsUiState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 设置状态管理
class SettingsNotifier extends Notifier<SettingsUiState> {
  @override
  SettingsUiState build() => const SettingsUiState();

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    final settings = await _repo.loadSettings();
    state = state.copyWith(settings: settings, isLoading: false);
  }

  Future<void> setFocusDuration(int minutes) => _update(
        state.settings.copyWith(focusDurationMinutes: minutes),
      );

  Future<void> setShortBreakDuration(int minutes) => _update(
        state.settings.copyWith(shortBreakDurationMinutes: minutes),
      );

  Future<void> setLongBreakDuration(int minutes) => _update(
        state.settings.copyWith(longBreakDurationMinutes: minutes),
      );

  Future<void> setSessionsBeforeLongBreak(int count) => _update(
        state.settings.copyWith(sessionsBeforeLongBreak: count),
      );

  Future<void> toggleSound() => _update(
        state.settings.copyWith(soundEnabled: !state.settings.soundEnabled),
      );

  Future<void> toggleNotification() => _update(
        state.settings.copyWith(
            notificationEnabled: !state.settings.notificationEnabled),
      );

  Future<void> _update(TimerSettings newSettings) async {
    await _repo.saveSettings(newSettings);
    state = state.copyWith(settings: newSettings);
  }
}

/// Provider: 设置状态
final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsUiState>(SettingsNotifier.new);
