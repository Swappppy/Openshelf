import 'package:drift/drift.dart';

/// Represents a "Smart Filter" or "Dynamic Shelf".
/// These are saved database queries that update automatically when new books match the criteria.
class Shelf extends DataClass implements Insertable<Shelf> {
  final int id;
  final String name;
  final String? filterQuery;
  final String? filterSubtitle;
  final String? filterAuthor;
  final String? filterPublisher;
  final String? filterIsbn;
  final String? filterLanguage;
  final String? filterTranslator;
  final String? filterCollection;
  final String? filterStatus;
  
  /// JSON-encoded list of tag IDs to filter by.
  final String? filterTagIds;
  
  /// JSON-encoded list of imprint IDs to filter by.
  final String? filterImprintIds;

  const Shelf({
    required this.id,
    required this.name,
    this.filterQuery,
    this.filterSubtitle,
    this.filterAuthor,
    this.filterPublisher,
    this.filterIsbn,
    this.filterLanguage,
    this.filterTranslator,
    this.filterCollection,
    this.filterStatus,
    this.filterTagIds,
    this.filterImprintIds,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return RawValuesInsertable({
      'id': Variable<int>(id),
      'name': Variable<String>(name),
      'filter_query': Variable<String>(filterQuery),
      'filter_subtitle': Variable<String>(filterSubtitle),
      'filter_author': Variable<String>(filterAuthor),
      'filter_publisher': Variable<String>(filterPublisher),
      'filter_isbn': Variable<String>(filterIsbn),
      'filter_language': Variable<String>(filterLanguage),
      'filter_translator': Variable<String>(filterTranslator),
      'filter_collection': Variable<String>(filterCollection),
      'filter_status': Variable<String>(filterStatus),
      'filter_tag_ids': Variable<String>(filterTagIds),
      'filter_imprint_ids': Variable<String>(filterImprintIds),
    }).toColumns(nullToAbsent);
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'filterQuery': serializer.toJson<String?>(filterQuery),
      'filterSubtitle': serializer.toJson<String?>(filterSubtitle),
      'filterAuthor': serializer.toJson<String?>(filterAuthor),
      'filterPublisher': serializer.toJson<String?>(filterPublisher),
      'filterIsbn': serializer.toJson<String?>(filterIsbn),
      'filterLanguage': serializer.toJson<String?>(filterLanguage),
      'filterTranslator': serializer.toJson<String?>(filterTranslator),
      'filterCollection': serializer.toJson<String?>(filterCollection),
      'filterStatus': serializer.toJson<String?>(filterStatus),
      'filterTagIds': serializer.toJson<String?>(filterTagIds),
      'filterImprintIds': serializer.toJson<String?>(filterImprintIds),
    };
  }

  Shelf copyWith({
    int? id,
    String? name,
    String? filterQuery,
    String? filterSubtitle,
    String? filterAuthor,
    String? filterPublisher,
    String? filterIsbn,
    String? filterLanguage,
    String? filterTranslator,
    String? filterCollection,
    String? filterStatus,
    String? filterTagIds,
    String? filterImprintIds,
    bool clearStatus = false,
  }) {
    return Shelf(
      id: id ?? this.id,
      name: name ?? this.name,
      filterQuery: filterQuery ?? this.filterQuery,
      filterSubtitle: filterSubtitle ?? this.filterSubtitle,
      filterAuthor: filterAuthor ?? this.filterAuthor,
      filterPublisher: filterPublisher ?? this.filterPublisher,
      filterIsbn: filterIsbn ?? this.filterIsbn,
      filterLanguage: filterLanguage ?? this.filterLanguage,
      filterTranslator: filterTranslator ?? this.filterTranslator,
      filterCollection: filterCollection ?? this.filterCollection,
      filterStatus: clearStatus ? null : (filterStatus ?? this.filterStatus),
      filterTagIds: filterTagIds ?? this.filterTagIds,
      filterImprintIds: filterImprintIds ?? this.filterImprintIds,
    );
  }
}
