import 'package:flutter/material.dart';
import 'stats_scale_helper.dart';

class WidgetHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const WidgetHeader({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = StatsScaleHelper.getScale(constraints);
        
        return Row(
          children: [
            Icon(
              icon, 
              size: 14 * scale.clamp(1.0, 1.5), 
              color: theme.colorScheme.outline
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title, 
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 9 * scale.clamp(1.0, 1.5),
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ?trailing,
          ],
        );
      }
    );
  }
}
