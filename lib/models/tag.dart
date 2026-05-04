import 'package:flutter/material.dart';

class Tag {
  final int? id;
  final String name;
  final Color color;

  const Tag({
    this.id,
    required this.name,
    required this.color,
  });
}