import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../repositories/task_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/tag_repository.dart';
import '../services/timer_service.dart';
import '../widgets/edit_task_dialog.dart';
import '../utils/time_formatter.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskRepository _taskRepo = TaskRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final TagRepository _tagRepo = TagRepository();
  final TimerService _timerService = TimerService();

  Task? _task;
  Category? _category;
  List<Tag> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    setState(() => _isLoading = true);
    try {
      final task = await _taskRepo.getTaskById(widget.taskId);
      if (task == null) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      Category? category;
      if (task.categoryId != null) {
        category = await _categoryRepo.getCategoryById(task.categoryId!);
      }

      final tags = await _tagRepo.getTagsForTask(widget.taskId);

      setState(() {
        _task = task;
        _category = category;
        _tags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Stop timer if running
      if (_task?.status == TaskStatus.running || _task?.status == TaskStatus.paused) {
        await _timerService.stopTimer(widget.taskId);
      }

      await _taskRepo.deleteTask(widget.taskId);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    }
  }

  Future<void> _editTask() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditTaskDialog(task: _task!),
    );

    if (result == true) {
      await _loadTaskDetails();
    }
  }

  String _getStatusText() {
    if (_task == null) return '';
    
    switch (_task!.status) {
      case TaskStatus.running:
        return 'Running';
      case TaskStatus.paused:
        return 'Paused';
      case TaskStatus.stopped:
        return _task!.endTime != null ? 'Completed' : 'Stopped';
    }
  }

  Color _getStatusColor() {
    if (_task == null) return Colors.grey;
    
    switch (_task!.status) {
      case TaskStatus.running:
        return Colors.green;
      case TaskStatus.paused:
        return Colors.orange;
      case TaskStatus.stopped:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _task == null ? null : _editTask,
            tooltip: 'Edit Task',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _task == null ? null : _deleteTask,
            tooltip: 'Delete Task',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
              ? const Center(child: Text('Task not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _task!.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status Badge
                      Chip(
                        avatar: CircleAvatar(
                          backgroundColor: _getStatusColor(),
                        ),
                        label: Text(_getStatusText()),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      if (_task!.description != null && _task!.description!.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _task!.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Category
                      if (_category != null) ...[
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(_category!.color.replaceFirst('#', '0xFF')),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _category!.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Tags
                      if (_tags.isNotEmpty) ...[
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) {
                            return Chip(
                              label: Text(tag.name),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Time Information
                      Text(
                        'Time Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                'Total Time',
                                TimeFormatter.formatElapsedTime(_task!.elapsedSeconds),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Started',
                                _formatDateTime(_task!.startTime),
                              ),
                              if (_task!.endTime != null) ...[
                                const Divider(),
                                _buildInfoRow(
                                  'Ended',
                                  _formatDateTime(_task!.endTime!),
                                ),
                              ],
                              const Divider(),
                              _buildInfoRow(
                                'Created',
                                _formatDateTime(_task!.createdAt),
                              ),
                              const Divider(),
                              _buildInfoRow(
                                'Updated',
                                _formatDateTime(_task!.updatedAt),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(value),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      // This week
      return '${difference.inDays} days ago at ${_formatTime(dateTime)}';
    } else {
      // Format as date
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
