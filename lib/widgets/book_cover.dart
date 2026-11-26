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
      return AdaptiveCoverImage(
        image: FileImage(File(coverPath!)),
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => _placeholder(context),
      );
    }
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return AdaptiveCoverImage(
        image: NetworkImage(coverUrl!),
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

/// Cover image that fills the 2:3 frame for portrait covers and letterboxes
/// square-ish ones (audiobooks, some print editions): full width, centered,
/// with the frame's background above and below. The frame never changes.
class AdaptiveCoverImage extends StatefulWidget {
  final ImageProvider image;
  final Alignment alignment;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Width/height ratio from which a cover is letterboxed instead of cropped.
  /// A 2:3 cover is 0.67; a square one is 1.0.
  static const letterboxFromRatio = 0.8;

  const AdaptiveCoverImage({
    super.key,
    required this.image,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  State<AdaptiveCoverImage> createState() => _AdaptiveCoverImageState();
}

class _AdaptiveCoverImageState extends State<AdaptiveCoverImage> {
  ImageStream? _stream;
  late final ImageStreamListener _listener = ImageStreamListener(_onImage, onError: (_, _) {});
  bool _letterbox = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(AdaptiveCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _resolve();
  }

  void _resolve() {
    final stream = widget.image.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _onImage(ImageInfo info, bool _) {
    final ratio = info.image.width / info.image.height;
    final letterbox = ratio >= AdaptiveCoverImage.letterboxFromRatio;
    if (mounted && letterbox != _letterbox) setState(() => _letterbox = letterbox);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.image,
      width: widget.width,
      height: widget.height,
      fit: _letterbox ? BoxFit.fitWidth : BoxFit.cover,
      alignment: _letterbox ? Alignment.center : widget.alignment,
      errorBuilder: widget.errorBuilder,
    );
  }
}
