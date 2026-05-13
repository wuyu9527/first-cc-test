import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地持久化存储服务
class StorageService {
  static const _historyKey = 'pomodoro_history';
  static const _settingsKey = 'pomodoro_settings';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// 保存 JSON 列表到指定 key
  Future<bool> saveJsonList(String key, List<Map<String, dynamic>> data) async {
    final prefs = await _prefs;
    return prefs.setString(key, jsonEncode(data));
  }

  /// 读取 JSON 列表
  Future<List<Map<String, dynamic>>> loadJsonList(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  /// 保存 JSON 对象
  Future<bool> saveJson(String key, Map<String, dynamic> data) async {
    final prefs = await _prefs;
    return prefs.setString(key, jsonEncode(data));
  }

  /// 读取 JSON 对象
  Future<Map<String, dynamic>?> loadJson(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// 清除所有数据
  Future<bool> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_historyKey);
    await prefs.remove(_settingsKey);
    return true;
  }

  String get historyKey => _historyKey;
  String get settingsKey => _settingsKey;
}
