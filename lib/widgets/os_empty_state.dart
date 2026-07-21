import 'package:flutter/material.dart';
import 'bookshelf_icon.dart';

/// A redesigned reusable widget for displaying empty states across the app,
/// matching the v1.0 premium aesthetic with glowing containers, breathing animations,
/// and integrated actions.
class OsEmptyState extends StatefulWidget {
  final Widget? iconWidget; // Custom widget for icon (like the app logo)
  final IconData? icon;
  final String message;
  final String? subtitle;
  final String? actionLabel;
  final IconData? actionIcon; // Customizable action icon
  final VoidCallback? onActionPressed;
  final Color? accentColor;

  const OsEmptyState({
    super.key,
    this.iconWidget,
    this.icon,
    required this.message,
    this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onActionPressed,
    this.accentColor,
  });

  @override
  State<OsEmptyState> createState() => _OsEmptyStateState();
}

class _OsEmptyStateState extends State<OsEmptyState> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveAccentColor = widget.accentColor ?? colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60), // Space for onboarding dots or extra breathing room
                child: Column(
                  children: [
                    const Spacer(flex: 3), 
                    
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_floatingAnimation.value),
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Aura
                          Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  effectiveAccentColor.withValues(alpha: 0.25),
                                  effectiveAccentColor.withValues(alpha: 0.1),
                                  effectiveAccentColor.withValues(alpha: 0.02),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3, 0.6, 1.0],
                              ),
                            ),
                          ),
                          
                          // Icon Container
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark 
                                  ? Colors.black.withValues(alpha: 0.4) 
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: effectiveAccentColor.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: effectiveAccentColor.withValues(alpha: 0.15),
                                  blurRadius: 25,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: widget.iconWidget ?? Icon(
                                widget.icon,
                                size: 48,
                                color: effectiveAccentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          Text(
                            widget.message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif',
                            ),
                          ),
                          
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              widget.subtitle!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                height: 1.4,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          
                          if (widget.actionLabel != null && widget.onActionPressed != null) ...[
                            const SizedBox(height: 40),
                            FilledButton(
                              onPressed: widget.onActionPressed,
                              style: FilledButton.styleFrom(
                                backgroundColor: effectiveAccentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 10,
                                shadowColor: effectiveAccentColor.withValues(alpha: 0.4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(widget.actionIcon ?? Icons.add, size: 18),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.actionLabel!,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(flex: 5),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A custom widget that draws the Openshelf logo using the [BookshelfIcon] painter style.
class OpenshelfLogoIcon extends StatelessWidget {
  final double size;
  final Color color;

  const OpenshelfLogoIcon({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BookshelfIcon(
      size: size,
      accentColor: color,
    );
  }
}
