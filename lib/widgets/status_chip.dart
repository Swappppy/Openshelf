import 'package:flutter/material.dart';
import '../services/database.dart';

class StatusChip extends StatelessWidget {
  final ReadingStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          _label(status),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1,
          ),
        ),
      ),
    );
  }

  String _label(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return 'Por leer';
      case ReadingStatus.reading:
        return 'Leyendo';
      case ReadingStatus.read:
        return 'Leído';
      case ReadingStatus.abandoned:
        return 'Abandonado';
    }
  }

  Color _color(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.wantToRead:
        return Colors.orange;
      case ReadingStatus.reading:
        return Colors.blue;
      case ReadingStatus.read:
        return Colors.green;
      case ReadingStatus.abandoned:
        return Colors.red;
    }
  }
}