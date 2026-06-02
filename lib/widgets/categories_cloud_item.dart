import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database.dart';
import '../controllers/display_preferences_controller.dart';
import '../views/shelves/shelf_books_view.dart';

class CategoriesCloudItem extends ConsumerWidget {
  final Tag tag;
  final int count;
  final int maxCount;
  final VoidCallback onLongPress;
  
  const CategoriesCloudItem({
    super.key,
    required this.tag, 
    required this.count,
    required this.maxCount,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final p = ref.watch(displayPreferencesProvider);
    
    // Logarithmic scaling: X books = 100% of max allowed size (~1.4 max).
    // X is defined by p.tagCloudMaxCount
    final logCount = math.log(count + 1);
    final logRef = math.log(p.tagCloudMaxCount + 1);
    final double logFactor = (logCount / logRef).clamp(0.0, 1.0);
    
    final double scale = 0.85 + (logFactor * 0.55);
    final double fontSize = 10 * scale;
    final double horizontalPadding = 8 * scale;
    final double verticalPadding = 4 * scale;

    final baseColor = (tag.color != null && tag.color!.length == 6)
        ? Color(int.parse('0xFF${tag.color!}')) 
        : colorScheme.secondaryContainer;
        
    final textColor = (tag.color != null && tag.color!.isNotEmpty && tag.color!.toLowerCase() != 'null')
        ? baseColor 
        : colorScheme.onSecondaryContainer;

    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => TagBooksView(tag: tag)),
      ),
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, 
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4 * scale),
          border: Border.all(
            color: baseColor.withValues(alpha: count > 0 ? 0.4 : 0.1),
            width: 0.5 * scale,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.name,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: count > (maxCount / 2) ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: fontSize * 0.8,
                  fontWeight: FontWeight.bold,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
