import 'package:flutter/material.dart';
import '../../../l10n/l10n_extension.dart';

/// A wrapper widget for bulk edit form fields.
/// Controls locking/unlocking of a field using the Padlock pattern.
/// When locked, the child widget is disabled and greyed out.
class PadlockFieldWrapper extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final ValueChanged<bool> onLockChanged;
  final String? label;

  const PadlockFieldWrapper({
    super.key,
    required this.child,
    required this.isLocked,
    required this.onLockChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLocked
                          ? colorScheme.outline
                          : colorScheme.onSurface,
                    ),
                  ),
                )
              else
                const Spacer(),
              Tooltip(
                message: isLocked ? l10n.padlockLockedHint : l10n.padlockUnlockedHint,
                child: IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: isLocked
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                        : colorScheme.primaryContainer,
                    foregroundColor: isLocked
                        ? colorScheme.outline
                        : colorScheme.primary,
                  ),
                  icon: Icon(
                    isLocked ? Icons.lock : Icons.lock_open,
                    size: 20,
                  ),
                  onPressed: () => onLockChanged(!isLocked),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isLocked ? 0.45 : 1.0,
            child: IgnorePointer(
              ignoring: isLocked,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
