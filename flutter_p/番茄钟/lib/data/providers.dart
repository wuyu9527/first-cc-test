import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/auth_repository.dart';
import 'repositories/history_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/timer_repository.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';
import 'services/auth_storage_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import '../domain/use_cases/complete_pomodoro_use_case.dart';

// ==================== 服务层（单例） ====================

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authStorageServiceProvider = Provider<AuthStorageService>((ref) {
  return AuthStorageService();
});

// ==================== 仓储层 ====================

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    storageService: ref.read(storageServiceProvider),
  );
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(
    storageService: ref.read(storageServiceProvider),
  );
});

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiService: ref.read(apiServiceProvider),
    storageService: ref.read(authStorageServiceProvider),
  );
});

// ==================== 用例层 ====================

final completePomodoroUseCaseProvider =
    Provider<CompletePomodoroUseCase>((ref) {
  return CompletePomodoroUseCase(
    timerRepository: ref.read(timerRepositoryProvider),
    historyRepository: ref.read(historyRepositoryProvider),
    audioService: ref.read(audioServiceProvider),
    notificationService: ref.read(notificationServiceProvider),
  );
});
