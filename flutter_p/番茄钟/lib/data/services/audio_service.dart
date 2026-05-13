import 'package:audioplayers/audioplayers.dart';

/// 音频播放服务
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// 播放完成提示音
  Future<void> playCompletionSound() async {
    try {
      await _player.play(AssetSource('sounds/completion.mp3'));
    } catch (_) {
      // 资源不存在时静默失败
    }
  }

  /// 播放开始提示音
  Future<void> playStartSound() async {
    try {
      await _player.play(AssetSource('sounds/start.mp3'));
    } catch (_) {
      // 资源不存在时静默失败
    }
  }

  /// 释放资源
  void dispose() {
    _player.dispose();
  }
}
