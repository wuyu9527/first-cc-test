import 'dart:async';
import '../../domain/models/pomodoro_session.dart';
import '../../domain/models/timer_state.dart';
import '../../domain/models/timer_settings.dart';

/// 计时器仓储 —— 管理计时逻辑和状态
class TimerRepository {
  Timer? _timer;
  TimerState _state = const TimerState();
  TimerSettings _settings = const TimerSettings();

  /// 当前计时器状态
  TimerState get currentState => _state;

  /// 状态变化通知流
  final StreamController<TimerState> _stateController =
      StreamController<TimerState>.broadcast();

  Stream<TimerState> get stateStream => _stateController.stream;

  /// 更新设置
  void updateSettings(TimerSettings settings) {
    _settings = settings;
    if (_state.status == TimerStatus.idle) {
      _state = TimerState(
        totalSeconds: settings.focusDurationMinutes * 60,
        remainingSeconds: settings.focusDurationMinutes * 60,
        sessionType: SessionType.focus,
        completedSessions: _state.completedSessions,
      );
      _stateController.add(_state);
    }
  }

  /// 开始计时
  void start() {
    if (_state.status == TimerStatus.running) return;

    if (_state.status == TimerStatus.idle) {
      _state = TimerState(
        status: TimerStatus.running,
        totalSeconds: _settings.focusDurationMinutes * 60,
        remainingSeconds: _settings.focusDurationMinutes * 60,
        sessionType: SessionType.focus,
        completedSessions: _state.completedSessions,
      );
    } else {
      _state = _state.copyWith(status: TimerStatus.running);
    }

    _stateController.add(_state);
    _startTicking();
  }

  /// 暂停计时
  void pause() {
    if (_state.status != TimerStatus.running) return;
    _timer?.cancel();
    _state = _state.copyWith(status: TimerStatus.paused);
    _stateController.add(_state);
  }

  /// 重置计时器
  void reset() {
    _timer?.cancel();
    _state = TimerState(
      totalSeconds: _settings.focusDurationMinutes * 60,
      remainingSeconds: _settings.focusDurationMinutes * 60,
      sessionType: SessionType.focus,
      completedSessions: _state.completedSessions,
    );
    _stateController.add(_state);
  }

  /// 跳过当前阶段
  void skip() {
    _timer?.cancel();
    _transitionToNext();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.remainingSeconds <= 1) {
        _timer?.cancel();
        _onTimerFinished();
        return;
      }
      _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
      _stateController.add(_state);
    });
  }

  void _onTimerFinished() {
    if (_state.sessionType == SessionType.focus) {
      // 专注完成，+1 计数
      final newCount = _state.completedSessions + 1;
      _state = _state.copyWith(
        completedSessions: newCount,
        status: TimerStatus.idle,
      );
      _stateController.add(_state);
    } else {
      // 休息完成，回到空闲
      _state = _state.copyWith(status: TimerStatus.idle);
      _stateController.add(_state);
    }
  }

  /// 转为休息阶段
  void startBreak() {
    _timer?.cancel();
    final isLongBreak =
        _state.completedSessions > 0 &&
        _state.completedSessions % _settings.sessionsBeforeLongBreak == 0;
    final breakDuration = isLongBreak
        ? _settings.longBreakDurationMinutes * 60
        : _settings.shortBreakDurationMinutes * 60;

    _state = TimerState(
      status: TimerStatus.running,
      totalSeconds: breakDuration,
      remainingSeconds: breakDuration,
      sessionType: isLongBreak ? SessionType.longBreak : SessionType.shortBreak,
      completedSessions: _state.completedSessions,
    );
    _stateController.add(_state);
    _startTicking();
  }

  /// 释放资源
  void dispose() {
    _timer?.cancel();
    _stateController.close();
  }

  void _transitionToNext() {
    if (_state.sessionType == SessionType.focus) {
      _onTimerFinished();
    } else {
      _state = _state.copyWith(
        status: TimerStatus.idle,
        sessionType: SessionType.focus,
        totalSeconds: _settings.focusDurationMinutes * 60,
        remainingSeconds: _settings.focusDurationMinutes * 60,
      );
      _stateController.add(_state);
    }
  }
}
