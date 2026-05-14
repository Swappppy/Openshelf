import 'package:flutter/material.dart';
import 'dart:io';

/// A reusable book cover widget that handles both local files and network images.
/// It includes a placeholder for cases where the image is missing or fails to load.
class BookCover extends StatelessWidget {
  final String? coverUrl;
  final String? coverPath;
  final double? height;
  final double? width;
  final String? author;
  final BorderRadius? borderRadius;
  final Alignment alignment;

  const BookCover({
    super.key,
    this.coverUrl,
    this.coverPath,
    this.height,
    this.width,
    this.author,
    this.borderRadius,
    this.alignment = const Alignment(0, -0.5),
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: _buildImage(context),
    );

    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildImage(BuildContext context) {
    if (coverPath != null && coverPath!.isNotEmpty) {
      return Image.file(
        File(coverPath!),
        fit: BoxFit.cover,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => _placeholder(context),
      );
    }
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return Image.network(
        coverUrl!,
        fit: BoxFit.cover,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (author != null)
            Text(
              author!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          Icon(
            Icons.menu_book,
            color: colorScheme.outline.withValues(alpha: 0.3),
            size: 24,
          ),
        ],
      ),
    );
  }
}
