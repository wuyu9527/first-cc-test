import 'package:flutter/material.dart';

/// 圆形进度指示器，用于显示番茄钟倒计时
class CircularTimerProgress extends StatelessWidget {
  const CircularTimerProgress({
    super.key,
    required this.progress,
    required this.remainingText,
    required this.statusText,
    required this.color,
    this.size = 260,
    this.strokeWidth = 12,
  });

  /// 进度值 0.0 ~ 1.0
  final double progress;

  /// 剩余时间文本
  final String remainingText;

  /// 状态文本（如"专注中"、"休息中"）
  final String statusText;

  /// 进度环颜色
  final Color color;

  /// 组件尺寸
  final double size;

  /// 描边宽度
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景环
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: color.withAlpha(40),
            ),
          ),
          // 进度环
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          // 中间文字
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                remainingText,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                statusText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color.withAlpha(200),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
