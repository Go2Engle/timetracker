import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../utils/time_formatter.dart';
import 'task_detail_screen.dart';

/// Calendar screen with collapsible calendar view.
///
/// Displays a month-view calendar that automatically collapses when scrolling
/// down to maximize space for the task list. The calendar can be expanded by
/// scrolling to the top or dragging down on the collapsed header.
///
/// Key features:
/// - Collapsible calendar header (expands to ~400dp, collapses to ~80dp)
/// - Maintains selected date and focused month during transitions
/// - Smooth animations for expand/collapse transitions
/// - Visual indicators for days with tasks
/// - Daily task summary and detailed task list
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskRepository _taskRepo = TaskRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _tasksForSelectedDay = [];
  Map<DateTime, int> _taskCounts = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasksForMonth(_focusedDay);
    _loadTasksForSelectedDay();
  }

  Future<void> _loadTasksForMonth(DateTime month) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final tasks = await _taskRepo.getTasksByDateRange(firstDay, lastDay);

    final counts = <DateTime, int>{};
    for (final task in tasks) {
      final date = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );
      counts[date] = (counts[date] ?? 0) + 1;
    }

    setState(() {
      _taskCounts = counts;
    });
  }

  Future<void> _loadTasksForSelectedDay() async {
    if (_selectedDay == null) return;

    setState(() => _isLoading = true);

    final tasks = await _taskRepo.getTasksByDate(_selectedDay!);

    setState(() {
      _tasksForSelectedDay = tasks;
      _isLoading = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _loadTasksForSelectedDay();
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    _loadTasksForMonth(focusedDay);
  }

  int _getTaskCount(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _taskCounts[date] ?? 0;
  }

  int _getTotalElapsedForDay() {
    return _tasksForSelectedDay.fold<int>(
      0,
      (sum, task) => sum + task.elapsedSeconds,
    );
  }

  Future<void> _navigateToTaskDetail(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(taskId: task.id!),
      ),
    );
    // Refresh the task list when returning from detail screen
    _loadTasksForSelectedDay();
    _loadTasksForMonth(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible calendar header using SliverAppBar
          // When expanded, shows full calendar (~400dp)
          // When collapsed, shows minimal info (~80dp) and stays pinned at top
          SliverAppBar(
            expandedHeight: 400.0,
            collapsedHeight: 80.0,
            pinned: true,
            floating: false,
            elevation: 0,
            title: const Text('Calendar'),
            actions: [
              IconButton(
                icon: const Icon(Icons.today),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                  _loadTasksForMonth(DateTime.now());
                  _loadTasksForSelectedDay();
                },
                tooltip: 'Go to today',
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Calculate if we're collapsed (closer to collapsedHeight) or expanded
                // constraints.maxHeight decreases as we scroll down
                final isCollapsed = constraints.maxHeight <= 120;

                return FlexibleSpaceBar(
                  // Only show date title when collapsed
                  title: isCollapsed && _selectedDay != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('MMM d, y').format(_selectedDay!),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.expand_more, size: 16),
                          ],
                        )
                      : null,
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Column(
                    children: [
                      const SizedBox(height: 88), // AppBar height + extra spacing
                      // Calendar widget
                      Expanded(
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: _onDaySelected,
                          onPageChanged: _onPageChanged,
                          calendarFormat: CalendarFormat.month,
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              final count = _getTaskCount(day);
                              if (count > 0) {
                                return Positioned(
                                  bottom: 1,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Daily summary
          if (_selectedDay != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 20,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMMM d, y').format(_selectedDay!),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    if (_tasksForSelectedDay.isNotEmpty)
                      Text(
                        '${_tasksForSelectedDay.length} ${_tasksForSelectedDay.length == 1 ? 'task' : 'tasks'} • '
                        '${TimeFormatter.formatElapsedTime(_getTotalElapsedForDay())}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Task list header
          if (_tasksForSelectedDay.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'TASKS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // Task list
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _tasksForSelectedDay.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks on this day',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start tracking to see tasks here',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final task = _tasksForSelectedDay[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        index == _tasksForSelectedDay.length - 1 ? 16 : 0,
                      ),
                      child: _TaskHistoryCard(
                        task: task,
                        onTap: () => _navigateToTaskDetail(task),
                      ),
                    );
                  }, childCount: _tasksForSelectedDay.length),
                ),
        ],
      ),
    );
  }
}

class _TaskHistoryCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskHistoryCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
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
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Started at ${DateFormat('h:mm a').format(task.startTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: task.status == TaskStatus.running
                          ? Colors.green.withOpacity(0.15)
                          : task.status == TaskStatus.paused
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.status == TaskStatus.running
                            ? Colors.green.withOpacity(0.3)
                            : task.status == TaskStatus.paused
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          task.status == TaskStatus.running
                              ? Icons.play_arrow
                              : task.status == TaskStatus.paused
                              ? Icons.pause
                              : Icons.stop,
                          size: 12,
                          color: task.status == TaskStatus.running
                              ? Colors.green[800]
                              : task.status == TaskStatus.paused
                              ? Colors.orange[800]
                              : Colors.grey[800],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.status.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: task.status == TaskStatus.running
                                ? Colors.green[800]
                                : task.status == TaskStatus.paused
                                ? Colors.orange[800]
                                : Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
