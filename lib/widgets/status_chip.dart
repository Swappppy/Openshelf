import 'package:flutter/material.dart';
import '../models/book.dart';

class StatusChip extends StatelessWidget {
  final ReadingStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        _label(status),
        style: TextStyle(
          fontSize: 11,
          color: _color(status),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _color(status).withOpacity(0.12),
      side: BorderSide(color: _color(status).withOpacity(0.3)),
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