import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/history_repository.dart';
import '../../../../data/repositories/timer_repository.dart';
import '../../../../domain/models/timer_settings.dart';
import '../../../../domain/models/timer_state.dart';
import '../../../../domain/use_cases/complete_pomodoro_use_case.dart';

/// 计时器 UI 状态
class TimerUiState {
  final TimerState timerState;
  final TimerSettings settings;
  final int todayFocusCount;

  const TimerUiState({
    this.timerState = const TimerState(),
    this.settings = const TimerSettings(),
    this.todayFocusCount = 0,
  });

  TimerUiState copyWith({
    TimerState? timerState,
    TimerSettings? settings,
    int? todayFocusCount,
  }) {
    return TimerUiState(
      timerState: timerState ?? this.timerState,
      settings: settings ?? this.settings,
      todayFocusCount: todayFocusCount ?? this.todayFocusCount,
    );
  }
}

/// 计时器状态管理
class TimerNotifier extends Notifier<TimerUiState> {
  StreamSubscription<TimerState>? _stateSub;

  @override
  TimerUiState build() {
    ref.onDispose(() {
      _stateSub?.cancel();
    });
    _init();
    return const TimerUiState();
  }

  TimerRepository get _timerRepo => ref.read(timerRepositoryProvider);
  HistoryRepository get _historyRepo => ref.read(historyRepositoryProvider);
  CompletePomodoroUseCase get _completeUseCase =>
      ref.read(completePomodoroUseCaseProvider);

  Future<void> _init() async {
    final settings = await ref.read(settingsRepositoryProvider).loadSettings();
    _timerRepo.updateSettings(settings);

    _stateSub = _timerRepo.stateStream.listen((ts) {
      state = state.copyWith(timerState: ts);
    });

    state = state.copyWith(
      timerState: _timerRepo.currentState,
      settings: settings,
    );
    _refreshTodayCount();
  }

  bool get isRunning => state.timerState.status == TimerStatus.running;
  bool get isPaused => state.timerState.status == TimerStatus.paused;
  bool get isIdle => state.timerState.status == TimerStatus.idle;

  void start() => _timerRepo.start();
  void pause() => _timerRepo.pause();
  void reset() => _timerRepo.reset();
  void startBreak() => _completeUseCase.startBreak();
  void skip() => _timerRepo.skip();

  Future<void> completePomodoro() async {
    final ts = state.timerState;
    await _completeUseCase.execute(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now().subtract(
        Duration(seconds: ts.totalSeconds - ts.remainingSeconds),
      ),
      durationSeconds: ts.totalSeconds,
      settings: state.settings,
    );
    _timerRepo.reset();
    await _refreshTodayCount();
  }

  Future<void> updateSettings(TimerSettings newSettings) async {
    await ref.read(settingsRepositoryProvider).saveSettings(newSettings);
    _timerRepo.updateSettings(newSettings);
    state = state.copyWith(settings: newSettings);
  }

  Future<void> _refreshTodayCount() async {
    final count = await _historyRepo.getTodayFocusCount();
    state = state.copyWith(todayFocusCount: count);
  }
}

/// Provider: 计时器状态
final timerProvider =
    NotifierProvider<TimerNotifier, TimerUiState>(TimerNotifier.new);
