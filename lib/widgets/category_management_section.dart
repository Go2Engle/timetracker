import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/category_with_count.dart';
import '../repositories/category_repository.dart';

class CategoryManagementSection extends StatefulWidget {
  const CategoryManagementSection({super.key});

  @override
  State<CategoryManagementSection> createState() => _CategoryManagementSectionState();
}

class _CategoryManagementSectionState extends State<CategoryManagementSection> {
  final CategoryRepository _categoryRepo = CategoryRepository();
  List<CategoryWithCount> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categoriesData = await _categoryRepo.getAllCategoriesWithCount();
      setState(() {
        _categories = categoriesData
            .map((data) => CategoryWithCount.fromMap(data))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Category'),
          content: SingleChildScrollView(
            child: Column(
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
      try {
        final colorHex = '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
        final category = Category(
          name: nameController.text.trim(),
          color: colorHex,
        );
        await _categoryRepo.createCategory(category);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category created')),
          );
          _loadCategories();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating category: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditCategoryDialog(CategoryWithCount categoryWithCount) async {
    final category = categoryWithCount.category;
    final nameController = TextEditingController(text: category.name);
    Color selectedColor = _parseColor(category.color);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Category'),
          content: SingleChildScrollView(
            child: Column(
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final colorHex = '#${selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
        final updatedCategory = category.copyWith(
          name: nameController.text.trim(),
          color: colorHex,
        );
        await _categoryRepo.updateCategory(updatedCategory);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category updated')),
          );
          _loadCategories();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating category: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(CategoryWithCount categoryWithCount) async {
    if (categoryWithCount.taskCount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Delete'),
          content: Text(
            'This category is used by ${categoryWithCount.taskCount} task(s). '
            'Remove it from those tasks first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text('This action cannot be undone.'),
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
      try {
        await _categoryRepo.deleteCategory(categoryWithCount.category.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted')),
          );
          _loadCategories();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting category: $e')),
          );
        }
      }
    }
  }

  Color _parseColor(String hexColor) {
    // Remove # if present
    final hex = hexColor.replaceAll('#', '');
    // Parse hex to integer and create Color
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Categories (${_categories.length})'),
      leading: const Icon(Icons.category),
      children: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_categories.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('No categories yet'),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Category'),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              ..._categories.map((categoryWithCount) {
                final category = categoryWithCount.category;
                final color = _parseColor(category.color);
                
                return ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text(
                    categoryWithCount.taskCount == 1
                        ? '1 task'
                        : '${categoryWithCount.taskCount} tasks',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditCategoryDialog(categoryWithCount),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: categoryWithCount.taskCount > 0
                              ? Colors.grey
                              : Colors.red,
                        ),
                        onPressed: categoryWithCount.taskCount > 0
                            ? null
                            : () => _deleteCategory(categoryWithCount),
                        tooltip: categoryWithCount.taskCount > 0
                            ? 'Cannot delete - in use'
                            : 'Delete',
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Category'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
