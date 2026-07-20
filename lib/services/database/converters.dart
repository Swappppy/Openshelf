import 'dart:convert';
import 'package:drift/drift.dart';

enum ReadingStatus {
  wantToRead,
  reading,
  read,
  abandoned,
  paused,
}

enum BookFormat {
  paperback,
  hardcover,
  leatherbound,
  rustic,
  digital,
  other,
}

/// Converts between BookFormat enum and String for DB storage
class BookFormatConverter extends TypeConverter<BookFormat?, String?> {
  const BookFormatConverter();

  @override
  BookFormat? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    return BookFormat.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => BookFormat.other,
    );
  }

  @override
  String? toSql(BookFormat? value) => value?.name;
}

enum PageNumberingType {
  arabic,
  roman,
}

class PaginationSegment {
  final int startPhysical;
  final int endPhysical;
  final PageNumberingType type;
  final int offset;
  final String? label;
  final String? color;

  PaginationSegment({
    required this.startPhysical,
    required this.endPhysical,
    required this.type,
    this.offset = 0,
    this.label,
    this.color,
  });

  PaginationSegment copyWith({
    int? startPhysical,
    int? endPhysical,
    PageNumberingType? type,
    int? offset,
    String? label,
    String? color,
  }) {
    return PaginationSegment(
      startPhysical: startPhysical ?? this.startPhysical,
      endPhysical: endPhysical ?? this.endPhysical,
      type: type ?? this.type,
      offset: offset ?? this.offset,
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
    'startPhysical': startPhysical,
    'endPhysical': endPhysical,
    'type': type.name,
    'offset': offset,
    'label': label,
    'color': color,
  };

  factory PaginationSegment.fromJson(Map<String, dynamic> json) {
    return PaginationSegment(
      startPhysical: json['startPhysical'],
      endPhysical: json['endPhysical'],
      type: PageNumberingType.values.firstWhere((e) => e.name == json['type']),
      offset: json['offset'] ?? 0,
      label: json['label'],
      color: json['color'],
    );
  }
}

class PaginationMarker {
  final int physicalPage;
  final String label;
  final String? color;

  PaginationMarker({
    required this.physicalPage,
    required this.label,
    this.color,
  });

  Map<String, dynamic> toJson() => {
    'physicalPage': physicalPage,
    'label': label,
    'color': color,
  };

  factory PaginationMarker.fromJson(Map<String, dynamic> json) => PaginationMarker(
    physicalPage: json['physicalPage'],
    label: json['label'],
    color: json['color'],
  );
}

class PaginationConfig {
  final List<PaginationSegment> segments;
  final List<PaginationMarker> markers;

  PaginationConfig({
    this.segments = const [],
    this.markers = const [],
  });

  Map<String, dynamic> toJson() => {
    'segments': segments.map((s) => s.toJson()).toList(),
    'markers': markers.map((m) => m.toJson()).toList(),
  };

  factory PaginationConfig.fromJson(Map<String, dynamic> json) => PaginationConfig(
    segments: (json['segments'] as List? ?? []).map((s) => PaginationSegment.fromJson(s)).toList(),
    markers: (json['markers'] as List? ?? []).map((m) => PaginationMarker.fromJson(m)).toList(),
  );

  PaginationConfig copyWith({
    List<PaginationSegment>? segments,
    List<PaginationMarker>? markers,
  }) {
    return PaginationConfig(
      segments: segments ?? this.segments,
      markers: markers ?? this.markers,
    );
  }
}

class PaginationConfigConverter extends TypeConverter<PaginationConfig, String> {
  const PaginationConfigConverter();

  @override
  PaginationConfig fromSql(String fromDb) {
    try {
      return PaginationConfig.fromJson(jsonDecode(fromDb));
    } catch (_) {
      return PaginationConfig();
    }
  }

  @override
  String toSql(PaginationConfig value) => jsonEncode(value.toJson());
}
