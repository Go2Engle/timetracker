import 'package:flutter/material.dart';
import '../models/category.dart';

/// A visual badge/chip displaying a category with its color
class CategoryBadge extends StatelessWidget {
  final Category? category;
  final VoidCallback? onTap;
  final bool showName;
  final double size;

  const CategoryBadge({
    super.key,
    required this.category,
    this.onTap,
    this.showName = true,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      if (!showName) return const SizedBox.shrink();
      
      return Tooltip(
        message: 'Uncategorized',
        child: Chip(
          label: const Text('Uncategorized'),
          labelStyle: TextStyle(fontSize: size * 0.7),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    final color = _parseColor(category!.color);

    if (showName) {
      // Show as a chip with color indicator and name
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Chip(
          avatar: CircleAvatar(
            backgroundColor: color,
            radius: size * 0.6,
          ),
          label: Text(category!.name),
          labelStyle: TextStyle(fontSize: size * 0.7),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    } else {
      // Show only colored circle badge
      return Tooltip(
        message: category!.name,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
      );
    }
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present
      final hex = colorString.replaceAll('#', '');
      
      // Parse hex color (supports both RGB and ARGB)
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      // Fallback to grey if parsing fails
      return Colors.grey;
    }
    
    return Colors.grey;
  }
}
