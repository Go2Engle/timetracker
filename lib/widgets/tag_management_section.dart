import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../models/tag_with_count.dart';
import '../repositories/tag_repository.dart';

class TagManagementSection extends StatefulWidget {
  const TagManagementSection({super.key});

  @override
  State<TagManagementSection> createState() => _TagManagementSectionState();
}

class _TagManagementSectionState extends State<TagManagementSection> {
  final TagRepository _tagRepo = TagRepository();
  List<TagWithCount> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    try {
      final tagsData = await _tagRepo.getAllTagsWithCount();
      setState(() {
        _tags = tagsData
            .map((data) => TagWithCount.fromMap(data))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tags: $e')),
        );
      }
    }
  }

  Future<void> _showAddTagDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Tag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final tag = Tag(name: nameController.text.trim());
        await _tagRepo.createTag(tag);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tag created')),
          );
          _loadTags();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating tag: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditTagDialog(TagWithCount tagWithCount) async {
    final tag = tagWithCount.tag;
    final nameController = TextEditingController(text: tag.name);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
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
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final updatedTag = tag.copyWith(name: nameController.text.trim());
        await _tagRepo.updateTag(updatedTag);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tag updated')),
          );
          _loadTags();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating tag: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteTag(TagWithCount tagWithCount) async {
    if (tagWithCount.taskCount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Delete'),
          content: Text(
            'This tag is used by ${tagWithCount.taskCount} task(s). '
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
        title: const Text('Delete Tag?'),
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
        await _tagRepo.deleteTag(tagWithCount.tag.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tag deleted')),
          );
          _loadTags();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting tag: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Tags (${_tags.length})'),
      leading: const Icon(Icons.label),
      children: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_tags.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('No tags yet'),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _showAddTagDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tag'),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              ..._tags.map((tagWithCount) {
                final tag = tagWithCount.tag;
                
                return ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(tag.name),
                  subtitle: Text(
                    tagWithCount.taskCount == 1
                        ? '1 task'
                        : '${tagWithCount.taskCount} tasks',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditTagDialog(tagWithCount),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: tagWithCount.taskCount > 0
                              ? Colors.grey
                              : Colors.red,
                        ),
                        onPressed: tagWithCount.taskCount > 0
                            ? null
                            : () => _deleteTag(tagWithCount),
                        tooltip: tagWithCount.taskCount > 0
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
                  onPressed: _showAddTagDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tag'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
