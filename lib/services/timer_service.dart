import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import '../models/task.dart';
import '../repositories/task_repository.dart';
import 'notification_service.dart';
import 'foreground_timer_service.dart';

class TimerState {
  final int taskId;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;
  final DateTime? sessionStartTime;

  TimerState({
    required this.taskId,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.isPaused,
    this.sessionStartTime,
  });

  TimerState copyWith({
    int? elapsedSeconds,
    bool? isRunning,
    bool? isPaused,
    DateTime? sessionStartTime,
  }) {
    return TimerState(
      taskId: taskId,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }
}

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final TaskRepository _taskRepo = TaskRepository();
  final NotificationService _notificationService = NotificationService();
  final Map<int, TimerState> _activeTimers = {};
  final StreamController<Map<int, TimerState>> _timerController =
      StreamController<Map<int, TimerState>>.broadcast();

  Timer? _tickTimer;
  Timer? _saveTimer;
  bool _initialized = false;
  bool _foregroundServiceActive = false;

  Stream<Map<int, TimerState>> get timerUpdates => _timerController.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    // On Android, check if foreground service is already running
    if (Platform.isAndroid) {
      final isServiceRunning = await ForegroundTimerService.isServiceRunning();
      if (isServiceRunning) {
        _foregroundServiceActive = true;
        // Sync from the running service to get current state
        await _syncFromForegroundService();
      }
    }
    
    // Load running tasks from database and restore timers
    final runningTasks = await _taskRepo.getRunningTasks();
    for (final task in runningTasks) {
      // On Android with active service, use synced values
      // Otherwise calculate elapsed time from last update
      int totalElapsed;
      
      if (Platform.isAndroid && _activeTimers.containsKey(task.id!)) {
        // Already loaded from foreground service, use that value
        totalElapsed = _activeTimers[task.id!]!.elapsedSeconds;
      } else {
        // Calculate from database
        final now = DateTime.now();
        final lastUpdateTime = task.updatedAt;
        final timeSinceLastUpdate = now.difference(lastUpdateTime).inSeconds;
        totalElapsed = task.elapsedSeconds + timeSinceLastUpdate;
        
        _activeTimers[task.id!] = TimerState(
          taskId: task.id!,
          elapsedSeconds: totalElapsed,
          isRunning: true,
          isPaused: false,
          sessionStartTime: lastUpdateTime,
        );
      }
      
      // Update database with current elapsed time
      await _taskRepo.updateTask(task.copyWith(elapsedSeconds: totalElapsed));
    }

    // Load paused tasks
    final pausedTasks = await _taskRepo.getTasksByStatus(TaskStatus.paused);
    for (final task in pausedTasks) {
      if (!_activeTimers.containsKey(task.id!)) {
        _activeTimers[task.id!] = TimerState(
          taskId: task.id!,
          elapsedSeconds: task.elapsedSeconds,
          isRunning: false,
          isPaused: true,
        );
      }
    }

    // Start the tick timer
    _startTickTimer();
    _startAutoSaveTimer();
    
    // Start foreground service on Android if there are running timers
    if (Platform.isAndroid && _activeTimers.values.any((t) => t.isRunning)) {
      await _syncToForegroundService();
    }
    
    _initialized = true;

    _broadcastUpdate();
  }

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      bool hasUpdate = false;
      
      if (Platform.isAndroid) {
        // On Android, just sync from foreground service every second
        // Don't increment - the service is doing that
        if (_foregroundServiceActive) {
          await _syncFromForegroundService();
          hasUpdate = _activeTimers.values.any((t) => t.isRunning);
        }
      } else {
        // On other platforms, increment timers and update notifications
        for (final entry in _activeTimers.entries) {
          if (entry.value.isRunning && !entry.value.isPaused) {
            _activeTimers[entry.key] = entry.value.copyWith(
              elapsedSeconds: entry.value.elapsedSeconds + 1,
            );
            hasUpdate = true;
            
            final task = await _taskRepo.getTaskById(entry.key);
            if (task != null) {
              await _notificationService.updateTimerNotification(
                task: task,
                elapsedSeconds: entry.value.elapsedSeconds,
                isRunning: entry.value.isRunning,
                isPaused: entry.value.isPaused,
              );
            }
          }
        }
      }
      
      if (hasUpdate) {
        _broadcastUpdate();
      }
    });
  }

  void _startAutoSaveTimer() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      // Only save timer state on non-Android platforms
      // On Android, the foreground service handles persistence
      if (!Platform.isAndroid) {
        for (final state in _activeTimers.values) {
          if (state.isRunning) {
            await _saveTimerState(state.taskId);
          }
        }
      }
    });
  }
  
  /// Sync timer data to Android foreground service
  Future<void> _syncToForegroundService() async {
    if (!Platform.isAndroid) return;
    
    final hasRunningTimers = _activeTimers.values.any((t) => t.isRunning);
    
    if (hasRunningTimers) {
      // Build timer data list
      final timerDataList = <TimerData>[];
      
      for (final state in _activeTimers.values) {
        final task = await _taskRepo.getTaskById(state.taskId);
        if (task != null) {
          timerDataList.add(TimerData(
            taskId: state.taskId,
            taskName: task.title,
            elapsedSeconds: state.elapsedSeconds,
            isRunning: state.isRunning,
            isPaused: state.isPaused,
            sessionStartTime: (state.sessionStartTime ?? DateTime.now()).millisecondsSinceEpoch,
          ));
        }
      }
      
      // Start or update foreground service
      if (_foregroundServiceActive) {
        await ForegroundTimerService.updateTimers(timerDataList);
      } else {
        await ForegroundTimerService.startForegroundService(timerDataList);
        _foregroundServiceActive = true;
      }
    } else if (_foregroundServiceActive) {
      // No running timers, stop foreground service
      await ForegroundTimerService.stopForegroundService();
      _foregroundServiceActive = false;
    }
  }
  
  /// Sync timer states FROM the foreground service (foreground service is source of truth)
  Future<void> _syncFromForegroundService() async {
    if (!Platform.isAndroid) return;
    
    try {
      final result = await ForegroundTimerService.getTimerStates();
      if (result == null || result['timerStates'] == null) return;
      
      final timersJson = result['timerStates'] as String;
      final timersList = jsonDecode(timersJson) as List;
      
      // Update Flutter timer states with authoritative values from service
      for (final timerJson in timersList) {
        final timerData = TimerData.fromJson(timerJson as Map<String, dynamic>);
        
        if (_activeTimers.containsKey(timerData.taskId)) {
          _activeTimers[timerData.taskId] = _activeTimers[timerData.taskId]!.copyWith(
            elapsedSeconds: timerData.elapsedSeconds,
          );
          
          // Also update the database with the authoritative value
          final task = await _taskRepo.getTaskById(timerData.taskId);
          if (task != null) {
            await _taskRepo.updateTask(task.copyWith(
              elapsedSeconds: timerData.elapsedSeconds,
            ));
          }
        }
      }
      
      _broadcastUpdate();
    } catch (e) {
      print('Error syncing from foreground service: $e');
    }
  }

  Future<void> _saveTimerState(int taskId) async {
    final state = _activeTimers[taskId];
    if (state == null) return;

    final task = await _taskRepo.getTaskById(taskId);
    if (task == null) return;

    final updatedTask = task.copyWith(
      elapsedSeconds: state.elapsedSeconds,
      status: state.isRunning
          ? TaskStatus.running
          : state.isPaused
              ? TaskStatus.paused
              : TaskStatus.stopped,
    );

    await _taskRepo.updateTask(updatedTask);
  }

  Future<void> startTimer(int taskId) async {
    // Prevent duplicate timers
    if (_activeTimers.containsKey(taskId) &&
        _activeTimers[taskId]!.isRunning) {
      return;
    }

    final task = await _taskRepo.getTaskById(taskId);
    if (task == null) return;

    _activeTimers[taskId] = TimerState(
      taskId: taskId,
      elapsedSeconds: task.elapsedSeconds,
      isRunning: true,
      isPaused: false,
      sessionStartTime: DateTime.now(),
    );

    // Update task status in database
    await _taskRepo.updateTask(task.copyWith(status: TaskStatus.running));

    // Sync to foreground service on Android (it will handle notifications)
    // On other platforms, show notification directly
    if (Platform.isAndroid) {
      await _syncToForegroundService();
    } else {
      await _notificationService.showTimerNotification(
        task: task,
        elapsedSeconds: task.elapsedSeconds,
        isRunning: true,
        isPaused: false,
      );
    }

    _broadcastUpdate();
  }

  Future<void> pauseTimer(int taskId) async {
    final state = _activeTimers[taskId];
    if (state == null || !state.isRunning) return;

    _activeTimers[taskId] = state.copyWith(
      isRunning: false,
      isPaused: true,
    );

    await _saveTimerState(taskId);
    
    // Sync to foreground service on Android (it will handle notifications)
    // On other platforms, update notification directly
    if (Platform.isAndroid) {
      await _syncToForegroundService();
    } else {
      final task = await _taskRepo.getTaskById(taskId);
      if (task != null) {
        await _notificationService.updateTimerNotification(
          task: task,
          elapsedSeconds: state.elapsedSeconds,
          isRunning: false,
          isPaused: true,
        );
      }
    }
    
    _broadcastUpdate();
  }

  Future<void> resumeTimer(int taskId) async {
    final state = _activeTimers[taskId];
    if (state == null || !state.isPaused) return;

    _activeTimers[taskId] = state.copyWith(
      isRunning: true,
      isPaused: false,
      sessionStartTime: DateTime.now(),
    );

    await _saveTimerState(taskId);
    
    // Sync to foreground service on Android (it will handle notifications)
    // On other platforms, update notification directly
    if (Platform.isAndroid) {
      await _syncToForegroundService();
    } else {
      final task = await _taskRepo.getTaskById(taskId);
      if (task != null) {
        await _notificationService.updateTimerNotification(
          task: task,
          elapsedSeconds: state.elapsedSeconds,
          isRunning: true,
          isPaused: false,
        );
      }
    }
    
    _broadcastUpdate();
  }

  Future<void> stopTimer(int taskId) async {
    final state = _activeTimers[taskId];
    if (state == null) return;

    // Get the task and update to stopped status with final elapsed time
    final task = await _taskRepo.getTaskById(taskId);
    if (task != null) {
      await _taskRepo.updateTask(
        task.copyWith(
          elapsedSeconds: state.elapsedSeconds,
          status: TaskStatus.stopped,
          endTime: DateTime.now(),
        ),
      );
    }

    // Remove notification
    await _notificationService.cancelNotification(taskId);

    // Remove from active timers
    _activeTimers.remove(taskId);
    
    // Sync to foreground service on Android (might stop service if no more timers)
    if (Platform.isAndroid) {
      await _syncToForegroundService();
    }
    
    _broadcastUpdate();
  }

  TimerState? getTimerState(int taskId) {
    return _activeTimers[taskId];
  }

  Map<int, TimerState> getAllActiveTimers() {
    return Map.unmodifiable(_activeTimers);
  }

  void _broadcastUpdate() {
    _timerController.add(Map.unmodifiable(_activeTimers));
  }

  void dispose() {
    _tickTimer?.cancel();
    _saveTimer?.cancel();
    _timerController.close();
    
    // Stop foreground service on Android when disposing
    if (Platform.isAndroid && _foregroundServiceActive) {
      ForegroundTimerService.stopForegroundService();
      _foregroundServiceActive = false;
    }
    
    _initialized = false;
  }
}
