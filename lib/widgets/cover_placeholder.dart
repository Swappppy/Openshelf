import 'package:flutter/material.dart';

class CoverPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double iconSize;

  const CoverPlaceholder({
    super.key,
    this.width = 90,
    this.height = 130,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book,
        size: iconSize,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
