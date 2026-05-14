import 'package:drift/drift.dart';

/// Represents a "Smart Filter" or "Dynamic Shelf".
/// These are saved database queries that update automatically when new books match the criteria.
class Shelf extends DataClass implements Insertable<Shelf> {
  final int id;
  final String name;
  final String? filterQuery;
  final String? filterAuthor;
  final String? filterPublisher;
  final String? filterIsbn;
  final String? filterCollection;
  final String? filterStatus;
  
  /// JSON-encoded list of tag IDs to filter by.
  final String? filterTagIds;
  final int? filterImprintId;

  const Shelf({
    required this.id,
    required this.name,
    this.filterQuery,
    this.filterAuthor,
    this.filterPublisher,
    this.filterIsbn,
    this.filterCollection,
    this.filterStatus,
    this.filterTagIds,
    this.filterImprintId,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return RawValuesInsertable({
      'id': Variable<int>(id),
      'name': Variable<String>(name),
      'filter_query': Variable<String>(filterQuery),
      'filter_author': Variable<String>(filterAuthor),
      'filter_publisher': Variable<String>(filterPublisher),
      'filter_isbn': Variable<String>(filterIsbn),
      'filter_collection': Variable<String>(filterCollection),
      'filter_status': Variable<String>(filterStatus),
      'filter_tag_ids': Variable<String>(filterTagIds),
      'filter_imprint_id': Variable<int>(filterImprintId),
    }).toColumns(nullToAbsent);
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'filterQuery': serializer.toJson<String?>(filterQuery),
      'filterAuthor': serializer.toJson<String?>(filterAuthor),
      'filterPublisher': serializer.toJson<String?>(filterPublisher),
      'filterIsbn': serializer.toJson<String?>(filterIsbn),
      'filterCollection': serializer.toJson<String?>(filterCollection),
      'filterStatus': serializer.toJson<String?>(filterStatus),
      'filterTagIds': serializer.toJson<String?>(filterTagIds),
      'filterImprintId': serializer.toJson<int?>(filterImprintId),
    };
  }

  Shelf copyWith({
    int? id,
    String? name,
    String? filterQuery,
    String? filterAuthor,
    String? filterPublisher,
    String? filterIsbn,
    String? filterCollection,
    String? filterStatus,
    String? filterTagIds,
    int? filterImprintId,
    bool clearStatus = false,
    bool clearImprint = false,
  }) {
    return Shelf(
      id: id ?? this.id,
      name: name ?? this.name,
      filterQuery: filterQuery ?? this.filterQuery,
      filterAuthor: filterAuthor ?? this.filterAuthor,
      filterPublisher: filterPublisher ?? this.filterPublisher,
      filterIsbn: filterIsbn ?? this.filterIsbn,
      filterCollection: filterCollection ?? this.filterCollection,
      filterStatus: clearStatus ? null : (filterStatus ?? this.filterStatus),
      filterTagIds: filterTagIds ?? this.filterTagIds,
      filterImprintId: clearImprint ? null : (filterImprintId ?? this.filterImprintId),
    );
  }
}
