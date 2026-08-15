import 'package:flutter/material.dart';

class BookRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const BookRatingBar({
    super.key,
    required this.rating,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.amber[700];
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: effectiveColor,
          size: size,
        );
      }),
    );
  }
}
