import 'dart:io';
import 'package:flutter/material.dart';

/// A unified, reusable grid box for selection criteria (Categories, Imprints, Collections).
/// Supports specific aesthetics for each type:
/// - Categories: Color-based with subtle tints.
/// - Imprints: Image/Initials-based branding.
/// - Collections: Clean text-only aesthetic.
class FilterGridBox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final String? imagePath;
  final bool isImprint;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FilterGridBox({
    super.key,
    required this.label,
    required this.isSelected,
    this.color,
    this.imagePath,
    this.isImprint = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.white70;
    final hasColor = color != null;

    // Determine colors based on category aesthetic (hasColor) vs generic aesthetic
    final Color bgColor = isSelected 
        ? (hasColor ? baseColor.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.2))
        : (hasColor ? baseColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05));
        
    final Color borderColor = isSelected 
        ? (hasColor ? baseColor.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.5))
        : (hasColor ? baseColor.withValues(alpha: 0.3) : Colors.white10);
        
    final Color textColor = isSelected 
        ? Colors.white 
        : (hasColor ? baseColor : Colors.white60);

    return IntrinsicWidth(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display image or initials placeholder ONLY for Imprints (Sellos)
              if (isImprint) ...[
                 ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: (imagePath != null && File(imagePath!).existsSync())
                    ? Image.file(
                        File(imagePath!),
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _initialsPlaceholder(label),
                      )
                    : _initialsPlaceholder(label),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsPlaceholder(String name) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(3)
        .map((w) => w[0].toUpperCase())
        .join('');
        
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        initials,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white38),
      ),
    );
  }
}
