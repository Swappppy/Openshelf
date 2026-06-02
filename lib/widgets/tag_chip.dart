import 'package:flutter/material.dart';

/// A colorful chip for displaying book categories (tags).
class TagChip extends StatelessWidget {
  final String label;
  final String? colorHex;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? heroTag;

  const TagChip({
    super.key,
    required this.label,
    this.colorHex,
    this.onDeleted,
    this.onTap,
    this.onLongPress,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Parse the hex color or use the theme's secondary container as fallback.
    final color = colorHex != null 
        ? Color(int.parse('0xFF$colorHex')) 
        : theme.colorScheme.secondaryContainer;
        
    final textColor = colorHex != null 
        ? color 
        : theme.colorScheme.onSecondaryContainer;

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close,
                size: 14,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (heroTag != null) {
      content = Hero(
        tag: heroTag!,
        // To prevent text from being weird during transition
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          final Hero fromHero = fromHeroContext.widget as Hero;
          final Hero toHero = toHeroContext.widget as Hero;
          
          return Material(
            color: Colors.transparent,
            child: flightDirection == HeroFlightDirection.push 
              ? toHero.child 
              : fromHero.child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: content,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
