import 'dart:async';
import 'package:flutter/material.dart';
import 'models/task.dart';
import 'models/category.dart';
import 'models/tag.dart';
import 'repositories/task_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/tag_repository.dart';
import 'services/timer_service.dart';
import 'services/notification_service.dart';
import 'services/preferences_service.dart';
import 'screens/calendar_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reports_screen.dart';
import 'widgets/add_task_dialog.dart';
import 'widgets/category_badge.dart';
import 'utils/time_formatter.dart';

// Helper class to hold task with its related data
class TaskWithDetails {
  final Task task;
  final Category? category;
  final List<Tag> tags;
  final TimerState? timerState;

  TaskWithDetails({
    required this.task,
    this.category,
    required this.tags,
    this.timerState,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize preferences service
  final preferencesService = PreferencesService();
  await preferencesService.initialize();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();
  
  // Initialize timer service
  await TimerService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeTracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  static const List<Widget> _screens = [
    TaskListScreen(),
    CalendarScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskRepository _taskRepo = TaskRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final TagRepository _tagRepo = TagRepository();
  final TimerService _timerService = TimerService();
  final PreferencesService _prefsService = PreferencesService();
  
  List<TaskWithDetails> _allTasksWithDetails = [];
  Map<int, TimerState> _timerStates = {};
  bool _isLoading = false;
  bool _groupByCategory = false;
  StreamSubscription<Map<int, TimerState>>? _timerSubscription;

  @override
  void initState() {
    super.initState();
    _groupByCategory = _prefsService.getGroupByCategory();
    _loadTasks();
    _listenToTimerUpdates();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    super.dispose();
  }

  void _listenToTimerUpdates() {
    _timerSubscription = _timerService.timerUpdates.listen((states) {
      if (mounted) {
        setState(() {
          _timerStates = states;
        });
      }
    });
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskRepo.getAllTasks();
      
      // Load categories and tags for each task
      final tasksWithDetails = <TaskWithDetails>[];
      for (final task in tasks) {
        Category? category;
        if (task.categoryId != null) {
          category = await _categoryRepo.getCategoryById(task.categoryId!);
        }

        final tags = task.id != null
            ? await _taskRepo.getTagsForTask(task.id!)
            : <Tag>[];

        tasksWithDetails.add(TaskWithDetails(
          task: task,
          category: category,
          tags: tags,
          timerState: task.id != null ? _timerStates[task.id] : null,
        ));
      }
      
      setState(() {
        _allTasksWithDetails = tasksWithDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestTask() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );

    if (result == null) return; // User cancelled

    setState(() => _isLoading = true);
    try {
      // Create task with user input
      final task = Task(
        title: result['title'] as String,
        description: result['description'] as String?,
        startTime: DateTime.now(),
        status: TaskStatus.stopped,
        categoryId: result['categoryId'] as int?,
      );
      
      final taskId = await _taskRepo.createTask(task);
      
      // Add selected tags
      final tagIds = result['tagIds'] as List<int>;
      for (final tagId in tagIds) {
        await _taskRepo.addTagToTask(taskId, tagId);
      }

      // Auto-start the timer for the new task
      await _timerService.startTimer(taskId);

      await _loadTasks();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTimer(Task task) async {
    final state = _timerStates[task.id];
    
    if (state == null || state.isPaused || !state.isRunning) {
      // Start or resume
      if (task.status == TaskStatus.paused) {
        await _timerService.resumeTimer(task.id!);
      } else {
        await _timerService.startTimer(task.id!);
      }
    } else {
      // Pause
      await _timerService.pauseTimer(task.id!);
    }
    await _loadTasks();
  }

  Future<void> _stopTimer(Task task) async {
    await _timerService.stopTimer(task.id!);
    await _loadTasks();
  }

  /// Build grouped tasks by category
  List<Widget> _buildGroupedTasks(List<TaskWithDetails> tasks, ThemeData theme) {
    if (tasks.isEmpty) return [];
    
    // Group tasks by category ID (not the object itself, to avoid duplicate groups)
    final Map<int?, List<TaskWithDetails>> grouped = {};
    for (final taskWithDetails in tasks) {
      final categoryId = taskWithDetails.task.categoryId;
      if (!grouped.containsKey(categoryId)) {
        grouped[categoryId] = [];
      }
      grouped[categoryId]!.add(taskWithDetails);
    }

    // Sort categories: named categories alphabetically, then uncategorized
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        if (a.key == null) return 1; // uncategorized at end
        if (b.key == null) return -1;
        // Get category names from the first task in each group
        final aCategory = a.value.first.category;
        final bCategory = b.value.first.category;
        return aCategory!.name.compareTo(bCategory!.name);
      });

    final List<Widget> widgets = [];
    
    for (final entry in sortedEntries) {
      final categoryTasks = entry.value;
      final category = categoryTasks.first.category; // Get category from first task
      
      // Category header
      widgets.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                if (category != null)
                  CategoryBadge(
                    category: category,
                    showName: false,
                    size: 16,
                  )
                else
                  const Icon(Icons.inbox_outlined, size: 16),
                const SizedBox(width: 8),
                Text(
                  category?.name ?? 'Uncategorized',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${categoryTasks.length}',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      // Tasks in this category
      widgets.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final taskWithDetails = categoryTasks[index];
                return _TaskCard(
                  taskWithDetails: taskWithDetails,
                  onStart: () => _toggleTimer(taskWithDetails.task),
                  onTap: _loadTasks,
                );
              },
              childCount: categoryTasks.length,
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeTasksWithDetails = _allTasksWithDetails.where((td) => 
      td.task.status == TaskStatus.running || td.task.status == TaskStatus.paused
    ).toList();
    
    final stoppedTasksWithDetails = _allTasksWithDetails.where((td) => 
      td.task.status == TaskStatus.stopped
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeTracker'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_groupByCategory ? Icons.view_list : Icons.view_module_outlined),
            onPressed: () async {
              setState(() {
                _groupByCategory = !_groupByCategory;
              });
              await _prefsService.setGroupByCategory(_groupByCategory);
            },
            tooltip: _groupByCategory ? 'Ungroup' : 'Group by Project/Client',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Active tasks section
          if (activeTasksWithDetails.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active Tasks (${activeTasksWithDetails.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final taskWithDetails = activeTasksWithDetails[index];
                    return _ActiveTaskCard(
                      taskWithDetails: taskWithDetails,
                      timerState: _timerStates[taskWithDetails.task.id],
                      onToggle: () => _toggleTimer(taskWithDetails.task),
                      onStop: () => _stopTimer(taskWithDetails.task),
                      onTap: _loadTasks,
                    );
                  },
                  childCount: activeTasksWithDetails.length,
                ),
              ),
            ),
          ],
          
          // Recent tasks header (only show if not grouping)
          if (!_groupByCategory)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, activeTasksWithDetails.isNotEmpty ? 8 : 16, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Tasks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Recent tasks list
          if (stoppedTasksWithDetails.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create a task',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_groupByCategory)
            // Show grouped by category
            ..._buildGroupedTasks(stoppedTasksWithDetails, theme)
          else
            // Show ungrouped list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final taskWithDetails = stoppedTasksWithDetails[index];
                    return _TaskCard(
                      taskWithDetails: taskWithDetails,
                      onStart: () => _toggleTimer(taskWithDetails.task),
                      onTap: _loadTasks,
                    );
                  },
                  childCount: stoppedTasksWithDetails.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _createTestTask,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        elevation: 4,
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final TaskWithDetails taskWithDetails;
  final TimerState? timerState;
  final VoidCallback onToggle;
  final VoidCallback onStop;
  final VoidCallback onTap;

  const _ActiveTaskCard({
    required this.taskWithDetails,
    required this.timerState,
    required this.onToggle,
    required this.onStop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = taskWithDetails.task;
    final category = taskWithDetails.category;
    final tags = taskWithDetails.tags;
    final elapsed = timerState?.elapsedSeconds ?? task.elapsedSeconds;
    final isRunning = timerState?.isRunning ?? false;
    final isPaused = timerState?.isPaused ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(taskId: task.id!),
              ),
            );
            // Refresh task list after returning from detail screen
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          if (task.description != null && task.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                task.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          // Category and tags
                          if (category != null || tags.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  // Category badge
                                  if (category != null)
                                    CategoryBadge(
                                      category: category,
                                      showName: true,
                                      size: 12,
                                    ),

                                  // Tag chips
                                  ...tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.label_outline,
                                            size: 12,
                                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            tag.name,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPaused
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPaused
                              ? Colors.orange.withOpacity(0.5)
                              : Colors.green.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPaused ? Icons.pause : Icons.play_arrow,
                            size: 14,
                            color: isPaused ? Colors.orange[800] : Colors.green[800],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPaused ? 'Paused' : 'Running',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isPaused ? Colors.orange[800] : Colors.green[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      TimeFormatter.formatDuration(elapsed),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton.filled(
                          onPressed: onToggle,
                          icon: Icon(isRunning && !isPaused
                              ? Icons.pause
                              : Icons.play_arrow),
                          tooltip: isRunning && !isPaused ? 'Pause' : 'Resume',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: onStop,
                          icon: const Icon(Icons.stop),
                          tooltip: 'Stop',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            foregroundColor: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskWithDetails taskWithDetails;
  final VoidCallback onStart;
  final VoidCallback onTap;

  const _TaskCard({
    required this.taskWithDetails,
    required this.onStart,
    required this.onTap,
  });

  Color _parseColor(String colorString) {
    return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = taskWithDetails.task;
    final category = taskWithDetails.category;
    final tags = taskWithDetails.tags;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(taskId: task.id!),
            ),
          );
          // Refresh task list after returning from detail screen
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Category and tags
                    if (category != null || tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          // Category badge
                          if (category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _parseColor(category.color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _parseColor(category.color).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 12,
                                    color: _parseColor(category.color),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    category.name,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: _parseColor(category.color),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Tag chips
                          ...tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.label_outline,
                                    size: 12,
                                    color: theme.colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tag.name,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      TimeFormatter.formatElapsedTime(task.elapsedSeconds),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.play_arrow, size: 20),
                    onPressed: onStart,
                    tooltip: 'Start',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
