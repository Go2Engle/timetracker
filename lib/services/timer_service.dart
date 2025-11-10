import 'dart:async';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import 'notification_service.dart';

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

  Stream<Map<int, TimerState>> get timerUpdates => _timerController.stream;

  Future<void> initialize() async {
    if (_initialized) return;

    // Load running tasks from database and restore timers
    final runningTasks = await _taskRepo.getRunningTasks();
    for (final task in runningTasks) {
      // For running tasks, calculate elapsed time from last update
      // We use the task's updatedAt as the session start reference
      final now = DateTime.now();
      final lastUpdateTime = task.updatedAt;
      final timeSinceLastUpdate = now.difference(lastUpdateTime).inSeconds;
      final totalElapsed = task.elapsedSeconds + timeSinceLastUpdate;
      
      _activeTimers[task.id!] = TimerState(
        taskId: task.id!,
        elapsedSeconds: totalElapsed,
        isRunning: true,
        isPaused: false,
        sessionStartTime: lastUpdateTime,
      );
      
      // Update database with corrected elapsed time
      await _taskRepo.updateTask(task.copyWith(elapsedSeconds: totalElapsed));
    }

    // Load paused tasks
    final pausedTasks = await _taskRepo.getTasksByStatus(TaskStatus.paused);
    for (final task in pausedTasks) {
      _activeTimers[task.id!] = TimerState(
        taskId: task.id!,
        elapsedSeconds: task.elapsedSeconds,
        isRunning: false,
        isPaused: true,
      );
    }

    // Start the tick timer
    _startTickTimer();
    _startAutoSaveTimer();
    _initialized = true;

    _broadcastUpdate();
  }

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      bool hasUpdate = false;
      for (final entry in _activeTimers.entries) {
        if (entry.value.isRunning && !entry.value.isPaused) {
          _activeTimers[entry.key] = entry.value.copyWith(
            elapsedSeconds: entry.value.elapsedSeconds + 1,
          );
          hasUpdate = true;
          
          // Update notification
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
      if (hasUpdate) {
        _broadcastUpdate();
      }
    });
  }

  void _startAutoSaveTimer() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      for (final state in _activeTimers.values) {
        if (state.isRunning) {
          await _saveTimerState(state.taskId);
        }
      }
    });
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

    // Show notification
    await _notificationService.showTimerNotification(
      task: task,
      elapsedSeconds: task.elapsedSeconds,
      isRunning: true,
      isPaused: false,
    );

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
    
    // Update notification to show paused state
    final task = await _taskRepo.getTaskById(taskId);
    if (task != null) {
      await _notificationService.updateTimerNotification(
        task: task,
        elapsedSeconds: state.elapsedSeconds,
        isRunning: false,
        isPaused: true,
      );
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
    
    // Update notification to show running state
    final task = await _taskRepo.getTaskById(taskId);
    if (task != null) {
      await _notificationService.updateTimerNotification(
        task: task,
        elapsedSeconds: state.elapsedSeconds,
        isRunning: true,
        isPaused: false,
      );
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
    _initialized = false;
  }
}
