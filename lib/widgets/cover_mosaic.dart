import 'dart:io';
import 'package:flutter/material.dart';
import '../services/database.dart';

/// A 2x2 grid display of book covers.
/// Used to represent groups of books (Shelves, Collections, etc.)
class CoverMosaic extends StatelessWidget {
  final List<Book> books;
  final double width;
  final double height;
  final double borderRadius;

  const CoverMosaic({
    super.key,
    required this.books,
    this.width = 80.0,
    this.height = 100.0,
    this.borderRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildGrid(),
    );
  }

  Widget _buildGrid() {
    if (books.isEmpty) {
      return const Center(child: Icon(Icons.library_books_outlined, size: 32, color: Colors.white10));
    }

    final hasCovers = books.where((b) => b.coverPath != null).take(4).toList();
    if (hasCovers.isEmpty) {
      return const Center(child: Icon(Icons.library_books_outlined, size: 32, color: Colors.white10));
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        if (index >= hasCovers.length) {
          return Container(color: Colors.black12);
        }
        final path = hasCovers[index].coverPath!;
        if (!File(path).existsSync()) return Container(color: Colors.black12);
        
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.black12),
        );
      },
    );
  }
}
