/// 番茄钟会话类型
enum SessionType {
  /// 专注时段
  focus,

  /// 短休息
  shortBreak,

  /// 长休息
  longBreak,
}

/// 番茄钟会话记录
class PomodoroSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final SessionType type;
  final bool isCompleted;

  const PomodoroSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.type,
    this.isCompleted = false,
  });

  /// 已完成会话的实际时长（秒）
  int? get actualDurationSeconds {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inSeconds;
  }

  PomodoroSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    SessionType? type,
    bool? isCompleted,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'durationSeconds': durationSeconds,
        'type': type.name,
        'isCompleted': isCompleted,
      };

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationSeconds: json['durationSeconds'] as int,
      type: SessionType.values.byName(json['type'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
