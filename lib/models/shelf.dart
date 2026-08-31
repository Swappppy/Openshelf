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
  @Deprecated('Use filterCollectionIds instead')
  final String? filterCollection;
  @Deprecated('Use ShelfTags table instead')
  final String? filterCollectionIds;
  final String? filterStatus;
  
  /// JSON-encoded list of tag IDs to filter by.
  final String? filterTagIds;
  
  /// JSON-encoded list of imprint IDs to filter by.
  final String? filterImprintIds;
  
  final bool filterNoCover;
  final String? filterBooleanQuery;
  final int filterSearchMode;
  final String? filterFormat;
  final String? filterOwnership;
  final String? filterNotes;

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
    this.filterCollectionIds,
    this.filterStatus,
    this.filterTagIds,
    this.filterImprintIds,
    this.filterNoCover = false,
    this.filterBooleanQuery,
    this.filterSearchMode = 0,
    this.filterFormat,
    this.filterOwnership,
    this.filterNotes,
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
      'filter_collection_ids': Variable<String>(filterCollectionIds),
      'filter_status': Variable<String>(filterStatus),
      'filter_tag_ids': Variable<String>(filterTagIds),
      'filter_imprint_ids': Variable<String>(filterImprintIds),
      'filter_no_cover': Variable<bool>(filterNoCover),
      'filter_boolean_query': Variable<String>(filterBooleanQuery),
      'filter_search_mode': Variable<int>(filterSearchMode),
      'filter_format': Variable<String>(filterFormat),
      'filter_ownership': Variable<String>(filterOwnership),
      'filter_notes': Variable<String>(filterNotes),
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
      'filterCollectionIds': serializer.toJson<String?>(filterCollectionIds),
      'filterStatus': serializer.toJson<String?>(filterStatus),
      'filterTagIds': serializer.toJson<String?>(filterTagIds),
      'filterImprintIds': serializer.toJson<String?>(filterImprintIds),
      'filterNoCover': serializer.toJson<bool>(filterNoCover),
      'filterBooleanQuery': serializer.toJson<String?>(filterBooleanQuery),
      'filterSearchMode': serializer.toJson<int>(filterSearchMode),
      'filterFormat': serializer.toJson<String?>(filterFormat),
      'filterOwnership': serializer.toJson<String?>(filterOwnership),
      'filterNotes': serializer.toJson<String?>(filterNotes),
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
    String? filterCollectionIds,
    String? filterStatus,
    String? filterTagIds,
    String? filterImprintIds,
    bool? filterNoCover,
    String? filterBooleanQuery,
    int? filterSearchMode,
    String? filterFormat,
    String? filterOwnership,
    String? filterNotes,
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
      filterCollectionIds: filterCollectionIds ?? this.filterCollectionIds,
      filterStatus: clearStatus ? null : (filterStatus ?? this.filterStatus),
      filterTagIds: filterTagIds ?? this.filterTagIds,
      filterImprintIds: filterImprintIds ?? this.filterImprintIds,
      filterNoCover: filterNoCover ?? this.filterNoCover,
      filterBooleanQuery: filterBooleanQuery ?? this.filterBooleanQuery,
      filterSearchMode: filterSearchMode ?? this.filterSearchMode,
      filterFormat: filterFormat ?? this.filterFormat,
      filterOwnership: filterOwnership ?? this.filterOwnership,
      filterNotes: filterNotes ?? this.filterNotes,
    );
  }
}
