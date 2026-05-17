import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database.dart';

/// A horizontal sequence of up to 3 book covers.
/// The first two are fully visible, and the third fades out towards the right.
class CoverStackFade extends StatelessWidget {
  final List<Book> books;
  final double height;
  final double borderRadius;

  const CoverStackFade({
    super.key,
    required this.books,
    this.height = 60.0,
    this.borderRadius = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final hasCovers = books.where((b) => b.coverPath != null).take(3).toList();
    
    if (hasCovers.isEmpty) {
      return Container(
        width: height * 0.7,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Icon(Icons.library_books_outlined, size: 24, color: Colors.white10),
      );
    }

    final double coverWidth = height * 0.65; // Balanced 2:3-ish ratio for icons

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(hasCovers.length, (index) {
        final path = hasCovers[index].coverPath!;
        final isThird = index == 2;
        
        Widget cover = Container(
          width: coverWidth,
          height: height,
          margin: EdgeInsets.only(right: isThird ? 0 : 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 3,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: File(path).existsSync()
              ? Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.black12),
                )
              : Container(color: Colors.black12),
        );

        if (isThird) {
          return ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: cover,
          );
        }
        
        return cover;
      }),
    );
  }
}
