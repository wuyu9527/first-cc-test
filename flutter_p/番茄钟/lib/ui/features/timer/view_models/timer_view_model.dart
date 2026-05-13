import 'package:flutter/foundation.dart';
import '../../../../data/repositories/history_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/repositories/timer_repository.dart';
import '../../../../domain/models/pomodoro_session.dart';
import '../../../../domain/models/timer_settings.dart';
import '../../../../domain/models/timer_state.dart';
import '../../../../domain/use_cases/complete_pomodoro_use_case.dart';

/// 计时器页面 ViewModel
class TimerViewmodel extends ChangeNotifier {
  TimerViewmodel({
    required TimerRepository timerRepository,
    required HistoryRepository historyRepository,
    required SettingsRepository settingsRepository,
    required CompletePomodoroUseCase completePomodoroUseCase,
  })  : _timerRepository = timerRepository,
        _historyRepository = historyRepository,
        _settingsRepository = settingsRepository,
        _completePomodoroUseCase = completePomodoroUseCase;

  final TimerRepository _timerRepository;
  final HistoryRepository _historyRepository;
  final SettingsRepository _settingsRepository;
  final CompletePomodoroUseCase _completePomodoroUseCase;

  TimerState _timerState = const TimerState();
  TimerSettings _settings = const TimerSettings();
  int _todayFocusCount = 0;

  TimerState get timerState => _timerState;
  TimerSettings get settings => _settings;
  int get todayFocusCount => _todayFocusCount;

  /// 是否正在计时
  bool get isRunning => _timerState.status == TimerStatus.running;

  /// 是否已暂停
  bool get isPaused => _timerState.status == TimerStatus.paused;

  /// 是否空闲
  bool get isIdle => _timerState.status == TimerStatus.idle;

  /// 初始化 —— 加载设置并监听计时器状态
  Future<void> initialize() async {
    _settings = await _settingsRepository.loadSettings();
    _timerRepository.updateSettings(_settings);
    await _refreshTodayCount();

    _timerRepository.stateStream.listen((state) {
      _timerState = state;
      notifyListeners();

      // 专注完成时记录
      if (state.status == TimerStatus.idle &&
          state.completedSessions > 0 &&
          state.sessionType != SessionType.focus) {
        _refreshTodayCount();
      }
    });

    _timerState = _timerRepository.currentState;
    notifyListeners();
  }

  /// 开始/继续
  void start() {
    _timerRepository.start();
  }

  /// 暂停
  void pause() {
    _timerRepository.pause();
  }

  /// 重置
  void reset() {
    _timerRepository.reset();
  }

  /// 开始休息
  void startBreak() {
    _completePomodoroUseCase.startBreak();
  }

  /// 跳过
  void skip() {
    _timerRepository.skip();
  }

  /// 完成当前番茄钟
  Future<void> completePomodoro() async {
    final session = await _completePomodoroUseCase.execute(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now().subtract(
        Duration(
          seconds: _timerState.totalSeconds - _timerState.remainingSeconds,
        ),
      ),
      durationSeconds: _timerState.totalSeconds,
      settings: _settings,
    );
    _timerRepository.reset();
    await _refreshTodayCount();
    notifyListeners();
  }

  /// 更新设置
  Future<void> updateSettings(TimerSettings newSettings) async {
    _settings = newSettings;
    await _settingsRepository.saveSettings(newSettings);
    _timerRepository.updateSettings(newSettings);
    notifyListeners();
  }

  Future<void> _refreshTodayCount() async {
    _todayFocusCount = await _historyRepository.getTodayFocusCount();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
