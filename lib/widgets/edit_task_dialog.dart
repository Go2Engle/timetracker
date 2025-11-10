import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../repositories/task_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/tag_repository.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;

  const EditTaskDialog({super.key, required this.task});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final _taskRepo = TaskRepository();
  final _categoryRepo = CategoryRepository();
  final _tagRepo = TagRepository();
  
  List<Category> _categories = [];
  List<Tag> _allTags = [];
  Category? _selectedCategory;
  Set<int> _selectedTagIds = {};
  Set<int> _originalTagIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final categories = await _categoryRepo.getAllCategories();
      final tags = await _tagRepo.getAllTags();
      final taskTags = await _tagRepo.getTagsForTask(widget.task.id!);
      
      setState(() {
        _categories = categories;
        _allTags = tags;
        _selectedCategory = categories.firstWhere(
          (c) => c.id == widget.task.categoryId,
          orElse: () => categories.first,
        );
        _selectedTagIds = taskTags.map((t) => t.id!).toSet();
        _originalTagIds = Set.from(_selectedTagIds);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showCreateCategoryDialog() async {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              const Text('Color', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                ].map((color) {
                  final isSelected = color == selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() => selectedColor = color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final colorHex = '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      final category = Category(
        name: nameController.text.trim(),
        color: colorHex,
      );
      final categoryId = await _categoryRepo.createCategory(category);
      final newCategory = await _categoryRepo.getCategoryById(categoryId);
      
      setState(() {
        if (newCategory != null) {
          _categories.add(newCategory);
          _selectedCategory = newCategory;
        }
      });
    }
  }

  Future<void> _showCreateTagDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Tag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final tag = await _tagRepo.getOrCreateTag(result);
      
      setState(() {
        if (!_allTags.any((t) => t.id == tag.id)) {
          _allTags.add(tag);
        }
        _selectedTagIds.add(tag.id!);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Update task
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        categoryId: _selectedCategory?.id,
      );

      await _taskRepo.updateTask(updatedTask);

      // Update tags
      // Remove tags that were deselected
      for (final tagId in _originalTagIds) {
        if (!_selectedTagIds.contains(tagId)) {
          await _taskRepo.removeTagFromTask(widget.task.id!, tagId);
        }
      }

      // Add newly selected tags
      for (final tagId in _selectedTagIds) {
        if (!_originalTagIds.contains(tagId)) {
          await _taskRepo.addTagToTask(widget.task.id!, tagId);
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: _isLoading
          ? const SizedBox(
              width: 300,
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: 300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Category>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category (optional)',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            int.parse(
                                              category.color.replaceFirst('#', '0xFF'),
                                            ),
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category.name),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (category) {
                                setState(() => _selectedCategory = category);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: _showCreateCategoryDialog,
                            icon: const Icon(Icons.add),
                            tooltip: 'New Category',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Tags (optional)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _showCreateTagDialog,
                            icon: const Icon(Icons.add, size: 18),
                            tooltip: 'New Tag',
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allTags.map((tag) {
                          final isSelected = _selectedTagIds.contains(tag.id);
                          return FilterChip(
                            label: Text(tag.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTagIds.add(tag.id!);
                                } else {
                                  _selectedTagIds.remove(tag.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
