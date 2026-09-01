import '../services/database.dart';
import 'package:flutter/widgets.dart';
import '../l10n/l10n_extension.dart';

enum BooleanConnector { and, or }

enum SearchMode { basic, advanced, boolean }

enum SearchField {
  title,
  subtitle,
  author,
  publisher,
  isbn,
  language,
  translator,
  originalTitle,
  originalLanguage,
  year,
  pages,
  status,
  category,
  imprint,
  collection,
  noCover,
  format,
  ownership,
  startedAt,
  finishedAt,
  notes,
  hasNotes,
}

extension SearchFieldExt on SearchField {
  String label(BuildContext context) {
    switch (this) {
      case SearchField.title: return context.l10n.searchFieldTitle;
      case SearchField.subtitle: return context.l10n.fieldSubtitle;
      case SearchField.author: return context.l10n.searchFieldAuthor;
      case SearchField.publisher: return context.l10n.searchFieldPublisher;
      case SearchField.isbn: return context.l10n.searchFieldIsbn;
      case SearchField.language: return context.l10n.searchFieldLanguage;
      case SearchField.translator: return context.l10n.fieldTranslator;
      case SearchField.originalTitle: return context.l10n.searchFieldOriginalTitle;
      case SearchField.originalLanguage: return context.l10n.searchFieldOriginalLanguage;
      case SearchField.year: return context.l10n.searchFieldYear;
      case SearchField.pages: return context.l10n.searchFieldPages;
      case SearchField.status: return context.l10n.searchFieldStatus;
      case SearchField.category: return context.l10n.searchFieldCategory;
      case SearchField.imprint: return context.l10n.searchFieldImprint;
      case SearchField.collection: return context.l10n.searchFieldCollection;
      case SearchField.noCover: return context.l10n.searchFieldNoCover;
      case SearchField.format: return context.l10n.sectionFormat;
      case SearchField.ownership: return context.l10n.fieldOwnershipStatus;
      case SearchField.startedAt: return context.l10n.bookDetailFieldStarted;
      case SearchField.finishedAt: return context.l10n.bookDetailFieldFinished;
      case SearchField.notes: return context.l10n.searchFieldNotes;
      case SearchField.hasNotes: return context.l10n.searchFieldHasNotes;
    }
  }

  List<BooleanOperator> operators() {
    switch (this) {
      case SearchField.category:
      case SearchField.imprint:
      case SearchField.collection:
        return [BooleanOperator.includes, BooleanOperator.notIncludes];
      case SearchField.year:
      case SearchField.pages:
        return [BooleanOperator.equals, BooleanOperator.notEquals, BooleanOperator.greaterThan, BooleanOperator.lessThan, BooleanOperator.between];
      case SearchField.status:
      case SearchField.noCover:
      case SearchField.hasNotes:
      case SearchField.format:
      case SearchField.ownership:
        return [BooleanOperator.equals, BooleanOperator.notEquals];
      case SearchField.startedAt:
      case SearchField.finishedAt:
        return [BooleanOperator.equals, BooleanOperator.greaterThan, BooleanOperator.lessThan];
      default:
        return [BooleanOperator.contains, BooleanOperator.exactly, BooleanOperator.startsWith];
    }
  }
}

enum BooleanOperator {
  contains,
  exactly,
  startsWith,
  includes,
  notIncludes,
  includesAll,
  equals,
  notEquals,
  greaterThan,
  lessThan,
  between,
}

extension BooleanOperatorExt on BooleanOperator {
  String label(BuildContext context) {
    switch (this) {
      case BooleanOperator.contains: return context.l10n.searchOpContains;
      case BooleanOperator.exactly: return context.l10n.searchOpExactly;
      case BooleanOperator.startsWith: return context.l10n.searchOpStartsWith;
      case BooleanOperator.includes: return context.l10n.searchOpIncludes;
      case BooleanOperator.notIncludes: return context.l10n.searchOpNotIncludes;
      case BooleanOperator.includesAll: return context.l10n.searchOpIncludesAll;
      case BooleanOperator.equals: return context.l10n.searchOpEquals;
      case BooleanOperator.notEquals: return context.l10n.searchOpNotEquals;
      case BooleanOperator.greaterThan: return context.l10n.searchOpGreaterThan;
      case BooleanOperator.lessThan: return context.l10n.searchOpLessThan;
      case BooleanOperator.between: return context.l10n.searchOpBetween;
    }
  }
}

class BooleanCondition {
  final SearchField field;
  final BooleanOperator operator;
  final dynamic value;
  final BooleanConnector? connector; // null for the first condition

  const BooleanCondition({
    required this.field,
    required this.operator,
    this.value,
    this.connector,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooleanCondition &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          operator == other.operator &&
          value == other.value &&
          connector == other.connector;

  @override
  int get hashCode => field.hashCode ^ operator.hashCode ^ value.hashCode ^ connector.hashCode;

  BooleanCondition copyWith({
    SearchField? field,
    BooleanOperator? operator,
    dynamic value,
    BooleanConnector? connector,
    bool clearConnector = false,
  }) =>
      BooleanCondition(
        field: field ?? this.field,
        operator: operator ?? this.operator,
        value: value ?? this.value,
        connector: clearConnector ? null : (connector ?? this.connector),
      );

  Map<String, dynamic> toJson() => {
        'field': field.name,
        'operator': operator.name,
        'value': value,
        'connector': connector?.name,
      };

  factory BooleanCondition.fromJson(Map<String, dynamic> json) => BooleanCondition(
        field: SearchField.values.byName(json['field']),
        operator: BooleanOperator.values.byName(json['operator']),
        value: json['value'],
        connector: json['connector'] != null ? BooleanConnector.values.byName(json['connector']) : null,
      );
}

class BooleanQuery {
  final List<BooleanCondition> conditions;

  const BooleanQuery({this.conditions = const []});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooleanQuery &&
          runtimeType == other.runtimeType &&
          _listEquals(conditions, other.conditions);

  @override
  int get hashCode => conditions.fold(0, (prev, element) => prev ^ element.hashCode);

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'conditions': conditions.map((c) => c.toJson()).toList(),
      };

  factory BooleanQuery.fromJson(Map<String, dynamic> json) => BooleanQuery(
        conditions: (json['conditions'] as List).map((c) => BooleanCondition.fromJson(c)).toList(),
      );

  BooleanQuery copyWith({List<BooleanCondition>? conditions}) =>
      BooleanQuery(conditions: conditions ?? this.conditions);
}

/// Model representing the current search and category filters.
class SearchFilters {
  final String query;
  final List<Tag> tags;
  final String author;
  final String subtitle;
  final String publisher;
  final String isbn;
  final String collection;
  final String notes;
  final String language;
  final String translator;
  final List<Tag> imprints;
  final List<Tag> collections;
  final ReadingStatus? status;
  final BookFormat? format;
  final OwnershipStatus? ownership;
  final bool? hasNotes;
  final DateTime? startedAt;
  final BooleanOperator startedAtOp;
  final DateTime? finishedAt;
  final BooleanOperator finishedAtOp;

  final SearchMode mode;
  final BooleanQuery booleanQuery;

  const SearchFilters({
    this.query = '',
    this.tags = const [],
    this.author = '',
    this.subtitle = '',
    this.publisher = '',
    this.isbn = '',
    this.collection = '',
    this.notes = '',
    this.language = '',
    this.translator = '',
    this.imprints = const [],
    this.collections = const [],
    this.status,
    this.format,
    this.ownership,
    this.hasNotes,
    this.startedAt,
    this.startedAtOp = BooleanOperator.equals,
    this.finishedAt,
    this.finishedAtOp = BooleanOperator.equals,
    this.mode = SearchMode.basic,
    this.booleanQuery = const BooleanQuery(),
  });

  bool get isEmpty =>
      query.isEmpty &&
          tags.isEmpty &&
          author.isEmpty &&
          subtitle.isEmpty &&
          publisher.isEmpty &&
          isbn.isEmpty &&
          collection.isEmpty &&
          notes.isEmpty &&
          language.isEmpty &&
          translator.isEmpty &&
          imprints.isEmpty &&
          collections.isEmpty &&
          format == null &&
          ownership == null &&
          hasNotes == null &&
          startedAt == null &&
          finishedAt == null &&
          booleanQuery.conditions.isEmpty;

  SearchFilters copyWith({
    String? query,
    List<Tag>? tags,
    String? author,
    String? subtitle,
    String? publisher,
    String? isbn,
    String? collection,
    String? notes,
    String? language,
    String? translator,
    List<Tag>? imprints,
    bool clearImprints = false,
    List<Tag>? collections,
    bool clearCollections = false,
    ReadingStatus? status,
    bool clearStatus = false,
    BookFormat? format,
    bool clearFormat = false,
    OwnershipStatus? ownership,
    bool clearOwnership = false,
    bool? hasNotes,
    bool clearHasNotes = false,
    DateTime? startedAt,
    bool clearStartedAt = false,
    BooleanOperator? startedAtOp,
    DateTime? finishedAt,
    bool clearFinishedAt = false,
    BooleanOperator? finishedAtOp,
    SearchMode? mode,
    BooleanQuery? booleanQuery,
  }) =>
      SearchFilters(
        query: query ?? this.query,
        tags: tags ?? this.tags,
        author: author ?? this.author,
        subtitle: subtitle ?? this.subtitle,
        publisher: publisher ?? this.publisher,
        isbn: isbn ?? this.isbn,
        collection: collection ?? this.collection,
        notes: notes ?? this.notes,
        language: language ?? this.language,
        translator: translator ?? this.translator,
        imprints: clearImprints ? [] : (imprints ?? this.imprints),
        collections: clearCollections ? [] : (collections ?? this.collections),
        status: clearStatus ? null : (status ?? this.status),
        format: clearFormat ? null : (format ?? this.format),
        ownership: clearOwnership ? null : (ownership ?? this.ownership),
        hasNotes: clearHasNotes ? null : (hasNotes ?? this.hasNotes),
        startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
        startedAtOp: startedAtOp ?? this.startedAtOp,
        finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
        finishedAtOp: finishedAtOp ?? this.finishedAtOp,
        mode: mode ?? this.mode,
        booleanQuery: booleanQuery ?? this.booleanQuery,
      );

  /// Converts the current flat filters to a BooleanQuery for a seamless transition.
  BooleanQuery toBooleanQuery() {
    final List<BooleanCondition> conditions = [];

    void add(SearchField field, BooleanOperator op, dynamic val) {
      conditions.add(BooleanCondition(
        field: field,
        operator: op,
        value: val,
        connector: conditions.isEmpty ? null : BooleanConnector.and,
      ));
    }

    if (query.isNotEmpty) add(SearchField.title, BooleanOperator.contains, query);
    if (author.isNotEmpty) add(SearchField.author, BooleanOperator.contains, author);
    if (subtitle.isNotEmpty) add(SearchField.subtitle, BooleanOperator.contains, subtitle);
    if (publisher.isNotEmpty) add(SearchField.publisher, BooleanOperator.contains, publisher);
    if (isbn.isNotEmpty) add(SearchField.isbn, BooleanOperator.contains, isbn);
    if (notes.isNotEmpty) add(SearchField.notes, BooleanOperator.contains, notes);
    if (hasNotes == true) add(SearchField.hasNotes, BooleanOperator.equals, true);
    if (hasNotes == false) add(SearchField.hasNotes, BooleanOperator.equals, false);
    if (startedAt != null) add(SearchField.startedAt, startedAtOp, startedAt!.toIso8601String());
    if (finishedAt != null) add(SearchField.finishedAt, finishedAtOp, finishedAt!.toIso8601String());
    if (language.isNotEmpty) add(SearchField.language, BooleanOperator.exactly, language);
    if (translator.isNotEmpty) add(SearchField.translator, BooleanOperator.contains, translator);
    if (status != null) add(SearchField.status, BooleanOperator.equals, status!.name);
    if (format != null) add(SearchField.format, BooleanOperator.equals, format!.name);
    if (ownership != null) add(SearchField.ownership, BooleanOperator.equals, ownership!.name);
    
    for (final tag in tags) {
      add(SearchField.category, BooleanOperator.includes, tag.id);
    }
    for (final imprint in imprints) {
      add(SearchField.imprint, BooleanOperator.includes, imprint.id);
    }
    for (final col in collections) {
      add(SearchField.collection, BooleanOperator.includes, col.id);
    }

    return BooleanQuery(conditions: conditions);
  }
}
