import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';

/// A wrapper widget for bulk edit form fields.
/// Places a slim lock toggle button (32px width) to the right of the field widget.
/// Supports [centerChild] to keep centered content (like cover pickers) perfectly centered on screen.
/// When locked, the field widget is disabled and opacified.
class PadlockFieldWrapper extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final ValueChanged<bool> onLockChanged;
  final String? label;
  final bool centerChild;

  const PadlockFieldWrapper({
    super.key,
    required this.child,
    required this.isLocked,
    required this.onLockChanged,
    this.label,
    this.centerChild = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLocked ? colorScheme.outline : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (centerChild) const SizedBox(width: 40),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLocked ? 0.45 : 1.0,
                  child: IgnorePointer(
                    ignoring: isLocked,
                    child: child,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: isLocked ? l10n.padlockLockedHint : l10n.padlockUnlockedHint,
                child: Container(
                  height: 56,
                  width: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isLocked
                          ? colorScheme.outlineVariant.withValues(alpha: 0.5)
                          : colorScheme.primary,
                      width: 1,
                    ),
                    color: isLocked
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                        : colorScheme.primaryContainer.withValues(alpha: 0.4),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onLockChanged(!isLocked),
                    child: Center(
                      child: Icon(
                        isLocked ? Icons.lock : Icons.lock_open,
                        size: 18,
                        color: isLocked
                            ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
