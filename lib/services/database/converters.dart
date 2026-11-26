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

/// How a book is consumed. `both` (reading + listening) is stored from the
/// start but only exposed once mixed mode is implemented.
enum MediaType {
  reading,
  audio,
  both,
}

/// Medium of a single progress entry (reading_log row).
enum ReadingMedium {
  text,
  audio,
}

enum OwnershipStatus {
  bought,
  gifted,
  borrowed,
  returned,
  sold,
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
  final bool restartNumbering;

  /// Mixed mode: where this section starts/ends in the audio, in seconds.
  /// Null means "derived" from the pages by interpolation between the
  /// nearest known anchors (see TimeMap); a value is an anchor set by the user.
  final int? startSeconds;
  final int? endSeconds;

  PaginationSegment({
    required this.startPhysical,
    required this.endPhysical,
    required this.type,
    this.offset = 0,
    this.label,
    this.color,
    this.restartNumbering = false,
    this.startSeconds,
    this.endSeconds,
  });

  PaginationSegment copyWith({
    int? startPhysical,
    int? endPhysical,
    PageNumberingType? type,
    int? offset,
    String? label,
    String? color,
    bool? restartNumbering,
    bool clearLabel = false,
    bool clearColor = false,
    int? startSeconds,
    int? endSeconds,
    bool clearStartSeconds = false,
    bool clearEndSeconds = false,
  }) {
    return PaginationSegment(
      startPhysical: startPhysical ?? this.startPhysical,
      endPhysical: endPhysical ?? this.endPhysical,
      type: type ?? this.type,
      offset: offset ?? this.offset,
      label: clearLabel ? null : (label ?? this.label),
      color: clearColor ? null : (color ?? this.color),
      restartNumbering: restartNumbering ?? this.restartNumbering,
      startSeconds: clearStartSeconds ? null : (startSeconds ?? this.startSeconds),
      endSeconds: clearEndSeconds ? null : (endSeconds ?? this.endSeconds),
    );
  }

  Map<String, dynamic> toJson() => {
    'startPhysical': startPhysical,
    'endPhysical': endPhysical,
    'type': type.name,
    'offset': offset,
    'label': label,
    'color': color,
    'restartNumbering': restartNumbering,
    if (startSeconds != null) 'startSeconds': startSeconds,
    if (endSeconds != null) 'endSeconds': endSeconds,
  };

  factory PaginationSegment.fromJson(Map<String, dynamic> json) {
    return PaginationSegment(
      startPhysical: json['startPhysical'],
      endPhysical: json['endPhysical'],
      type: PageNumberingType.values.firstWhere((e) => e.name == json['type']),
      offset: json['offset'] ?? 0,
      label: json['label'],
      color: json['color'],
      restartNumbering: json['restartNumbering'] ?? false,
      startSeconds: json['startSeconds'],
      endSeconds: json['endSeconds'],
    );
  }
}

class PaginationMarker {
  final int physicalPage;
  final String label;
  final String? color;

  /// Mixed mode: audio position anchor in seconds; null = derived from the page.
  final int? seconds;

  PaginationMarker({
    required this.physicalPage,
    required this.label,
    this.color,
    this.seconds,
  });

  Map<String, dynamic> toJson() => {
    'physicalPage': physicalPage,
    'label': label,
    'color': color,
    if (seconds != null) 'seconds': seconds,
  };

  PaginationMarker copyWith({
    int? physicalPage,
    String? label,
    String? color,
    bool clearColor = false,
    int? seconds,
    bool clearSeconds = false,
  }) {
    return PaginationMarker(
      physicalPage: physicalPage ?? this.physicalPage,
      label: label ?? this.label,
      color: clearColor ? null : (color ?? this.color),
      seconds: clearSeconds ? null : (seconds ?? this.seconds),
    );
  }

  factory PaginationMarker.fromJson(Map<String, dynamic> json) => PaginationMarker(
    physicalPage: json['physicalPage'],
    label: json['label'],
    color: json['color'],
    seconds: json['seconds'],
  );
}

typedef OnSavePaginationConfig = void Function(PaginationConfig config, Map<int, int>? segmentProgress);

class PaginationConfig {
  final List<PaginationSegment> segments;
  final List<PaginationMarker> markers;
  final bool useVisualMode;

  PaginationConfig({
    this.segments = const [],
    this.markers = const [],
    this.useVisualMode = false,
  });

  Map<String, dynamic> toJson() => {
    'segments': segments.map((s) => s.toJson()).toList(),
    'markers': markers.map((m) => m.toJson()).toList(),
    'useVisualMode': useVisualMode,
  };

  factory PaginationConfig.fromJson(Map<String, dynamic> json) => PaginationConfig(
    segments: (json['segments'] as List? ?? []).map((s) => PaginationSegment.fromJson(s)).toList(),
    markers: (json['markers'] as List? ?? []).map((m) => PaginationMarker.fromJson(m)).toList(),
    useVisualMode: json['useVisualMode'] ?? false,
  );

  PaginationConfig copyWith({
    List<PaginationSegment>? segments,
    List<PaginationMarker>? markers,
    bool? useVisualMode,
  }) {
    return PaginationConfig(
      segments: segments ?? this.segments,
      markers: markers ?? this.markers,
      useVisualMode: useVisualMode ?? this.useVisualMode,
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

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    try {
      return (jsonDecode(fromDb) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class IntMapConverter extends TypeConverter<Map<int, int>, String> {
  const IntMapConverter();

  @override
  Map<int, int> fromSql(String fromDb) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(fromDb);
      return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  @override
  String toSql(Map<int, int> value) => jsonEncode(value.map((k, v) => MapEntry(k.toString(), v)));
}
