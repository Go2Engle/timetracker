import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../models/category.dart';
import '../repositories/task_repository.dart';
import '../repositories/tag_repository.dart';
import '../repositories/category_repository.dart';
import '../services/report_export_service.dart';
import '../utils/time_formatter.dart';
import 'task_detail_screen.dart';

// Helper class to hold task with its related data
class TaskWithDetails {
  final Task task;
  final Category? category;
  final List<Tag> tags;

  TaskWithDetails({
    required this.task,
    this.category,
    required this.tags,
  });
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TaskRepository _taskRepo = TaskRepository();
  final TagRepository _tagRepo = TagRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final ReportExportService _exportService = ReportExportService();

  // State
  List<Tag> _availableTags = [];
  List<Category> _availableCategories = [];
  Set<int> _selectedTagIds = {};
  int? _selectedCategoryId;
  List<TaskWithDetails> _filteredTasksWithDetails = [];
  int _totalSeconds = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tags = await _tagRepo.getAllTags();
      final categories = await _categoryRepo.getAllCategories();

      setState(() {
        _availableTags = tags;
        _availableCategories = categories;
      });

      await _applyFilters();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskRepo.getTasksByFilters(
        tagIds: _selectedTagIds.isEmpty ? null : _selectedTagIds.toList(),
        categoryId: _selectedCategoryId,
      );

      // Load all task details upfront
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
        ));
      }

      final total = tasks.fold<int>(
        0,
        (sum, task) => sum + task.elapsedSeconds,
      );

      setState(() {
        _filteredTasksWithDetails = tasksWithDetails;
        _totalSeconds = total;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleTag(int tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });
    _applyFilters();
  }

  void _selectCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _selectedTagIds.clear();
      _selectedCategoryId = null;
    });
    _applyFilters();
  }

  Future<void> _exportReport() async {
    try {
      // Generate filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'timetracker_report_$timestamp.csv';

      // Let user choose directory to save CSV export
      final directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Export Location',
      );

      // User cancelled
      if (directoryPath == null) {
        return;
      }

      // Create full file path
      final filePath = '$directoryPath/$fileName';

      // Export to CSV
      final tasks = _filteredTasksWithDetails.map((td) => td.task).toList();
      await _exportService.exportToCSV(tasks, _totalSeconds, filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report exported successfully:\n$fileName\n\nSaved to: $directoryPath',
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export report: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = _selectedTagIds.isNotEmpty || _selectedCategoryId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        elevation: 0,
        actions: [
          if (hasFilters)
            TextButton.icon(
              icon: const Icon(Icons.clear_all, size: 20),
              label: const Text('Clear'),
              onPressed: _clearFilters,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading && _filteredTasksWithDetails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Filter section
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Filters',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Project/Client filter
                        if (_availableCategories.isNotEmpty) ...[
                          Text(
                            'Project/Client',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int?>(
                            value: _selectedCategoryId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                            hint: const Text('All projects/clients'),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All projects/clients'),
                              ),
                              ..._availableCategories.map((category) {
                                return DropdownMenuItem<int?>(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: _parseColor(category.color),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(category.name),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: _selectCategory,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Tags filter
                        if (_availableTags.isNotEmpty) ...[
                          Text(
                            'Tags',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableTags.map((tag) {
                              final isSelected = _selectedTagIds.contains(tag.id);
                              return FilterChip(
                                label: Text(tag.name),
                                selected: isSelected,
                                onSelected: (selected) => _toggleTag(tag.id!),
                                showCheckmark: true,
                              );
                            }).toList(),
                          ),
                        ],

                        // Empty state for no tags/categories
                        if (_availableTags.isEmpty && _availableCategories.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No tags or categories available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Total time display
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(24),
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Time',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          TimeFormatter.formatDuration(_totalSeconds),
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                        if (_filteredTasksWithDetails.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${_filteredTasksWithDetails.length} ${_filteredTasksWithDetails.length == 1 ? 'task' : 'tasks'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Task list header
                if (_filteredTasksWithDetails.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'TASKS',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                // Task list
                _filteredTasksWithDetails.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasFilters ? Icons.filter_list_off : Icons.inbox_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                hasFilters
                                    ? 'No tasks match filters'
                                    : 'No tasks to display',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final taskWithDetails = _filteredTasksWithDetails[index];
                              return _TaskListItem(
                                taskWithDetails: taskWithDetails,
                                onTap: () => _navigateToTaskDetail(taskWithDetails.task),
                              );
                            },
                            childCount: _filteredTasksWithDetails.length,
                          ),
                        ),
                      ),
              ],
            ),
      floatingActionButton: _filteredTasksWithDetails.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _exportReport,
              icon: const Icon(Icons.download),
              label: const Text('Export CSV'),
              elevation: 4,
            )
          : null,
    );
  }

  void _navigateToTaskDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(taskId: task.id!),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    // Remove # if present
    final hex = hexColor.replaceAll('#', '');
    // Parse hex to integer and create Color
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class _TaskListItem extends StatelessWidget {
  final TaskWithDetails taskWithDetails;
  final VoidCallback onTap;

  const _TaskListItem({
    required this.taskWithDetails,
    required this.onTap,
  });

  Color _parseColor(String hexColor) {
    // Remove # if present
    final hex = hexColor.replaceAll('#', '');
    // Parse hex to integer and create Color
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y • h:mm a');
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and elapsed time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      TimeFormatter.formatDuration(task.elapsedSeconds),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Start time
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(task.startTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Category and tags
              if (category != null || tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Category badge
                    if (category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      ),
    );
  }
}
