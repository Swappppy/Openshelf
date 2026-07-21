// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TagType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('tag'),
      ).withConverter<TagType>($TagsTable.$convertertype);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, color, imagePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $TagsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }

  static TypeConverter<TagType, String> $convertertype =
      const TagTypeConverter();
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;

  /// Type can be 'tag' (category), 'imprint', or 'collection'
  final TagType type;
  final String? color;
  final String? imagePath;
  const Tag({
    required this.id,
    required this.name,
    required this.type,
    this.color,
    this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($TagsTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<TagType>(json['type']),
      color: serializer.fromJson<String?>(json['color']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<TagType>(type),
      'color': serializer.toJson<String?>(color),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  Tag copyWith({
    int? id,
    String? name,
    TagType? type,
    Value<String?> color = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    color: color.present ? color.value : this.color,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, color, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.color == this.color &&
          other.imagePath == this.imagePath);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<TagType> type;
  final Value<String?> color;
  final Value<String?> imagePath;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.imagePath = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.imagePath = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? color,
    Expression<String>? imagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (imagePath != null) 'image_path': imagePath,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<TagType>? type,
    Value<String?>? color,
    Value<String?>? imagePath,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TagsTable.$convertertype.toSql(type.value),
      );
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translatorMeta = const VerificationMeta(
    'translator',
  );
  @override
  late final GeneratedColumn<String> translator = GeneratedColumn<String>(
    'translator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReadingStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReadingStatus>($BooksTable.$converterstatus);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BookFormat?, String> bookFormat =
      GeneratedColumn<String>(
        'book_format',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<BookFormat?>($BooksTable.$converterbookFormat);
  static const VerificationMeta _collectionNameMeta = const VerificationMeta(
    'collectionName',
  );
  @override
  late final GeneratedColumn<String> collectionName = GeneratedColumn<String>(
    'collection_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectionNumberMeta = const VerificationMeta(
    'collectionNumber',
  );
  @override
  late final GeneratedColumn<int> collectionNumber = GeneratedColumn<int>(
    'collection_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishYearMeta = const VerificationMeta(
    'publishYear',
  );
  @override
  late final GeneratedColumn<int> publishYear = GeneratedColumn<int>(
    'publish_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _imprintIdMeta = const VerificationMeta(
    'imprintId',
  );
  @override
  late final GeneratedColumn<int> imprintId = GeneratedColumn<int>(
    'imprint_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _copiesMeta = const VerificationMeta('copies');
  @override
  late final GeneratedColumn<int> copies = GeneratedColumn<int>(
    'copies',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaginationConfig?, String>
  paginationConfig = GeneratedColumn<String>(
    'pagination_config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<PaginationConfig?>($BooksTable.$converterpaginationConfign);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    subtitle,
    author,
    isbn,
    language,
    translator,
    publisher,
    coverUrl,
    totalPages,
    currentPage,
    status,
    rating,
    bookFormat,
    collectionName,
    collectionNumber,
    coverPath,
    notes,
    description,
    publishYear,
    collectionId,
    imprintId,
    startedAt,
    finishedAt,
    copies,
    paginationConfig,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('translator')) {
      context.handle(
        _translatorMeta,
        translator.isAcceptableOrUnknown(data['translator']!, _translatorMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('collection_name')) {
      context.handle(
        _collectionNameMeta,
        collectionName.isAcceptableOrUnknown(
          data['collection_name']!,
          _collectionNameMeta,
        ),
      );
    }
    if (data.containsKey('collection_number')) {
      context.handle(
        _collectionNumberMeta,
        collectionNumber.isAcceptableOrUnknown(
          data['collection_number']!,
          _collectionNumberMeta,
        ),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('publish_year')) {
      context.handle(
        _publishYearMeta,
        publishYear.isAcceptableOrUnknown(
          data['publish_year']!,
          _publishYearMeta,
        ),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('imprint_id')) {
      context.handle(
        _imprintIdMeta,
        imprintId.isAcceptableOrUnknown(data['imprint_id']!, _imprintIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('copies')) {
      context.handle(
        _copiesMeta,
        copies.isAcceptableOrUnknown(data['copies']!, _copiesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      translator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translator'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      ),
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      ),
      status: $BooksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      bookFormat: $BooksTable.$converterbookFormat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}book_format'],
        ),
      ),
      collectionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_name'],
      ),
      collectionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_number'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      publishYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publish_year'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      ),
      imprintId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imprint_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      copies: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}copies'],
      )!,
      paginationConfig: $BooksTable.$converterpaginationConfign.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pagination_config'],
        ),
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReadingStatus, String, String> $converterstatus =
      const EnumNameConverter<ReadingStatus>(ReadingStatus.values);
  static TypeConverter<BookFormat?, String?> $converterbookFormat =
      const BookFormatConverter();
  static TypeConverter<PaginationConfig, String> $converterpaginationConfig =
      const PaginationConfigConverter();
  static TypeConverter<PaginationConfig?, String?> $converterpaginationConfign =
      NullAwareTypeConverter.wrap($converterpaginationConfig);
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String? subtitle;
  final String author;
  final String? isbn;
  final String? language;
  final String? translator;
  final String? publisher;
  final String? coverUrl;
  final int? totalPages;
  final int? currentPage;
  final ReadingStatus status;
  final double? rating;
  final BookFormat? bookFormat;
  final String? collectionName;
  final int? collectionNumber;
  final String? coverPath;
  final String? notes;
  final String? description;
  final int? publishYear;
  final int? collectionId;
  final int? imprintId;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int copies;
  final PaginationConfig? paginationConfig;
  final DateTime createdAt;
  const Book({
    required this.id,
    required this.title,
    this.subtitle,
    required this.author,
    this.isbn,
    this.language,
    this.translator,
    this.publisher,
    this.coverUrl,
    this.totalPages,
    this.currentPage,
    required this.status,
    this.rating,
    this.bookFormat,
    this.collectionName,
    this.collectionNumber,
    this.coverPath,
    this.notes,
    this.description,
    this.publishYear,
    this.collectionId,
    this.imprintId,
    this.startedAt,
    this.finishedAt,
    required this.copies,
    this.paginationConfig,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || translator != null) {
      map['translator'] = Variable<String>(translator);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || totalPages != null) {
      map['total_pages'] = Variable<int>(totalPages);
    }
    if (!nullToAbsent || currentPage != null) {
      map['current_page'] = Variable<int>(currentPage);
    }
    {
      map['status'] = Variable<String>(
        $BooksTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    if (!nullToAbsent || bookFormat != null) {
      map['book_format'] = Variable<String>(
        $BooksTable.$converterbookFormat.toSql(bookFormat),
      );
    }
    if (!nullToAbsent || collectionName != null) {
      map['collection_name'] = Variable<String>(collectionName);
    }
    if (!nullToAbsent || collectionNumber != null) {
      map['collection_number'] = Variable<int>(collectionNumber);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || publishYear != null) {
      map['publish_year'] = Variable<int>(publishYear);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<int>(collectionId);
    }
    if (!nullToAbsent || imprintId != null) {
      map['imprint_id'] = Variable<int>(imprintId);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['copies'] = Variable<int>(copies);
    if (!nullToAbsent || paginationConfig != null) {
      map['pagination_config'] = Variable<String>(
        $BooksTable.$converterpaginationConfign.toSql(paginationConfig),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      author: Value(author),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      translator: translator == null && nullToAbsent
          ? const Value.absent()
          : Value(translator),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      totalPages: totalPages == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPages),
      currentPage: currentPage == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPage),
      status: Value(status),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      bookFormat: bookFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(bookFormat),
      collectionName: collectionName == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionName),
      collectionNumber: collectionNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionNumber),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      publishYear: publishYear == null && nullToAbsent
          ? const Value.absent()
          : Value(publishYear),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      imprintId: imprintId == null && nullToAbsent
          ? const Value.absent()
          : Value(imprintId),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      copies: Value(copies),
      paginationConfig: paginationConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(paginationConfig),
      createdAt: Value(createdAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      author: serializer.fromJson<String>(json['author']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      language: serializer.fromJson<String?>(json['language']),
      translator: serializer.fromJson<String?>(json['translator']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      totalPages: serializer.fromJson<int?>(json['totalPages']),
      currentPage: serializer.fromJson<int?>(json['currentPage']),
      status: $BooksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      rating: serializer.fromJson<double?>(json['rating']),
      bookFormat: serializer.fromJson<BookFormat?>(json['bookFormat']),
      collectionName: serializer.fromJson<String?>(json['collectionName']),
      collectionNumber: serializer.fromJson<int?>(json['collectionNumber']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      notes: serializer.fromJson<String?>(json['notes']),
      description: serializer.fromJson<String?>(json['description']),
      publishYear: serializer.fromJson<int?>(json['publishYear']),
      collectionId: serializer.fromJson<int?>(json['collectionId']),
      imprintId: serializer.fromJson<int?>(json['imprintId']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      copies: serializer.fromJson<int>(json['copies']),
      paginationConfig: serializer.fromJson<PaginationConfig?>(
        json['paginationConfig'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'author': serializer.toJson<String>(author),
      'isbn': serializer.toJson<String?>(isbn),
      'language': serializer.toJson<String?>(language),
      'translator': serializer.toJson<String?>(translator),
      'publisher': serializer.toJson<String?>(publisher),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'totalPages': serializer.toJson<int?>(totalPages),
      'currentPage': serializer.toJson<int?>(currentPage),
      'status': serializer.toJson<String>(
        $BooksTable.$converterstatus.toJson(status),
      ),
      'rating': serializer.toJson<double?>(rating),
      'bookFormat': serializer.toJson<BookFormat?>(bookFormat),
      'collectionName': serializer.toJson<String?>(collectionName),
      'collectionNumber': serializer.toJson<int?>(collectionNumber),
      'coverPath': serializer.toJson<String?>(coverPath),
      'notes': serializer.toJson<String?>(notes),
      'description': serializer.toJson<String?>(description),
      'publishYear': serializer.toJson<int?>(publishYear),
      'collectionId': serializer.toJson<int?>(collectionId),
      'imprintId': serializer.toJson<int?>(imprintId),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'copies': serializer.toJson<int>(copies),
      'paginationConfig': serializer.toJson<PaginationConfig?>(
        paginationConfig,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    Value<String?> subtitle = const Value.absent(),
    String? author,
    Value<String?> isbn = const Value.absent(),
    Value<String?> language = const Value.absent(),
    Value<String?> translator = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<int?> totalPages = const Value.absent(),
    Value<int?> currentPage = const Value.absent(),
    ReadingStatus? status,
    Value<double?> rating = const Value.absent(),
    Value<BookFormat?> bookFormat = const Value.absent(),
    Value<String?> collectionName = const Value.absent(),
    Value<int?> collectionNumber = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> publishYear = const Value.absent(),
    Value<int?> collectionId = const Value.absent(),
    Value<int?> imprintId = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    int? copies,
    Value<PaginationConfig?> paginationConfig = const Value.absent(),
    DateTime? createdAt,
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    author: author ?? this.author,
    isbn: isbn.present ? isbn.value : this.isbn,
    language: language.present ? language.value : this.language,
    translator: translator.present ? translator.value : this.translator,
    publisher: publisher.present ? publisher.value : this.publisher,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    totalPages: totalPages.present ? totalPages.value : this.totalPages,
    currentPage: currentPage.present ? currentPage.value : this.currentPage,
    status: status ?? this.status,
    rating: rating.present ? rating.value : this.rating,
    bookFormat: bookFormat.present ? bookFormat.value : this.bookFormat,
    collectionName: collectionName.present
        ? collectionName.value
        : this.collectionName,
    collectionNumber: collectionNumber.present
        ? collectionNumber.value
        : this.collectionNumber,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    notes: notes.present ? notes.value : this.notes,
    description: description.present ? description.value : this.description,
    publishYear: publishYear.present ? publishYear.value : this.publishYear,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    imprintId: imprintId.present ? imprintId.value : this.imprintId,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    copies: copies ?? this.copies,
    paginationConfig: paginationConfig.present
        ? paginationConfig.value
        : this.paginationConfig,
    createdAt: createdAt ?? this.createdAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      author: data.author.present ? data.author.value : this.author,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      language: data.language.present ? data.language.value : this.language,
      translator: data.translator.present
          ? data.translator.value
          : this.translator,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      status: data.status.present ? data.status.value : this.status,
      rating: data.rating.present ? data.rating.value : this.rating,
      bookFormat: data.bookFormat.present
          ? data.bookFormat.value
          : this.bookFormat,
      collectionName: data.collectionName.present
          ? data.collectionName.value
          : this.collectionName,
      collectionNumber: data.collectionNumber.present
          ? data.collectionNumber.value
          : this.collectionNumber,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      description: data.description.present
          ? data.description.value
          : this.description,
      publishYear: data.publishYear.present
          ? data.publishYear.value
          : this.publishYear,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      imprintId: data.imprintId.present ? data.imprintId.value : this.imprintId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      copies: data.copies.present ? data.copies.value : this.copies,
      paginationConfig: data.paginationConfig.present
          ? data.paginationConfig.value
          : this.paginationConfig,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('author: $author, ')
          ..write('isbn: $isbn, ')
          ..write('language: $language, ')
          ..write('translator: $translator, ')
          ..write('publisher: $publisher, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('totalPages: $totalPages, ')
          ..write('currentPage: $currentPage, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('bookFormat: $bookFormat, ')
          ..write('collectionName: $collectionName, ')
          ..write('collectionNumber: $collectionNumber, ')
          ..write('coverPath: $coverPath, ')
          ..write('notes: $notes, ')
          ..write('description: $description, ')
          ..write('publishYear: $publishYear, ')
          ..write('collectionId: $collectionId, ')
          ..write('imprintId: $imprintId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('copies: $copies, ')
          ..write('paginationConfig: $paginationConfig, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    subtitle,
    author,
    isbn,
    language,
    translator,
    publisher,
    coverUrl,
    totalPages,
    currentPage,
    status,
    rating,
    bookFormat,
    collectionName,
    collectionNumber,
    coverPath,
    notes,
    description,
    publishYear,
    collectionId,
    imprintId,
    startedAt,
    finishedAt,
    copies,
    paginationConfig,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.author == this.author &&
          other.isbn == this.isbn &&
          other.language == this.language &&
          other.translator == this.translator &&
          other.publisher == this.publisher &&
          other.coverUrl == this.coverUrl &&
          other.totalPages == this.totalPages &&
          other.currentPage == this.currentPage &&
          other.status == this.status &&
          other.rating == this.rating &&
          other.bookFormat == this.bookFormat &&
          other.collectionName == this.collectionName &&
          other.collectionNumber == this.collectionNumber &&
          other.coverPath == this.coverPath &&
          other.notes == this.notes &&
          other.description == this.description &&
          other.publishYear == this.publishYear &&
          other.collectionId == this.collectionId &&
          other.imprintId == this.imprintId &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.copies == this.copies &&
          other.paginationConfig == this.paginationConfig &&
          other.createdAt == this.createdAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<String> author;
  final Value<String?> isbn;
  final Value<String?> language;
  final Value<String?> translator;
  final Value<String?> publisher;
  final Value<String?> coverUrl;
  final Value<int?> totalPages;
  final Value<int?> currentPage;
  final Value<ReadingStatus> status;
  final Value<double?> rating;
  final Value<BookFormat?> bookFormat;
  final Value<String?> collectionName;
  final Value<int?> collectionNumber;
  final Value<String?> coverPath;
  final Value<String?> notes;
  final Value<String?> description;
  final Value<int?> publishYear;
  final Value<int?> collectionId;
  final Value<int?> imprintId;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> copies;
  final Value<PaginationConfig?> paginationConfig;
  final Value<DateTime> createdAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.author = const Value.absent(),
    this.isbn = const Value.absent(),
    this.language = const Value.absent(),
    this.translator = const Value.absent(),
    this.publisher = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.bookFormat = const Value.absent(),
    this.collectionName = const Value.absent(),
    this.collectionNumber = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.description = const Value.absent(),
    this.publishYear = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.imprintId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.copies = const Value.absent(),
    this.paginationConfig = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.subtitle = const Value.absent(),
    required String author,
    this.isbn = const Value.absent(),
    this.language = const Value.absent(),
    this.translator = const Value.absent(),
    this.publisher = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.currentPage = const Value.absent(),
    required ReadingStatus status,
    this.rating = const Value.absent(),
    this.bookFormat = const Value.absent(),
    this.collectionName = const Value.absent(),
    this.collectionNumber = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.description = const Value.absent(),
    this.publishYear = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.imprintId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.copies = const Value.absent(),
    this.paginationConfig = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       author = Value(author),
       status = Value(status);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? author,
    Expression<String>? isbn,
    Expression<String>? language,
    Expression<String>? translator,
    Expression<String>? publisher,
    Expression<String>? coverUrl,
    Expression<int>? totalPages,
    Expression<int>? currentPage,
    Expression<String>? status,
    Expression<double>? rating,
    Expression<String>? bookFormat,
    Expression<String>? collectionName,
    Expression<int>? collectionNumber,
    Expression<String>? coverPath,
    Expression<String>? notes,
    Expression<String>? description,
    Expression<int>? publishYear,
    Expression<int>? collectionId,
    Expression<int>? imprintId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? copies,
    Expression<String>? paginationConfig,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (author != null) 'author': author,
      if (isbn != null) 'isbn': isbn,
      if (language != null) 'language': language,
      if (translator != null) 'translator': translator,
      if (publisher != null) 'publisher': publisher,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (totalPages != null) 'total_pages': totalPages,
      if (currentPage != null) 'current_page': currentPage,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (bookFormat != null) 'book_format': bookFormat,
      if (collectionName != null) 'collection_name': collectionName,
      if (collectionNumber != null) 'collection_number': collectionNumber,
      if (coverPath != null) 'cover_path': coverPath,
      if (notes != null) 'notes': notes,
      if (description != null) 'description': description,
      if (publishYear != null) 'publish_year': publishYear,
      if (collectionId != null) 'collection_id': collectionId,
      if (imprintId != null) 'imprint_id': imprintId,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (copies != null) 'copies': copies,
      if (paginationConfig != null) 'pagination_config': paginationConfig,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? subtitle,
    Value<String>? author,
    Value<String?>? isbn,
    Value<String?>? language,
    Value<String?>? translator,
    Value<String?>? publisher,
    Value<String?>? coverUrl,
    Value<int?>? totalPages,
    Value<int?>? currentPage,
    Value<ReadingStatus>? status,
    Value<double?>? rating,
    Value<BookFormat?>? bookFormat,
    Value<String?>? collectionName,
    Value<int?>? collectionNumber,
    Value<String?>? coverPath,
    Value<String?>? notes,
    Value<String?>? description,
    Value<int?>? publishYear,
    Value<int?>? collectionId,
    Value<int?>? imprintId,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? copies,
    Value<PaginationConfig?>? paginationConfig,
    Value<DateTime>? createdAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      language: language ?? this.language,
      translator: translator ?? this.translator,
      publisher: publisher ?? this.publisher,
      coverUrl: coverUrl ?? this.coverUrl,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      bookFormat: bookFormat ?? this.bookFormat,
      collectionName: collectionName ?? this.collectionName,
      collectionNumber: collectionNumber ?? this.collectionNumber,
      coverPath: coverPath ?? this.coverPath,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      publishYear: publishYear ?? this.publishYear,
      collectionId: collectionId ?? this.collectionId,
      imprintId: imprintId ?? this.imprintId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      copies: copies ?? this.copies,
      paginationConfig: paginationConfig ?? this.paginationConfig,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (translator.present) {
      map['translator'] = Variable<String>(translator.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $BooksTable.$converterstatus.toSql(status.value),
      );
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (bookFormat.present) {
      map['book_format'] = Variable<String>(
        $BooksTable.$converterbookFormat.toSql(bookFormat.value),
      );
    }
    if (collectionName.present) {
      map['collection_name'] = Variable<String>(collectionName.value);
    }
    if (collectionNumber.present) {
      map['collection_number'] = Variable<int>(collectionNumber.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (publishYear.present) {
      map['publish_year'] = Variable<int>(publishYear.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (imprintId.present) {
      map['imprint_id'] = Variable<int>(imprintId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (copies.present) {
      map['copies'] = Variable<int>(copies.value);
    }
    if (paginationConfig.present) {
      map['pagination_config'] = Variable<String>(
        $BooksTable.$converterpaginationConfign.toSql(paginationConfig.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('author: $author, ')
          ..write('isbn: $isbn, ')
          ..write('language: $language, ')
          ..write('translator: $translator, ')
          ..write('publisher: $publisher, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('totalPages: $totalPages, ')
          ..write('currentPage: $currentPage, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('bookFormat: $bookFormat, ')
          ..write('collectionName: $collectionName, ')
          ..write('collectionNumber: $collectionNumber, ')
          ..write('coverPath: $coverPath, ')
          ..write('notes: $notes, ')
          ..write('description: $description, ')
          ..write('publishYear: $publishYear, ')
          ..write('collectionId: $collectionId, ')
          ..write('imprintId: $imprintId, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('copies: $copies, ')
          ..write('paginationConfig: $paginationConfig, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BookTagsTable extends BookTags with TableInfo<$BookTagsTable, BookTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, tagId};
  @override
  BookTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookTag(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $BookTagsTable createAlias(String alias) {
    return $BookTagsTable(attachedDatabase, alias);
  }
}

class BookTag extends DataClass implements Insertable<BookTag> {
  final int bookId;
  final int tagId;
  const BookTag({required this.bookId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  BookTagsCompanion toCompanion(bool nullToAbsent) {
    return BookTagsCompanion(bookId: Value(bookId), tagId: Value(tagId));
  }

  factory BookTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookTag(
      bookId: serializer.fromJson<int>(json['bookId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  BookTag copyWith({int? bookId, int? tagId}) =>
      BookTag(bookId: bookId ?? this.bookId, tagId: tagId ?? this.tagId);
  BookTag copyWithCompanion(BookTagsCompanion data) {
    return BookTag(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookTag(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookTag &&
          other.bookId == this.bookId &&
          other.tagId == this.tagId);
}

class BookTagsCompanion extends UpdateCompanion<BookTag> {
  final Value<int> bookId;
  final Value<int> tagId;
  final Value<int> rowid;
  const BookTagsCompanion({
    this.bookId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookTagsCompanion.insert({
    required int bookId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       tagId = Value(tagId);
  static Insertable<BookTag> custom({
    Expression<int>? bookId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookTagsCompanion copyWith({
    Value<int>? bookId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return BookTagsCompanion(
      bookId: bookId ?? this.bookId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookTagsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShelvesTable extends Shelves with TableInfo<$ShelvesTable, Shelf> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filterQueryMeta = const VerificationMeta(
    'filterQuery',
  );
  @override
  late final GeneratedColumn<String> filterQuery = GeneratedColumn<String>(
    'filter_query',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterSubtitleMeta = const VerificationMeta(
    'filterSubtitle',
  );
  @override
  late final GeneratedColumn<String> filterSubtitle = GeneratedColumn<String>(
    'filter_subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterAuthorMeta = const VerificationMeta(
    'filterAuthor',
  );
  @override
  late final GeneratedColumn<String> filterAuthor = GeneratedColumn<String>(
    'filter_author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterPublisherMeta = const VerificationMeta(
    'filterPublisher',
  );
  @override
  late final GeneratedColumn<String> filterPublisher = GeneratedColumn<String>(
    'filter_publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterIsbnMeta = const VerificationMeta(
    'filterIsbn',
  );
  @override
  late final GeneratedColumn<String> filterIsbn = GeneratedColumn<String>(
    'filter_isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterLanguageMeta = const VerificationMeta(
    'filterLanguage',
  );
  @override
  late final GeneratedColumn<String> filterLanguage = GeneratedColumn<String>(
    'filter_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterTranslatorMeta = const VerificationMeta(
    'filterTranslator',
  );
  @override
  late final GeneratedColumn<String> filterTranslator = GeneratedColumn<String>(
    'filter_translator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterCollectionMeta = const VerificationMeta(
    'filterCollection',
  );
  @override
  late final GeneratedColumn<String> filterCollection = GeneratedColumn<String>(
    'filter_collection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterCollectionIdsMeta =
      const VerificationMeta('filterCollectionIds');
  @override
  late final GeneratedColumn<String> filterCollectionIds =
      GeneratedColumn<String>(
        'filter_collection_ids',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _filterStatusMeta = const VerificationMeta(
    'filterStatus',
  );
  @override
  late final GeneratedColumn<String> filterStatus = GeneratedColumn<String>(
    'filter_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterTagIdsMeta = const VerificationMeta(
    'filterTagIds',
  );
  @override
  late final GeneratedColumn<String> filterTagIds = GeneratedColumn<String>(
    'filter_tag_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterImprintIdsMeta = const VerificationMeta(
    'filterImprintIds',
  );
  @override
  late final GeneratedColumn<String> filterImprintIds = GeneratedColumn<String>(
    'filter_imprint_ids',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filterNoCoverMeta = const VerificationMeta(
    'filterNoCover',
  );
  @override
  late final GeneratedColumn<bool> filterNoCover = GeneratedColumn<bool>(
    'filter_no_cover',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("filter_no_cover" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    filterQuery,
    filterSubtitle,
    filterAuthor,
    filterPublisher,
    filterIsbn,
    filterLanguage,
    filterTranslator,
    filterCollection,
    filterCollectionIds,
    filterStatus,
    filterTagIds,
    filterImprintIds,
    filterNoCover,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelves';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shelf> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('filter_query')) {
      context.handle(
        _filterQueryMeta,
        filterQuery.isAcceptableOrUnknown(
          data['filter_query']!,
          _filterQueryMeta,
        ),
      );
    }
    if (data.containsKey('filter_subtitle')) {
      context.handle(
        _filterSubtitleMeta,
        filterSubtitle.isAcceptableOrUnknown(
          data['filter_subtitle']!,
          _filterSubtitleMeta,
        ),
      );
    }
    if (data.containsKey('filter_author')) {
      context.handle(
        _filterAuthorMeta,
        filterAuthor.isAcceptableOrUnknown(
          data['filter_author']!,
          _filterAuthorMeta,
        ),
      );
    }
    if (data.containsKey('filter_publisher')) {
      context.handle(
        _filterPublisherMeta,
        filterPublisher.isAcceptableOrUnknown(
          data['filter_publisher']!,
          _filterPublisherMeta,
        ),
      );
    }
    if (data.containsKey('filter_isbn')) {
      context.handle(
        _filterIsbnMeta,
        filterIsbn.isAcceptableOrUnknown(data['filter_isbn']!, _filterIsbnMeta),
      );
    }
    if (data.containsKey('filter_language')) {
      context.handle(
        _filterLanguageMeta,
        filterLanguage.isAcceptableOrUnknown(
          data['filter_language']!,
          _filterLanguageMeta,
        ),
      );
    }
    if (data.containsKey('filter_translator')) {
      context.handle(
        _filterTranslatorMeta,
        filterTranslator.isAcceptableOrUnknown(
          data['filter_translator']!,
          _filterTranslatorMeta,
        ),
      );
    }
    if (data.containsKey('filter_collection')) {
      context.handle(
        _filterCollectionMeta,
        filterCollection.isAcceptableOrUnknown(
          data['filter_collection']!,
          _filterCollectionMeta,
        ),
      );
    }
    if (data.containsKey('filter_collection_ids')) {
      context.handle(
        _filterCollectionIdsMeta,
        filterCollectionIds.isAcceptableOrUnknown(
          data['filter_collection_ids']!,
          _filterCollectionIdsMeta,
        ),
      );
    }
    if (data.containsKey('filter_status')) {
      context.handle(
        _filterStatusMeta,
        filterStatus.isAcceptableOrUnknown(
          data['filter_status']!,
          _filterStatusMeta,
        ),
      );
    }
    if (data.containsKey('filter_tag_ids')) {
      context.handle(
        _filterTagIdsMeta,
        filterTagIds.isAcceptableOrUnknown(
          data['filter_tag_ids']!,
          _filterTagIdsMeta,
        ),
      );
    }
    if (data.containsKey('filter_imprint_ids')) {
      context.handle(
        _filterImprintIdsMeta,
        filterImprintIds.isAcceptableOrUnknown(
          data['filter_imprint_ids']!,
          _filterImprintIdsMeta,
        ),
      );
    }
    if (data.containsKey('filter_no_cover')) {
      context.handle(
        _filterNoCoverMeta,
        filterNoCover.isAcceptableOrUnknown(
          data['filter_no_cover']!,
          _filterNoCoverMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shelf map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shelf(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      filterQuery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_query'],
      ),
      filterSubtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_subtitle'],
      ),
      filterAuthor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_author'],
      ),
      filterPublisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_publisher'],
      ),
      filterIsbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_isbn'],
      ),
      filterLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_language'],
      ),
      filterTranslator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_translator'],
      ),
      filterCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_collection'],
      ),
      filterCollectionIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_collection_ids'],
      ),
      filterStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_status'],
      ),
      filterTagIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_tag_ids'],
      ),
      filterImprintIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_imprint_ids'],
      ),
      filterNoCover: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}filter_no_cover'],
      )!,
    );
  }

  @override
  $ShelvesTable createAlias(String alias) {
    return $ShelvesTable(attachedDatabase, alias);
  }
}

class ShelvesCompanion extends UpdateCompanion<Shelf> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> filterQuery;
  final Value<String?> filterSubtitle;
  final Value<String?> filterAuthor;
  final Value<String?> filterPublisher;
  final Value<String?> filterIsbn;
  final Value<String?> filterLanguage;
  final Value<String?> filterTranslator;
  final Value<String?> filterCollection;
  final Value<String?> filterCollectionIds;
  final Value<String?> filterStatus;
  final Value<String?> filterTagIds;
  final Value<String?> filterImprintIds;
  final Value<bool> filterNoCover;
  const ShelvesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.filterQuery = const Value.absent(),
    this.filterSubtitle = const Value.absent(),
    this.filterAuthor = const Value.absent(),
    this.filterPublisher = const Value.absent(),
    this.filterIsbn = const Value.absent(),
    this.filterLanguage = const Value.absent(),
    this.filterTranslator = const Value.absent(),
    this.filterCollection = const Value.absent(),
    this.filterCollectionIds = const Value.absent(),
    this.filterStatus = const Value.absent(),
    this.filterTagIds = const Value.absent(),
    this.filterImprintIds = const Value.absent(),
    this.filterNoCover = const Value.absent(),
  });
  ShelvesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.filterQuery = const Value.absent(),
    this.filterSubtitle = const Value.absent(),
    this.filterAuthor = const Value.absent(),
    this.filterPublisher = const Value.absent(),
    this.filterIsbn = const Value.absent(),
    this.filterLanguage = const Value.absent(),
    this.filterTranslator = const Value.absent(),
    this.filterCollection = const Value.absent(),
    this.filterCollectionIds = const Value.absent(),
    this.filterStatus = const Value.absent(),
    this.filterTagIds = const Value.absent(),
    this.filterImprintIds = const Value.absent(),
    this.filterNoCover = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Shelf> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? filterQuery,
    Expression<String>? filterSubtitle,
    Expression<String>? filterAuthor,
    Expression<String>? filterPublisher,
    Expression<String>? filterIsbn,
    Expression<String>? filterLanguage,
    Expression<String>? filterTranslator,
    Expression<String>? filterCollection,
    Expression<String>? filterCollectionIds,
    Expression<String>? filterStatus,
    Expression<String>? filterTagIds,
    Expression<String>? filterImprintIds,
    Expression<bool>? filterNoCover,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (filterQuery != null) 'filter_query': filterQuery,
      if (filterSubtitle != null) 'filter_subtitle': filterSubtitle,
      if (filterAuthor != null) 'filter_author': filterAuthor,
      if (filterPublisher != null) 'filter_publisher': filterPublisher,
      if (filterIsbn != null) 'filter_isbn': filterIsbn,
      if (filterLanguage != null) 'filter_language': filterLanguage,
      if (filterTranslator != null) 'filter_translator': filterTranslator,
      if (filterCollection != null) 'filter_collection': filterCollection,
      if (filterCollectionIds != null)
        'filter_collection_ids': filterCollectionIds,
      if (filterStatus != null) 'filter_status': filterStatus,
      if (filterTagIds != null) 'filter_tag_ids': filterTagIds,
      if (filterImprintIds != null) 'filter_imprint_ids': filterImprintIds,
      if (filterNoCover != null) 'filter_no_cover': filterNoCover,
    });
  }

  ShelvesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? filterQuery,
    Value<String?>? filterSubtitle,
    Value<String?>? filterAuthor,
    Value<String?>? filterPublisher,
    Value<String?>? filterIsbn,
    Value<String?>? filterLanguage,
    Value<String?>? filterTranslator,
    Value<String?>? filterCollection,
    Value<String?>? filterCollectionIds,
    Value<String?>? filterStatus,
    Value<String?>? filterTagIds,
    Value<String?>? filterImprintIds,
    Value<bool>? filterNoCover,
  }) {
    return ShelvesCompanion(
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
      filterStatus: filterStatus ?? this.filterStatus,
      filterTagIds: filterTagIds ?? this.filterTagIds,
      filterImprintIds: filterImprintIds ?? this.filterImprintIds,
      filterNoCover: filterNoCover ?? this.filterNoCover,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filterQuery.present) {
      map['filter_query'] = Variable<String>(filterQuery.value);
    }
    if (filterSubtitle.present) {
      map['filter_subtitle'] = Variable<String>(filterSubtitle.value);
    }
    if (filterAuthor.present) {
      map['filter_author'] = Variable<String>(filterAuthor.value);
    }
    if (filterPublisher.present) {
      map['filter_publisher'] = Variable<String>(filterPublisher.value);
    }
    if (filterIsbn.present) {
      map['filter_isbn'] = Variable<String>(filterIsbn.value);
    }
    if (filterLanguage.present) {
      map['filter_language'] = Variable<String>(filterLanguage.value);
    }
    if (filterTranslator.present) {
      map['filter_translator'] = Variable<String>(filterTranslator.value);
    }
    if (filterCollection.present) {
      map['filter_collection'] = Variable<String>(filterCollection.value);
    }
    if (filterCollectionIds.present) {
      map['filter_collection_ids'] = Variable<String>(
        filterCollectionIds.value,
      );
    }
    if (filterStatus.present) {
      map['filter_status'] = Variable<String>(filterStatus.value);
    }
    if (filterTagIds.present) {
      map['filter_tag_ids'] = Variable<String>(filterTagIds.value);
    }
    if (filterImprintIds.present) {
      map['filter_imprint_ids'] = Variable<String>(filterImprintIds.value);
    }
    if (filterNoCover.present) {
      map['filter_no_cover'] = Variable<bool>(filterNoCover.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filterQuery: $filterQuery, ')
          ..write('filterSubtitle: $filterSubtitle, ')
          ..write('filterAuthor: $filterAuthor, ')
          ..write('filterPublisher: $filterPublisher, ')
          ..write('filterIsbn: $filterIsbn, ')
          ..write('filterLanguage: $filterLanguage, ')
          ..write('filterTranslator: $filterTranslator, ')
          ..write('filterCollection: $filterCollection, ')
          ..write('filterCollectionIds: $filterCollectionIds, ')
          ..write('filterStatus: $filterStatus, ')
          ..write('filterTagIds: $filterTagIds, ')
          ..write('filterImprintIds: $filterImprintIds, ')
          ..write('filterNoCover: $filterNoCover')
          ..write(')'))
        .toString();
  }
}

class $ShelfTagsTable extends ShelfTags
    with TableInfo<$ShelfTagsTable, ShelfTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelfTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<int> shelfId = GeneratedColumn<int>(
    'shelf_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [shelfId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelf_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShelfTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shelfIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {shelfId, tagId};
  @override
  ShelfTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShelfTag(
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $ShelfTagsTable createAlias(String alias) {
    return $ShelfTagsTable(attachedDatabase, alias);
  }
}

class ShelfTag extends DataClass implements Insertable<ShelfTag> {
  final int shelfId;
  final int tagId;
  const ShelfTag({required this.shelfId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['shelf_id'] = Variable<int>(shelfId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  ShelfTagsCompanion toCompanion(bool nullToAbsent) {
    return ShelfTagsCompanion(shelfId: Value(shelfId), tagId: Value(tagId));
  }

  factory ShelfTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShelfTag(
      shelfId: serializer.fromJson<int>(json['shelfId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shelfId': serializer.toJson<int>(shelfId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  ShelfTag copyWith({int? shelfId, int? tagId}) =>
      ShelfTag(shelfId: shelfId ?? this.shelfId, tagId: tagId ?? this.tagId);
  ShelfTag copyWithCompanion(ShelfTagsCompanion data) {
    return ShelfTag(
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShelfTag(')
          ..write('shelfId: $shelfId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(shelfId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShelfTag &&
          other.shelfId == this.shelfId &&
          other.tagId == this.tagId);
}

class ShelfTagsCompanion extends UpdateCompanion<ShelfTag> {
  final Value<int> shelfId;
  final Value<int> tagId;
  final Value<int> rowid;
  const ShelfTagsCompanion({
    this.shelfId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShelfTagsCompanion.insert({
    required int shelfId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : shelfId = Value(shelfId),
       tagId = Value(tagId);
  static Insertable<ShelfTag> custom({
    Expression<int>? shelfId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (shelfId != null) 'shelf_id': shelfId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShelfTagsCompanion copyWith({
    Value<int>? shelfId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return ShelfTagsCompanion(
      shelfId: shelfId ?? this.shelfId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shelfId.present) {
      map['shelf_id'] = Variable<int>(shelfId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelfTagsCompanion(')
          ..write('shelfId: $shelfId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingGoalsTable extends ReadingGoals
    with TableInfo<$ReadingGoalsTable, ReadingGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<int> shelfId = GeneratedColumn<int>(
    'shelf_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id)',
    ),
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    type,
    targetValue,
    startDate,
    endDate,
    shelfId,
    collectionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_value'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_id'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      ),
    );
  }

  @override
  $ReadingGoalsTable createAlias(String alias) {
    return $ReadingGoalsTable(attachedDatabase, alias);
  }
}

class ReadingGoal extends DataClass implements Insertable<ReadingGoal> {
  final int id;
  final String title;

  /// Type can be 'books' or 'pages'
  final String type;
  final int targetValue;
  final DateTime startDate;
  final DateTime endDate;

  /// Optional filters
  final int? shelfId;
  final int? collectionId;
  const ReadingGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
    this.shelfId,
    this.collectionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['target_value'] = Variable<int>(targetValue);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    if (!nullToAbsent || shelfId != null) {
      map['shelf_id'] = Variable<int>(shelfId);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<int>(collectionId);
    }
    return map;
  }

  ReadingGoalsCompanion toCompanion(bool nullToAbsent) {
    return ReadingGoalsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      targetValue: Value(targetValue),
      startDate: Value(startDate),
      endDate: Value(endDate),
      shelfId: shelfId == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfId),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
    );
  }

  factory ReadingGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingGoal(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      targetValue: serializer.fromJson<int>(json['targetValue']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      shelfId: serializer.fromJson<int?>(json['shelfId']),
      collectionId: serializer.fromJson<int?>(json['collectionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'targetValue': serializer.toJson<int>(targetValue),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'shelfId': serializer.toJson<int?>(shelfId),
      'collectionId': serializer.toJson<int?>(collectionId),
    };
  }

  ReadingGoal copyWith({
    int? id,
    String? title,
    String? type,
    int? targetValue,
    DateTime? startDate,
    DateTime? endDate,
    Value<int?> shelfId = const Value.absent(),
    Value<int?> collectionId = const Value.absent(),
  }) => ReadingGoal(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    targetValue: targetValue ?? this.targetValue,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    shelfId: shelfId.present ? shelfId.value : this.shelfId,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
  );
  ReadingGoal copyWithCompanion(ReadingGoalsCompanion data) {
    return ReadingGoal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingGoal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('targetValue: $targetValue, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('shelfId: $shelfId, ')
          ..write('collectionId: $collectionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    targetValue,
    startDate,
    endDate,
    shelfId,
    collectionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingGoal &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.targetValue == this.targetValue &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.shelfId == this.shelfId &&
          other.collectionId == this.collectionId);
}

class ReadingGoalsCompanion extends UpdateCompanion<ReadingGoal> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> type;
  final Value<int> targetValue;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int?> shelfId;
  final Value<int?> collectionId;
  const ReadingGoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.collectionId = const Value.absent(),
  });
  ReadingGoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String type,
    required int targetValue,
    required DateTime startDate,
    required DateTime endDate,
    this.shelfId = const Value.absent(),
    this.collectionId = const Value.absent(),
  }) : title = Value(title),
       type = Value(type),
       targetValue = Value(targetValue),
       startDate = Value(startDate),
       endDate = Value(endDate);
  static Insertable<ReadingGoal> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<int>? targetValue,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? shelfId,
    Expression<int>? collectionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (targetValue != null) 'target_value': targetValue,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (shelfId != null) 'shelf_id': shelfId,
      if (collectionId != null) 'collection_id': collectionId,
    });
  }

  ReadingGoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? type,
    Value<int>? targetValue,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<int?>? shelfId,
    Value<int?>? collectionId,
  }) {
    return ReadingGoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      shelfId: shelfId ?? this.shelfId,
      collectionId: collectionId ?? this.collectionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<int>(shelfId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingGoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('targetValue: $targetValue, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('shelfId: $shelfId, ')
          ..write('collectionId: $collectionId')
          ..write(')'))
        .toString();
  }
}

class $ReadingLogTable extends ReadingLog
    with TableInfo<$ReadingLogTable, ReadingLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagesReadMeta = const VerificationMeta(
    'pagesRead',
  );
  @override
  late final GeneratedColumn<int> pagesRead = GeneratedColumn<int>(
    'pages_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> sections =
      GeneratedColumn<String>(
        'sections',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($ReadingLogTable.$convertersectionsn);
  @override
  List<GeneratedColumn> get $columns => [id, bookId, date, pagesRead, sections];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('pages_read')) {
      context.handle(
        _pagesReadMeta,
        pagesRead.isAcceptableOrUnknown(data['pages_read']!, _pagesReadMeta),
      );
    } else if (isInserting) {
      context.missing(_pagesReadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      pagesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_read'],
      )!,
      sections: $ReadingLogTable.$convertersectionsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sections'],
        ),
      ),
    );
  }

  @override
  $ReadingLogTable createAlias(String alias) {
    return $ReadingLogTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertersections =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertersectionsn =
      NullAwareTypeConverter.wrap($convertersections);
}

class ReadingLogData extends DataClass implements Insertable<ReadingLogData> {
  final int id;
  final int bookId;
  final DateTime date;
  final int pagesRead;
  final List<String>? sections;
  const ReadingLogData({
    required this.id,
    required this.bookId,
    required this.date,
    required this.pagesRead,
    this.sections,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['date'] = Variable<DateTime>(date);
    map['pages_read'] = Variable<int>(pagesRead);
    if (!nullToAbsent || sections != null) {
      map['sections'] = Variable<String>(
        $ReadingLogTable.$convertersectionsn.toSql(sections),
      );
    }
    return map;
  }

  ReadingLogCompanion toCompanion(bool nullToAbsent) {
    return ReadingLogCompanion(
      id: Value(id),
      bookId: Value(bookId),
      date: Value(date),
      pagesRead: Value(pagesRead),
      sections: sections == null && nullToAbsent
          ? const Value.absent()
          : Value(sections),
    );
  }

  factory ReadingLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingLogData(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      date: serializer.fromJson<DateTime>(json['date']),
      pagesRead: serializer.fromJson<int>(json['pagesRead']),
      sections: serializer.fromJson<List<String>?>(json['sections']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'date': serializer.toJson<DateTime>(date),
      'pagesRead': serializer.toJson<int>(pagesRead),
      'sections': serializer.toJson<List<String>?>(sections),
    };
  }

  ReadingLogData copyWith({
    int? id,
    int? bookId,
    DateTime? date,
    int? pagesRead,
    Value<List<String>?> sections = const Value.absent(),
  }) => ReadingLogData(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    date: date ?? this.date,
    pagesRead: pagesRead ?? this.pagesRead,
    sections: sections.present ? sections.value : this.sections,
  );
  ReadingLogData copyWithCompanion(ReadingLogCompanion data) {
    return ReadingLogData(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      date: data.date.present ? data.date.value : this.date,
      pagesRead: data.pagesRead.present ? data.pagesRead.value : this.pagesRead,
      sections: data.sections.present ? data.sections.value : this.sections,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLogData(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('date: $date, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('sections: $sections')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, date, pagesRead, sections);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingLogData &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.date == this.date &&
          other.pagesRead == this.pagesRead &&
          other.sections == this.sections);
}

class ReadingLogCompanion extends UpdateCompanion<ReadingLogData> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<DateTime> date;
  final Value<int> pagesRead;
  final Value<List<String>?> sections;
  const ReadingLogCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.date = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.sections = const Value.absent(),
  });
  ReadingLogCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required DateTime date,
    required int pagesRead,
    this.sections = const Value.absent(),
  }) : bookId = Value(bookId),
       date = Value(date),
       pagesRead = Value(pagesRead);
  static Insertable<ReadingLogData> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<DateTime>? date,
    Expression<int>? pagesRead,
    Expression<String>? sections,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (date != null) 'date': date,
      if (pagesRead != null) 'pages_read': pagesRead,
      if (sections != null) 'sections': sections,
    });
  }

  ReadingLogCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<DateTime>? date,
    Value<int>? pagesRead,
    Value<List<String>?>? sections,
  }) {
    return ReadingLogCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      date: date ?? this.date,
      pagesRead: pagesRead ?? this.pagesRead,
      sections: sections ?? this.sections,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (pagesRead.present) {
      map['pages_read'] = Variable<int>(pagesRead.value);
    }
    if (sections.present) {
      map['sections'] = Variable<String>(
        $ReadingLogTable.$convertersectionsn.toSql(sections.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLogCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('date: $date, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('sections: $sections')
          ..write(')'))
        .toString();
  }
}

class $StatWidgetConfigsTable extends StatWidgetConfigs
    with TableInfo<$StatWidgetConfigsTable, StatWidgetConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatWidgetConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reading_goals (id)',
    ),
  );
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
    'config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    size,
    sortOrder,
    goalId,
    config,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stat_widget_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatWidgetConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    }
    if (data.containsKey('config')) {
      context.handle(
        _configMeta,
        config.isAcceptableOrUnknown(data['config']!, _configMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatWidgetConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatWidgetConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      ),
      config: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config'],
      ),
    );
  }

  @override
  $StatWidgetConfigsTable createAlias(String alias) {
    return $StatWidgetConfigsTable(attachedDatabase, alias);
  }
}

class StatWidgetConfig extends DataClass
    implements Insertable<StatWidgetConfig> {
  final int id;

  /// Type: 'pages', 'streak', 'goal', 'status', 'currentBook', 'addedOverTime', 'categories', 'publishYear', 'readList'
  final String type;

  /// Size: 'half', 'full', 'fullTall'
  final String size;
  final int sortOrder;
  final int? goalId;

  /// JSON-encoded configuration for the widget (e.g. time period)
  final String? config;
  const StatWidgetConfig({
    required this.id,
    required this.type,
    required this.size,
    required this.sortOrder,
    this.goalId,
    this.config,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['size'] = Variable<String>(size);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<int>(goalId);
    }
    if (!nullToAbsent || config != null) {
      map['config'] = Variable<String>(config);
    }
    return map;
  }

  StatWidgetConfigsCompanion toCompanion(bool nullToAbsent) {
    return StatWidgetConfigsCompanion(
      id: Value(id),
      type: Value(type),
      size: Value(size),
      sortOrder: Value(sortOrder),
      goalId: goalId == null && nullToAbsent
          ? const Value.absent()
          : Value(goalId),
      config: config == null && nullToAbsent
          ? const Value.absent()
          : Value(config),
    );
  }

  factory StatWidgetConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatWidgetConfig(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      size: serializer.fromJson<String>(json['size']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      goalId: serializer.fromJson<int?>(json['goalId']),
      config: serializer.fromJson<String?>(json['config']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'size': serializer.toJson<String>(size),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'goalId': serializer.toJson<int?>(goalId),
      'config': serializer.toJson<String?>(config),
    };
  }

  StatWidgetConfig copyWith({
    int? id,
    String? type,
    String? size,
    int? sortOrder,
    Value<int?> goalId = const Value.absent(),
    Value<String?> config = const Value.absent(),
  }) => StatWidgetConfig(
    id: id ?? this.id,
    type: type ?? this.type,
    size: size ?? this.size,
    sortOrder: sortOrder ?? this.sortOrder,
    goalId: goalId.present ? goalId.value : this.goalId,
    config: config.present ? config.value : this.config,
  );
  StatWidgetConfig copyWithCompanion(StatWidgetConfigsCompanion data) {
    return StatWidgetConfig(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      size: data.size.present ? data.size.value : this.size,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      config: data.config.present ? data.config.value : this.config,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatWidgetConfig(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('size: $size, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('goalId: $goalId, ')
          ..write('config: $config')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, size, sortOrder, goalId, config);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatWidgetConfig &&
          other.id == this.id &&
          other.type == this.type &&
          other.size == this.size &&
          other.sortOrder == this.sortOrder &&
          other.goalId == this.goalId &&
          other.config == this.config);
}

class StatWidgetConfigsCompanion extends UpdateCompanion<StatWidgetConfig> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> size;
  final Value<int> sortOrder;
  final Value<int?> goalId;
  final Value<String?> config;
  const StatWidgetConfigsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.size = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.goalId = const Value.absent(),
    this.config = const Value.absent(),
  });
  StatWidgetConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String size,
    required int sortOrder,
    this.goalId = const Value.absent(),
    this.config = const Value.absent(),
  }) : type = Value(type),
       size = Value(size),
       sortOrder = Value(sortOrder);
  static Insertable<StatWidgetConfig> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? size,
    Expression<int>? sortOrder,
    Expression<int>? goalId,
    Expression<String>? config,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (size != null) 'size': size,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (goalId != null) 'goal_id': goalId,
      if (config != null) 'config': config,
    });
  }

  StatWidgetConfigsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? size,
    Value<int>? sortOrder,
    Value<int?>? goalId,
    Value<String?>? config,
  }) {
    return StatWidgetConfigsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      size: size ?? this.size,
      sortOrder: sortOrder ?? this.sortOrder,
      goalId: goalId ?? this.goalId,
      config: config ?? this.config,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatWidgetConfigsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('size: $size, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('goalId: $goalId, ')
          ..write('config: $config')
          ..write(')'))
        .toString();
  }
}

class $ReadHistoryTable extends ReadHistory
    with TableInfo<$ReadHistoryTable, ReadHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _readNumberMeta = const VerificationMeta(
    'readNumber',
  );
  @override
  late final GeneratedColumn<int> readNumber = GeneratedColumn<int>(
    'read_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> sections =
      GeneratedColumn<String>(
        'sections',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($ReadHistoryTable.$convertersectionsn);
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<int, int>?, String>
  segmentProgress = GeneratedColumn<String>(
    'segment_progress',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<int, int>?>($ReadHistoryTable.$convertersegmentProgressn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    readNumber,
    startedAt,
    finishedAt,
    sections,
    progress,
    segmentProgress,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('read_number')) {
      context.handle(
        _readNumberMeta,
        readNumber.isAcceptableOrUnknown(data['read_number']!, _readNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_readNumberMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      readNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_number'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      sections: $ReadHistoryTable.$convertersectionsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sections'],
        ),
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      segmentProgress: $ReadHistoryTable.$convertersegmentProgressn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}segment_progress'],
        ),
      ),
    );
  }

  @override
  $ReadHistoryTable createAlias(String alias) {
    return $ReadHistoryTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertersections =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $convertersectionsn =
      NullAwareTypeConverter.wrap($convertersections);
  static TypeConverter<Map<int, int>, String> $convertersegmentProgress =
      const IntMapConverter();
  static TypeConverter<Map<int, int>?, String?> $convertersegmentProgressn =
      NullAwareTypeConverter.wrap($convertersegmentProgress);
}

class ReadHistoryData extends DataClass implements Insertable<ReadHistoryData> {
  final int id;
  final int bookId;
  final int readNumber;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final List<String>? sections;
  final int progress;
  final Map<int, int>? segmentProgress;
  const ReadHistoryData({
    required this.id,
    required this.bookId,
    required this.readNumber,
    this.startedAt,
    this.finishedAt,
    this.sections,
    required this.progress,
    this.segmentProgress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['read_number'] = Variable<int>(readNumber);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || sections != null) {
      map['sections'] = Variable<String>(
        $ReadHistoryTable.$convertersectionsn.toSql(sections),
      );
    }
    map['progress'] = Variable<int>(progress);
    if (!nullToAbsent || segmentProgress != null) {
      map['segment_progress'] = Variable<String>(
        $ReadHistoryTable.$convertersegmentProgressn.toSql(segmentProgress),
      );
    }
    return map;
  }

  ReadHistoryCompanion toCompanion(bool nullToAbsent) {
    return ReadHistoryCompanion(
      id: Value(id),
      bookId: Value(bookId),
      readNumber: Value(readNumber),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      sections: sections == null && nullToAbsent
          ? const Value.absent()
          : Value(sections),
      progress: Value(progress),
      segmentProgress: segmentProgress == null && nullToAbsent
          ? const Value.absent()
          : Value(segmentProgress),
    );
  }

  factory ReadHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadHistoryData(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      readNumber: serializer.fromJson<int>(json['readNumber']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      sections: serializer.fromJson<List<String>?>(json['sections']),
      progress: serializer.fromJson<int>(json['progress']),
      segmentProgress: serializer.fromJson<Map<int, int>?>(
        json['segmentProgress'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'readNumber': serializer.toJson<int>(readNumber),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'sections': serializer.toJson<List<String>?>(sections),
      'progress': serializer.toJson<int>(progress),
      'segmentProgress': serializer.toJson<Map<int, int>?>(segmentProgress),
    };
  }

  ReadHistoryData copyWith({
    int? id,
    int? bookId,
    int? readNumber,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<List<String>?> sections = const Value.absent(),
    int? progress,
    Value<Map<int, int>?> segmentProgress = const Value.absent(),
  }) => ReadHistoryData(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    readNumber: readNumber ?? this.readNumber,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    sections: sections.present ? sections.value : this.sections,
    progress: progress ?? this.progress,
    segmentProgress: segmentProgress.present
        ? segmentProgress.value
        : this.segmentProgress,
  );
  ReadHistoryData copyWithCompanion(ReadHistoryCompanion data) {
    return ReadHistoryData(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      readNumber: data.readNumber.present
          ? data.readNumber.value
          : this.readNumber,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      sections: data.sections.present ? data.sections.value : this.sections,
      progress: data.progress.present ? data.progress.value : this.progress,
      segmentProgress: data.segmentProgress.present
          ? data.segmentProgress.value
          : this.segmentProgress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadHistoryData(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('readNumber: $readNumber, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('sections: $sections, ')
          ..write('progress: $progress, ')
          ..write('segmentProgress: $segmentProgress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    readNumber,
    startedAt,
    finishedAt,
    sections,
    progress,
    segmentProgress,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadHistoryData &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.readNumber == this.readNumber &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.sections == this.sections &&
          other.progress == this.progress &&
          other.segmentProgress == this.segmentProgress);
}

class ReadHistoryCompanion extends UpdateCompanion<ReadHistoryData> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> readNumber;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<List<String>?> sections;
  final Value<int> progress;
  final Value<Map<int, int>?> segmentProgress;
  const ReadHistoryCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.readNumber = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.sections = const Value.absent(),
    this.progress = const Value.absent(),
    this.segmentProgress = const Value.absent(),
  });
  ReadHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int readNumber,
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.sections = const Value.absent(),
    this.progress = const Value.absent(),
    this.segmentProgress = const Value.absent(),
  }) : bookId = Value(bookId),
       readNumber = Value(readNumber);
  static Insertable<ReadHistoryData> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? readNumber,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? sections,
    Expression<int>? progress,
    Expression<String>? segmentProgress,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (readNumber != null) 'read_number': readNumber,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (sections != null) 'sections': sections,
      if (progress != null) 'progress': progress,
      if (segmentProgress != null) 'segment_progress': segmentProgress,
    });
  }

  ReadHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? readNumber,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<List<String>?>? sections,
    Value<int>? progress,
    Value<Map<int, int>?>? segmentProgress,
  }) {
    return ReadHistoryCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      readNumber: readNumber ?? this.readNumber,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      sections: sections ?? this.sections,
      progress: progress ?? this.progress,
      segmentProgress: segmentProgress ?? this.segmentProgress,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (readNumber.present) {
      map['read_number'] = Variable<int>(readNumber.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (sections.present) {
      map['sections'] = Variable<String>(
        $ReadHistoryTable.$convertersectionsn.toSql(sections.value),
      );
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (segmentProgress.present) {
      map['segment_progress'] = Variable<String>(
        $ReadHistoryTable.$convertersegmentProgressn.toSql(
          segmentProgress.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadHistoryCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('readNumber: $readNumber, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('sections: $sections, ')
          ..write('progress: $progress, ')
          ..write('segmentProgress: $segmentProgress')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookTagsTable bookTags = $BookTagsTable(this);
  late final $ShelvesTable shelves = $ShelvesTable(this);
  late final $ShelfTagsTable shelfTags = $ShelfTagsTable(this);
  late final $ReadingGoalsTable readingGoals = $ReadingGoalsTable(this);
  late final $ReadingLogTable readingLog = $ReadingLogTable(this);
  late final $StatWidgetConfigsTable statWidgetConfigs =
      $StatWidgetConfigsTable(this);
  late final $ReadHistoryTable readHistory = $ReadHistoryTable(this);
  late final BookDao bookDao = BookDao(this as AppDatabase);
  late final TagDao tagDao = TagDao(this as AppDatabase);
  late final ShelfDao shelfDao = ShelfDao(this as AppDatabase);
  late final GoalDao goalDao = GoalDao(this as AppDatabase);
  late final LogDao logDao = LogDao(this as AppDatabase);
  late final StatDao statDao = StatDao(this as AppDatabase);
  late final ReadHistoryDao readHistoryDao = ReadHistoryDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tags,
    books,
    bookTags,
    shelves,
    shelfTags,
    readingGoals,
    readingLog,
    statWidgetConfigs,
    readHistory,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shelves',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shelf_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shelf_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('read_history', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      Value<TagType> type,
      Value<String?> color,
      Value<String?> imagePath,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<TagType> type,
      Value<String?> color,
      Value<String?> imagePath,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<Book>> _bookCollectionTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: 'tags__id__books__collection_id',
  );

  $$BooksTableProcessedTableManager get bookCollection {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookCollectionTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BooksTable, List<Book>> _bookImprintTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: 'tags__id__books__imprint_id',
  );

  $$BooksTableProcessedTableManager get bookImprint {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.imprintId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookImprintTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookTagsTable, List<BookTag>> _bookTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bookTags,
    aliasName: 'tags__id__book_tags__tag_id',
  );

  $$BookTagsTableProcessedTableManager get bookTagsRefs {
    final manager = $$BookTagsTableTableManager(
      $_db,
      $_db.bookTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShelfTagsTable, List<ShelfTag>>
  _shelfTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shelfTags,
    aliasName: 'tags__id__shelf_tags__tag_id',
  );

  $$ShelfTagsTableProcessedTableManager get shelfTagsRefs {
    final manager = $$ShelfTagsTableTableManager(
      $_db,
      $_db.shelfTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shelfTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingGoalsTable, List<ReadingGoal>>
  _readingGoalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingGoals,
    aliasName: 'tags__id__reading_goals__collection_id',
  );

  $$ReadingGoalsTableProcessedTableManager get readingGoalsRefs {
    final manager = $$ReadingGoalsTableTableManager(
      $_db,
      $_db.readingGoals,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingGoalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TagType, TagType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookCollection(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookImprint(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.imprintId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookTagsRefs(
    Expression<bool> Function($$BookTagsTableFilterComposer f) f,
  ) {
    final $$BookTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shelfTagsRefs(
    Expression<bool> Function($$ShelfTagsTableFilterComposer f) f,
  ) {
    final $$ShelfTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfTagsTableFilterComposer(
            $db: $db,
            $table: $db.shelfTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingGoalsRefs(
    Expression<bool> Function($$ReadingGoalsTableFilterComposer f) f,
  ) {
    final $$ReadingGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingGoals,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingGoalsTableFilterComposer(
            $db: $db,
            $table: $db.readingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TagType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  Expression<T> bookCollection<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookImprint<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.imprintId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookTagsRefs<T extends Object>(
    Expression<T> Function($$BookTagsTableAnnotationComposer a) f,
  ) {
    final $$BookTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shelfTagsRefs<T extends Object>(
    Expression<T> Function($$ShelfTagsTableAnnotationComposer a) f,
  ) {
    final $$ShelfTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingGoalsRefs<T extends Object>(
    Expression<T> Function($$ReadingGoalsTableAnnotationComposer a) f,
  ) {
    final $$ReadingGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingGoals,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({
            bool bookCollection,
            bool bookImprint,
            bool bookTagsRefs,
            bool shelfTagsRefs,
            bool readingGoalsRefs,
          })
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<TagType> type = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                type: type,
                color: color,
                imagePath: imagePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<TagType> type = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                type: type,
                color: color,
                imagePath: imagePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bookCollection = false,
                bookImprint = false,
                bookTagsRefs = false,
                shelfTagsRefs = false,
                readingGoalsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookCollection) db.books,
                    if (bookImprint) db.books,
                    if (bookTagsRefs) db.bookTags,
                    if (shelfTagsRefs) db.shelfTags,
                    if (readingGoalsRefs) db.readingGoals,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookCollection)
                        await $_getPrefetchedData<Tag, $TagsTable, Book>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._bookCollectionTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).bookCollection,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookImprint)
                        await $_getPrefetchedData<Tag, $TagsTable, Book>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._bookImprintTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagsTableReferences(db, table, p0).bookImprint,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.imprintId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, BookTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._bookTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagsTableReferences(db, table, p0).bookTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shelfTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, ShelfTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._shelfTagsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).shelfTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingGoalsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, ReadingGoal>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._readingGoalsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).readingGoalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.collectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({
        bool bookCollection,
        bool bookImprint,
        bool bookTagsRefs,
        bool shelfTagsRefs,
        bool readingGoalsRefs,
      })
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> subtitle,
      required String author,
      Value<String?> isbn,
      Value<String?> language,
      Value<String?> translator,
      Value<String?> publisher,
      Value<String?> coverUrl,
      Value<int?> totalPages,
      Value<int?> currentPage,
      required ReadingStatus status,
      Value<double?> rating,
      Value<BookFormat?> bookFormat,
      Value<String?> collectionName,
      Value<int?> collectionNumber,
      Value<String?> coverPath,
      Value<String?> notes,
      Value<String?> description,
      Value<int?> publishYear,
      Value<int?> collectionId,
      Value<int?> imprintId,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> copies,
      Value<PaginationConfig?> paginationConfig,
      Value<DateTime> createdAt,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> subtitle,
      Value<String> author,
      Value<String?> isbn,
      Value<String?> language,
      Value<String?> translator,
      Value<String?> publisher,
      Value<String?> coverUrl,
      Value<int?> totalPages,
      Value<int?> currentPage,
      Value<ReadingStatus> status,
      Value<double?> rating,
      Value<BookFormat?> bookFormat,
      Value<String?> collectionName,
      Value<int?> collectionNumber,
      Value<String?> coverPath,
      Value<String?> notes,
      Value<String?> description,
      Value<int?> publishYear,
      Value<int?> collectionId,
      Value<int?> imprintId,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> copies,
      Value<PaginationConfig?> paginationConfig,
      Value<DateTime> createdAt,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TagsTable _collectionIdTable(_$AppDatabase db) =>
      db.tags.createAlias('books__collection_id__tags__id');

  $$TagsTableProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<int>('collection_id');
    if ($_column == null) return null;
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _imprintIdTable(_$AppDatabase db) =>
      db.tags.createAlias('books__imprint_id__tags__id');

  $$TagsTableProcessedTableManager? get imprintId {
    final $_column = $_itemColumn<int>('imprint_id');
    if ($_column == null) return null;
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_imprintIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BookTagsTable, List<BookTag>> _bookTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bookTags,
    aliasName: 'books__id__book_tags__book_id',
  );

  $$BookTagsTableProcessedTableManager get bookTagsRefs {
    final manager = $$BookTagsTableTableManager(
      $_db,
      $_db.bookTags,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingLogTable, List<ReadingLogData>>
  _readingLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingLog,
    aliasName: 'books__id__reading_log__book_id',
  );

  $$ReadingLogTableProcessedTableManager get readingLogRefs {
    final manager = $$ReadingLogTableTableManager(
      $_db,
      $_db.readingLog,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadHistoryTable, List<ReadHistoryData>>
  _readHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readHistory,
    aliasName: 'books__id__read_history__book_id',
  );

  $$ReadHistoryTableProcessedTableManager get readHistoryRefs {
    final manager = $$ReadHistoryTableTableManager(
      $_db,
      $_db.readHistory,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translator => $composableBuilder(
    column: $table.translator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReadingStatus, ReadingStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BookFormat?, BookFormat, String>
  get bookFormat => $composableBuilder(
    column: $table.bookFormat,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get collectionNumber => $composableBuilder(
    column: $table.collectionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publishYear => $composableBuilder(
    column: $table.publishYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get copies => $composableBuilder(
    column: $table.copies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaginationConfig?, PaginationConfig, String>
  get paginationConfig => $composableBuilder(
    column: $table.paginationConfig,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TagsTableFilterComposer get collectionId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get imprintId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imprintId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> bookTagsRefs(
    Expression<bool> Function($$BookTagsTableFilterComposer f) f,
  ) {
    final $$BookTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingLogRefs(
    Expression<bool> Function($$ReadingLogTableFilterComposer f) f,
  ) {
    final $$ReadingLogTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLog,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogTableFilterComposer(
            $db: $db,
            $table: $db.readingLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readHistoryRefs(
    Expression<bool> Function($$ReadHistoryTableFilterComposer f) f,
  ) {
    final $$ReadHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readHistory,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadHistoryTableFilterComposer(
            $db: $db,
            $table: $db.readHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translator => $composableBuilder(
    column: $table.translator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookFormat => $composableBuilder(
    column: $table.bookFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get collectionNumber => $composableBuilder(
    column: $table.collectionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publishYear => $composableBuilder(
    column: $table.publishYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get copies => $composableBuilder(
    column: $table.copies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paginationConfig => $composableBuilder(
    column: $table.paginationConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagsTableOrderingComposer get collectionId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get imprintId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imprintId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get translator => $composableBuilder(
    column: $table.translator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReadingStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BookFormat?, String> get bookFormat =>
      $composableBuilder(
        column: $table.bookFormat,
        builder: (column) => column,
      );

  GeneratedColumn<String> get collectionName => $composableBuilder(
    column: $table.collectionName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get collectionNumber => $composableBuilder(
    column: $table.collectionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get publishYear => $composableBuilder(
    column: $table.publishYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get copies =>
      $composableBuilder(column: $table.copies, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaginationConfig?, String>
  get paginationConfig => $composableBuilder(
    column: $table.paginationConfig,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TagsTableAnnotationComposer get collectionId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get imprintId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imprintId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> bookTagsRefs<T extends Object>(
    Expression<T> Function($$BookTagsTableAnnotationComposer a) f,
  ) {
    final $$BookTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingLogRefs<T extends Object>(
    Expression<T> Function($$ReadingLogTableAnnotationComposer a) f,
  ) {
    final $$ReadingLogTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLog,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogTableAnnotationComposer(
            $db: $db,
            $table: $db.readingLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readHistoryRefs<T extends Object>(
    Expression<T> Function($$ReadHistoryTableAnnotationComposer a) f,
  ) {
    final $$ReadHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readHistory,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.readHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool collectionId,
            bool imprintId,
            bool bookTagsRefs,
            bool readingLogRefs,
            bool readHistoryRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> translator = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<int?> currentPage = const Value.absent(),
                Value<ReadingStatus> status = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<BookFormat?> bookFormat = const Value.absent(),
                Value<String?> collectionName = const Value.absent(),
                Value<int?> collectionNumber = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> publishYear = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<int?> imprintId = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> copies = const Value.absent(),
                Value<PaginationConfig?> paginationConfig =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                subtitle: subtitle,
                author: author,
                isbn: isbn,
                language: language,
                translator: translator,
                publisher: publisher,
                coverUrl: coverUrl,
                totalPages: totalPages,
                currentPage: currentPage,
                status: status,
                rating: rating,
                bookFormat: bookFormat,
                collectionName: collectionName,
                collectionNumber: collectionNumber,
                coverPath: coverPath,
                notes: notes,
                description: description,
                publishYear: publishYear,
                collectionId: collectionId,
                imprintId: imprintId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                copies: copies,
                paginationConfig: paginationConfig,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> subtitle = const Value.absent(),
                required String author,
                Value<String?> isbn = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<String?> translator = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<int?> currentPage = const Value.absent(),
                required ReadingStatus status,
                Value<double?> rating = const Value.absent(),
                Value<BookFormat?> bookFormat = const Value.absent(),
                Value<String?> collectionName = const Value.absent(),
                Value<int?> collectionNumber = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> publishYear = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
                Value<int?> imprintId = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> copies = const Value.absent(),
                Value<PaginationConfig?> paginationConfig =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                subtitle: subtitle,
                author: author,
                isbn: isbn,
                language: language,
                translator: translator,
                publisher: publisher,
                coverUrl: coverUrl,
                totalPages: totalPages,
                currentPage: currentPage,
                status: status,
                rating: rating,
                bookFormat: bookFormat,
                collectionName: collectionName,
                collectionNumber: collectionNumber,
                coverPath: coverPath,
                notes: notes,
                description: description,
                publishYear: publishYear,
                collectionId: collectionId,
                imprintId: imprintId,
                startedAt: startedAt,
                finishedAt: finishedAt,
                copies: copies,
                paginationConfig: paginationConfig,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                collectionId = false,
                imprintId = false,
                bookTagsRefs = false,
                readingLogRefs = false,
                readHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookTagsRefs) db.bookTags,
                    if (readingLogRefs) db.readingLog,
                    if (readHistoryRefs) db.readHistory,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (collectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.collectionId,
                                    referencedTable: $$BooksTableReferences
                                        ._collectionIdTable(db),
                                    referencedColumn: $$BooksTableReferences
                                        ._collectionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (imprintId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.imprintId,
                                    referencedTable: $$BooksTableReferences
                                        ._imprintIdTable(db),
                                    referencedColumn: $$BooksTableReferences
                                        ._imprintIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookTagsRefs)
                        await $_getPrefetchedData<Book, $BooksTable, BookTag>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingLogRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          ReadingLogData
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readingLogRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readHistoryRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          ReadHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool collectionId,
        bool imprintId,
        bool bookTagsRefs,
        bool readingLogRefs,
        bool readHistoryRefs,
      })
    >;
typedef $$BookTagsTableCreateCompanionBuilder =
    BookTagsCompanion Function({
      required int bookId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$BookTagsTableUpdateCompanionBuilder =
    BookTagsCompanion Function({
      Value<int> bookId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$BookTagsTableReferences
    extends BaseReferences<_$AppDatabase, $BookTagsTable, BookTag> {
  $$BookTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_tags__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('book_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookTagsTableFilterComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookTagsTable,
          BookTag,
          $$BookTagsTableFilterComposer,
          $$BookTagsTableOrderingComposer,
          $$BookTagsTableAnnotationComposer,
          $$BookTagsTableCreateCompanionBuilder,
          $$BookTagsTableUpdateCompanionBuilder,
          (BookTag, $$BookTagsTableReferences),
          BookTag,
          PrefetchHooks Function({bool bookId, bool tagId})
        > {
  $$BookTagsTableTableManager(_$AppDatabase db, $BookTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  BookTagsCompanion(bookId: bookId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required int bookId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => BookTagsCompanion.insert(
                bookId: bookId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$BookTagsTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$BookTagsTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$BookTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$BookTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookTagsTable,
      BookTag,
      $$BookTagsTableFilterComposer,
      $$BookTagsTableOrderingComposer,
      $$BookTagsTableAnnotationComposer,
      $$BookTagsTableCreateCompanionBuilder,
      $$BookTagsTableUpdateCompanionBuilder,
      (BookTag, $$BookTagsTableReferences),
      BookTag,
      PrefetchHooks Function({bool bookId, bool tagId})
    >;
typedef $$ShelvesTableCreateCompanionBuilder =
    ShelvesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> filterQuery,
      Value<String?> filterSubtitle,
      Value<String?> filterAuthor,
      Value<String?> filterPublisher,
      Value<String?> filterIsbn,
      Value<String?> filterLanguage,
      Value<String?> filterTranslator,
      Value<String?> filterCollection,
      Value<String?> filterCollectionIds,
      Value<String?> filterStatus,
      Value<String?> filterTagIds,
      Value<String?> filterImprintIds,
      Value<bool> filterNoCover,
    });
typedef $$ShelvesTableUpdateCompanionBuilder =
    ShelvesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> filterQuery,
      Value<String?> filterSubtitle,
      Value<String?> filterAuthor,
      Value<String?> filterPublisher,
      Value<String?> filterIsbn,
      Value<String?> filterLanguage,
      Value<String?> filterTranslator,
      Value<String?> filterCollection,
      Value<String?> filterCollectionIds,
      Value<String?> filterStatus,
      Value<String?> filterTagIds,
      Value<String?> filterImprintIds,
      Value<bool> filterNoCover,
    });

final class $$ShelvesTableReferences
    extends BaseReferences<_$AppDatabase, $ShelvesTable, Shelf> {
  $$ShelvesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShelfTagsTable, List<ShelfTag>>
  _shelfTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shelfTags,
    aliasName: 'shelves__id__shelf_tags__shelf_id',
  );

  $$ShelfTagsTableProcessedTableManager get shelfTagsRefs {
    final manager = $$ShelfTagsTableTableManager(
      $_db,
      $_db.shelfTags,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shelfTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingGoalsTable, List<ReadingGoal>>
  _readingGoalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingGoals,
    aliasName: 'shelves__id__reading_goals__shelf_id',
  );

  $$ReadingGoalsTableProcessedTableManager get readingGoalsRefs {
    final manager = $$ReadingGoalsTableTableManager(
      $_db,
      $_db.readingGoals,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingGoalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelvesTableFilterComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterQuery => $composableBuilder(
    column: $table.filterQuery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterSubtitle => $composableBuilder(
    column: $table.filterSubtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterAuthor => $composableBuilder(
    column: $table.filterAuthor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterPublisher => $composableBuilder(
    column: $table.filterPublisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterIsbn => $composableBuilder(
    column: $table.filterIsbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterLanguage => $composableBuilder(
    column: $table.filterLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterTranslator => $composableBuilder(
    column: $table.filterTranslator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterCollection => $composableBuilder(
    column: $table.filterCollection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterCollectionIds => $composableBuilder(
    column: $table.filterCollectionIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterStatus => $composableBuilder(
    column: $table.filterStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterTagIds => $composableBuilder(
    column: $table.filterTagIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterImprintIds => $composableBuilder(
    column: $table.filterImprintIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get filterNoCover => $composableBuilder(
    column: $table.filterNoCover,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shelfTagsRefs(
    Expression<bool> Function($$ShelfTagsTableFilterComposer f) f,
  ) {
    final $$ShelfTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfTags,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfTagsTableFilterComposer(
            $db: $db,
            $table: $db.shelfTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingGoalsRefs(
    Expression<bool> Function($$ReadingGoalsTableFilterComposer f) f,
  ) {
    final $$ReadingGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingGoals,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingGoalsTableFilterComposer(
            $db: $db,
            $table: $db.readingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterQuery => $composableBuilder(
    column: $table.filterQuery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterSubtitle => $composableBuilder(
    column: $table.filterSubtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterAuthor => $composableBuilder(
    column: $table.filterAuthor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterPublisher => $composableBuilder(
    column: $table.filterPublisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterIsbn => $composableBuilder(
    column: $table.filterIsbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterLanguage => $composableBuilder(
    column: $table.filterLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterTranslator => $composableBuilder(
    column: $table.filterTranslator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterCollection => $composableBuilder(
    column: $table.filterCollection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterCollectionIds => $composableBuilder(
    column: $table.filterCollectionIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterStatus => $composableBuilder(
    column: $table.filterStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterTagIds => $composableBuilder(
    column: $table.filterTagIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterImprintIds => $composableBuilder(
    column: $table.filterImprintIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get filterNoCover => $composableBuilder(
    column: $table.filterNoCover,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShelvesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filterQuery => $composableBuilder(
    column: $table.filterQuery,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterSubtitle => $composableBuilder(
    column: $table.filterSubtitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterAuthor => $composableBuilder(
    column: $table.filterAuthor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterPublisher => $composableBuilder(
    column: $table.filterPublisher,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterIsbn => $composableBuilder(
    column: $table.filterIsbn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterLanguage => $composableBuilder(
    column: $table.filterLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterTranslator => $composableBuilder(
    column: $table.filterTranslator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterCollection => $composableBuilder(
    column: $table.filterCollection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterCollectionIds => $composableBuilder(
    column: $table.filterCollectionIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterStatus => $composableBuilder(
    column: $table.filterStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterTagIds => $composableBuilder(
    column: $table.filterTagIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterImprintIds => $composableBuilder(
    column: $table.filterImprintIds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get filterNoCover => $composableBuilder(
    column: $table.filterNoCover,
    builder: (column) => column,
  );

  Expression<T> shelfTagsRefs<T extends Object>(
    Expression<T> Function($$ShelfTagsTableAnnotationComposer a) f,
  ) {
    final $$ShelfTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfTags,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingGoalsRefs<T extends Object>(
    Expression<T> Function($$ReadingGoalsTableAnnotationComposer a) f,
  ) {
    final $$ReadingGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingGoals,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelvesTable,
          Shelf,
          $$ShelvesTableFilterComposer,
          $$ShelvesTableOrderingComposer,
          $$ShelvesTableAnnotationComposer,
          $$ShelvesTableCreateCompanionBuilder,
          $$ShelvesTableUpdateCompanionBuilder,
          (Shelf, $$ShelvesTableReferences),
          Shelf,
          PrefetchHooks Function({bool shelfTagsRefs, bool readingGoalsRefs})
        > {
  $$ShelvesTableTableManager(_$AppDatabase db, $ShelvesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelvesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelvesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelvesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> filterQuery = const Value.absent(),
                Value<String?> filterSubtitle = const Value.absent(),
                Value<String?> filterAuthor = const Value.absent(),
                Value<String?> filterPublisher = const Value.absent(),
                Value<String?> filterIsbn = const Value.absent(),
                Value<String?> filterLanguage = const Value.absent(),
                Value<String?> filterTranslator = const Value.absent(),
                Value<String?> filterCollection = const Value.absent(),
                Value<String?> filterCollectionIds = const Value.absent(),
                Value<String?> filterStatus = const Value.absent(),
                Value<String?> filterTagIds = const Value.absent(),
                Value<String?> filterImprintIds = const Value.absent(),
                Value<bool> filterNoCover = const Value.absent(),
              }) => ShelvesCompanion(
                id: id,
                name: name,
                filterQuery: filterQuery,
                filterSubtitle: filterSubtitle,
                filterAuthor: filterAuthor,
                filterPublisher: filterPublisher,
                filterIsbn: filterIsbn,
                filterLanguage: filterLanguage,
                filterTranslator: filterTranslator,
                filterCollection: filterCollection,
                filterCollectionIds: filterCollectionIds,
                filterStatus: filterStatus,
                filterTagIds: filterTagIds,
                filterImprintIds: filterImprintIds,
                filterNoCover: filterNoCover,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> filterQuery = const Value.absent(),
                Value<String?> filterSubtitle = const Value.absent(),
                Value<String?> filterAuthor = const Value.absent(),
                Value<String?> filterPublisher = const Value.absent(),
                Value<String?> filterIsbn = const Value.absent(),
                Value<String?> filterLanguage = const Value.absent(),
                Value<String?> filterTranslator = const Value.absent(),
                Value<String?> filterCollection = const Value.absent(),
                Value<String?> filterCollectionIds = const Value.absent(),
                Value<String?> filterStatus = const Value.absent(),
                Value<String?> filterTagIds = const Value.absent(),
                Value<String?> filterImprintIds = const Value.absent(),
                Value<bool> filterNoCover = const Value.absent(),
              }) => ShelvesCompanion.insert(
                id: id,
                name: name,
                filterQuery: filterQuery,
                filterSubtitle: filterSubtitle,
                filterAuthor: filterAuthor,
                filterPublisher: filterPublisher,
                filterIsbn: filterIsbn,
                filterLanguage: filterLanguage,
                filterTranslator: filterTranslator,
                filterCollection: filterCollection,
                filterCollectionIds: filterCollectionIds,
                filterStatus: filterStatus,
                filterTagIds: filterTagIds,
                filterImprintIds: filterImprintIds,
                filterNoCover: filterNoCover,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShelvesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({shelfTagsRefs = false, readingGoalsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (shelfTagsRefs) db.shelfTags,
                    if (readingGoalsRefs) db.readingGoals,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (shelfTagsRefs)
                        await $_getPrefetchedData<
                          Shelf,
                          $ShelvesTable,
                          ShelfTag
                        >(
                          currentTable: table,
                          referencedTable: $$ShelvesTableReferences
                              ._shelfTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShelvesTableReferences(
                                db,
                                table,
                                p0,
                              ).shelfTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shelfId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingGoalsRefs)
                        await $_getPrefetchedData<
                          Shelf,
                          $ShelvesTable,
                          ReadingGoal
                        >(
                          currentTable: table,
                          referencedTable: $$ShelvesTableReferences
                              ._readingGoalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShelvesTableReferences(
                                db,
                                table,
                                p0,
                              ).readingGoalsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shelfId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ShelvesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelvesTable,
      Shelf,
      $$ShelvesTableFilterComposer,
      $$ShelvesTableOrderingComposer,
      $$ShelvesTableAnnotationComposer,
      $$ShelvesTableCreateCompanionBuilder,
      $$ShelvesTableUpdateCompanionBuilder,
      (Shelf, $$ShelvesTableReferences),
      Shelf,
      PrefetchHooks Function({bool shelfTagsRefs, bool readingGoalsRefs})
    >;
typedef $$ShelfTagsTableCreateCompanionBuilder =
    ShelfTagsCompanion Function({
      required int shelfId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$ShelfTagsTableUpdateCompanionBuilder =
    ShelfTagsCompanion Function({
      Value<int> shelfId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$ShelfTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ShelfTagsTable, ShelfTag> {
  $$ShelfTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShelvesTable _shelfIdTable(_$AppDatabase db) =>
      db.shelves.createAlias('shelf_tags__shelf_id__shelves__id');

  $$ShelvesTableProcessedTableManager get shelfId {
    final $_column = $_itemColumn<int>('shelf_id')!;

    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('shelf_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShelfTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ShelfTagsTable> {
  $$ShelfTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelfTagsTable> {
  $$ShelfTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelfTagsTable> {
  $$ShelfTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelfTagsTable,
          ShelfTag,
          $$ShelfTagsTableFilterComposer,
          $$ShelfTagsTableOrderingComposer,
          $$ShelfTagsTableAnnotationComposer,
          $$ShelfTagsTableCreateCompanionBuilder,
          $$ShelfTagsTableUpdateCompanionBuilder,
          (ShelfTag, $$ShelfTagsTableReferences),
          ShelfTag,
          PrefetchHooks Function({bool shelfId, bool tagId})
        > {
  $$ShelfTagsTableTableManager(_$AppDatabase db, $ShelfTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelfTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelfTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelfTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> shelfId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelfTagsCompanion(
                shelfId: shelfId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int shelfId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => ShelfTagsCompanion.insert(
                shelfId: shelfId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShelfTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shelfId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shelfId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shelfId,
                                referencedTable: $$ShelfTagsTableReferences
                                    ._shelfIdTable(db),
                                referencedColumn: $$ShelfTagsTableReferences
                                    ._shelfIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$ShelfTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$ShelfTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShelfTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelfTagsTable,
      ShelfTag,
      $$ShelfTagsTableFilterComposer,
      $$ShelfTagsTableOrderingComposer,
      $$ShelfTagsTableAnnotationComposer,
      $$ShelfTagsTableCreateCompanionBuilder,
      $$ShelfTagsTableUpdateCompanionBuilder,
      (ShelfTag, $$ShelfTagsTableReferences),
      ShelfTag,
      PrefetchHooks Function({bool shelfId, bool tagId})
    >;
typedef $$ReadingGoalsTableCreateCompanionBuilder =
    ReadingGoalsCompanion Function({
      Value<int> id,
      required String title,
      required String type,
      required int targetValue,
      required DateTime startDate,
      required DateTime endDate,
      Value<int?> shelfId,
      Value<int?> collectionId,
    });
typedef $$ReadingGoalsTableUpdateCompanionBuilder =
    ReadingGoalsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> type,
      Value<int> targetValue,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<int?> shelfId,
      Value<int?> collectionId,
    });

final class $$ReadingGoalsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingGoalsTable, ReadingGoal> {
  $$ReadingGoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShelvesTable _shelfIdTable(_$AppDatabase db) =>
      db.shelves.createAlias('reading_goals__shelf_id__shelves__id');

  $$ShelvesTableProcessedTableManager? get shelfId {
    final $_column = $_itemColumn<int>('shelf_id');
    if ($_column == null) return null;
    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _collectionIdTable(_$AppDatabase db) =>
      db.tags.createAlias('reading_goals__collection_id__tags__id');

  $$TagsTableProcessedTableManager? get collectionId {
    final $_column = $_itemColumn<int>('collection_id');
    if ($_column == null) return null;
    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StatWidgetConfigsTable, List<StatWidgetConfig>>
  _statWidgetConfigsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.statWidgetConfigs,
        aliasName: 'reading_goals__id__stat_widget_configs__goal_id',
      );

  $$StatWidgetConfigsTableProcessedTableManager get statWidgetConfigsRefs {
    final manager = $$StatWidgetConfigsTableTableManager(
      $_db,
      $_db.statWidgetConfigs,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _statWidgetConfigsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReadingGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingGoalsTable> {
  $$ReadingGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get collectionId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> statWidgetConfigsRefs(
    Expression<bool> Function($$StatWidgetConfigsTableFilterComposer f) f,
  ) {
    final $$StatWidgetConfigsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statWidgetConfigs,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatWidgetConfigsTableFilterComposer(
            $db: $db,
            $table: $db.statWidgetConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReadingGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingGoalsTable> {
  $$ReadingGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get collectionId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingGoalsTable> {
  $$ReadingGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get collectionId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> statWidgetConfigsRefs<T extends Object>(
    Expression<T> Function($$StatWidgetConfigsTableAnnotationComposer a) f,
  ) {
    final $$StatWidgetConfigsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.statWidgetConfigs,
          getReferencedColumn: (t) => t.goalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StatWidgetConfigsTableAnnotationComposer(
                $db: $db,
                $table: $db.statWidgetConfigs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReadingGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingGoalsTable,
          ReadingGoal,
          $$ReadingGoalsTableFilterComposer,
          $$ReadingGoalsTableOrderingComposer,
          $$ReadingGoalsTableAnnotationComposer,
          $$ReadingGoalsTableCreateCompanionBuilder,
          $$ReadingGoalsTableUpdateCompanionBuilder,
          (ReadingGoal, $$ReadingGoalsTableReferences),
          ReadingGoal,
          PrefetchHooks Function({
            bool shelfId,
            bool collectionId,
            bool statWidgetConfigsRefs,
          })
        > {
  $$ReadingGoalsTableTableManager(_$AppDatabase db, $ReadingGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> targetValue = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<int?> shelfId = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
              }) => ReadingGoalsCompanion(
                id: id,
                title: title,
                type: type,
                targetValue: targetValue,
                startDate: startDate,
                endDate: endDate,
                shelfId: shelfId,
                collectionId: collectionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String type,
                required int targetValue,
                required DateTime startDate,
                required DateTime endDate,
                Value<int?> shelfId = const Value.absent(),
                Value<int?> collectionId = const Value.absent(),
              }) => ReadingGoalsCompanion.insert(
                id: id,
                title: title,
                type: type,
                targetValue: targetValue,
                startDate: startDate,
                endDate: endDate,
                shelfId: shelfId,
                collectionId: collectionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingGoalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shelfId = false,
                collectionId = false,
                statWidgetConfigsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (statWidgetConfigsRefs) db.statWidgetConfigs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shelfId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shelfId,
                                    referencedTable:
                                        $$ReadingGoalsTableReferences
                                            ._shelfIdTable(db),
                                    referencedColumn:
                                        $$ReadingGoalsTableReferences
                                            ._shelfIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (collectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.collectionId,
                                    referencedTable:
                                        $$ReadingGoalsTableReferences
                                            ._collectionIdTable(db),
                                    referencedColumn:
                                        $$ReadingGoalsTableReferences
                                            ._collectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (statWidgetConfigsRefs)
                        await $_getPrefetchedData<
                          ReadingGoal,
                          $ReadingGoalsTable,
                          StatWidgetConfig
                        >(
                          currentTable: table,
                          referencedTable: $$ReadingGoalsTableReferences
                              ._statWidgetConfigsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReadingGoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).statWidgetConfigsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.goalId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReadingGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingGoalsTable,
      ReadingGoal,
      $$ReadingGoalsTableFilterComposer,
      $$ReadingGoalsTableOrderingComposer,
      $$ReadingGoalsTableAnnotationComposer,
      $$ReadingGoalsTableCreateCompanionBuilder,
      $$ReadingGoalsTableUpdateCompanionBuilder,
      (ReadingGoal, $$ReadingGoalsTableReferences),
      ReadingGoal,
      PrefetchHooks Function({
        bool shelfId,
        bool collectionId,
        bool statWidgetConfigsRefs,
      })
    >;
typedef $$ReadingLogTableCreateCompanionBuilder =
    ReadingLogCompanion Function({
      Value<int> id,
      required int bookId,
      required DateTime date,
      required int pagesRead,
      Value<List<String>?> sections,
    });
typedef $$ReadingLogTableUpdateCompanionBuilder =
    ReadingLogCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<DateTime> date,
      Value<int> pagesRead,
      Value<List<String>?> sections,
    });

final class $$ReadingLogTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingLogTable, ReadingLogData> {
  $$ReadingLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_log__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingLogTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingLogTable> {
  $$ReadingLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get sections => $composableBuilder(
    column: $table.sections,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingLogTable> {
  $$ReadingLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sections => $composableBuilder(
    column: $table.sections,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingLogTable> {
  $$ReadingLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get pagesRead =>
      $composableBuilder(column: $table.pagesRead, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get sections =>
      $composableBuilder(column: $table.sections, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingLogTable,
          ReadingLogData,
          $$ReadingLogTableFilterComposer,
          $$ReadingLogTableOrderingComposer,
          $$ReadingLogTableAnnotationComposer,
          $$ReadingLogTableCreateCompanionBuilder,
          $$ReadingLogTableUpdateCompanionBuilder,
          (ReadingLogData, $$ReadingLogTableReferences),
          ReadingLogData,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadingLogTableTableManager(_$AppDatabase db, $ReadingLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> pagesRead = const Value.absent(),
                Value<List<String>?> sections = const Value.absent(),
              }) => ReadingLogCompanion(
                id: id,
                bookId: bookId,
                date: date,
                pagesRead: pagesRead,
                sections: sections,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required DateTime date,
                required int pagesRead,
                Value<List<String>?> sections = const Value.absent(),
              }) => ReadingLogCompanion.insert(
                id: id,
                bookId: bookId,
                date: date,
                pagesRead: pagesRead,
                sections: sections,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingLogTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$ReadingLogTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$ReadingLogTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingLogTable,
      ReadingLogData,
      $$ReadingLogTableFilterComposer,
      $$ReadingLogTableOrderingComposer,
      $$ReadingLogTableAnnotationComposer,
      $$ReadingLogTableCreateCompanionBuilder,
      $$ReadingLogTableUpdateCompanionBuilder,
      (ReadingLogData, $$ReadingLogTableReferences),
      ReadingLogData,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$StatWidgetConfigsTableCreateCompanionBuilder =
    StatWidgetConfigsCompanion Function({
      Value<int> id,
      required String type,
      required String size,
      required int sortOrder,
      Value<int?> goalId,
      Value<String?> config,
    });
typedef $$StatWidgetConfigsTableUpdateCompanionBuilder =
    StatWidgetConfigsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> size,
      Value<int> sortOrder,
      Value<int?> goalId,
      Value<String?> config,
    });

final class $$StatWidgetConfigsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StatWidgetConfigsTable,
          StatWidgetConfig
        > {
  $$StatWidgetConfigsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReadingGoalsTable _goalIdTable(_$AppDatabase db) => db.readingGoals
      .createAlias('stat_widget_configs__goal_id__reading_goals__id');

  $$ReadingGoalsTableProcessedTableManager? get goalId {
    final $_column = $_itemColumn<int>('goal_id');
    if ($_column == null) return null;
    final manager = $$ReadingGoalsTableTableManager(
      $_db,
      $_db.readingGoals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StatWidgetConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $StatWidgetConfigsTable> {
  $$StatWidgetConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnFilters(column),
  );

  $$ReadingGoalsTableFilterComposer get goalId {
    final $$ReadingGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.readingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingGoalsTableFilterComposer(
            $db: $db,
            $table: $db.readingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatWidgetConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $StatWidgetConfigsTable> {
  $$StatWidgetConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReadingGoalsTableOrderingComposer get goalId {
    final $$ReadingGoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.readingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingGoalsTableOrderingComposer(
            $db: $db,
            $table: $db.readingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatWidgetConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatWidgetConfigsTable> {
  $$StatWidgetConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  $$ReadingGoalsTableAnnotationComposer get goalId {
    final $$ReadingGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.readingGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatWidgetConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatWidgetConfigsTable,
          StatWidgetConfig,
          $$StatWidgetConfigsTableFilterComposer,
          $$StatWidgetConfigsTableOrderingComposer,
          $$StatWidgetConfigsTableAnnotationComposer,
          $$StatWidgetConfigsTableCreateCompanionBuilder,
          $$StatWidgetConfigsTableUpdateCompanionBuilder,
          (StatWidgetConfig, $$StatWidgetConfigsTableReferences),
          StatWidgetConfig,
          PrefetchHooks Function({bool goalId})
        > {
  $$StatWidgetConfigsTableTableManager(
    _$AppDatabase db,
    $StatWidgetConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatWidgetConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatWidgetConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatWidgetConfigsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> size = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> goalId = const Value.absent(),
                Value<String?> config = const Value.absent(),
              }) => StatWidgetConfigsCompanion(
                id: id,
                type: type,
                size: size,
                sortOrder: sortOrder,
                goalId: goalId,
                config: config,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String size,
                required int sortOrder,
                Value<int?> goalId = const Value.absent(),
                Value<String?> config = const Value.absent(),
              }) => StatWidgetConfigsCompanion.insert(
                id: id,
                type: type,
                size: size,
                sortOrder: sortOrder,
                goalId: goalId,
                config: config,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StatWidgetConfigsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalId,
                                referencedTable:
                                    $$StatWidgetConfigsTableReferences
                                        ._goalIdTable(db),
                                referencedColumn:
                                    $$StatWidgetConfigsTableReferences
                                        ._goalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StatWidgetConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatWidgetConfigsTable,
      StatWidgetConfig,
      $$StatWidgetConfigsTableFilterComposer,
      $$StatWidgetConfigsTableOrderingComposer,
      $$StatWidgetConfigsTableAnnotationComposer,
      $$StatWidgetConfigsTableCreateCompanionBuilder,
      $$StatWidgetConfigsTableUpdateCompanionBuilder,
      (StatWidgetConfig, $$StatWidgetConfigsTableReferences),
      StatWidgetConfig,
      PrefetchHooks Function({bool goalId})
    >;
typedef $$ReadHistoryTableCreateCompanionBuilder =
    ReadHistoryCompanion Function({
      Value<int> id,
      required int bookId,
      required int readNumber,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
      Value<List<String>?> sections,
      Value<int> progress,
      Value<Map<int, int>?> segmentProgress,
    });
typedef $$ReadHistoryTableUpdateCompanionBuilder =
    ReadHistoryCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> readNumber,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
      Value<List<String>?> sections,
      Value<int> progress,
      Value<Map<int, int>?> segmentProgress,
    });

final class $$ReadHistoryTableReferences
    extends BaseReferences<_$AppDatabase, $ReadHistoryTable, ReadHistoryData> {
  $$ReadHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('read_history__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ReadHistoryTable> {
  $$ReadHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readNumber => $composableBuilder(
    column: $table.readNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get sections => $composableBuilder(
    column: $table.sections,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Map<int, int>?, Map<int, int>, String>
  get segmentProgress => $composableBuilder(
    column: $table.segmentProgress,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadHistoryTable> {
  $$ReadHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readNumber => $composableBuilder(
    column: $table.readNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sections => $composableBuilder(
    column: $table.sections,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentProgress => $composableBuilder(
    column: $table.segmentProgress,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadHistoryTable> {
  $$ReadHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get readNumber => $composableBuilder(
    column: $table.readNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>?, String> get sections =>
      $composableBuilder(column: $table.sections, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<int, int>?, String>
  get segmentProgress => $composableBuilder(
    column: $table.segmentProgress,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadHistoryTable,
          ReadHistoryData,
          $$ReadHistoryTableFilterComposer,
          $$ReadHistoryTableOrderingComposer,
          $$ReadHistoryTableAnnotationComposer,
          $$ReadHistoryTableCreateCompanionBuilder,
          $$ReadHistoryTableUpdateCompanionBuilder,
          (ReadHistoryData, $$ReadHistoryTableReferences),
          ReadHistoryData,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadHistoryTableTableManager(_$AppDatabase db, $ReadHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> readNumber = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<List<String>?> sections = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<Map<int, int>?> segmentProgress = const Value.absent(),
              }) => ReadHistoryCompanion(
                id: id,
                bookId: bookId,
                readNumber: readNumber,
                startedAt: startedAt,
                finishedAt: finishedAt,
                sections: sections,
                progress: progress,
                segmentProgress: segmentProgress,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int readNumber,
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<List<String>?> sections = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<Map<int, int>?> segmentProgress = const Value.absent(),
              }) => ReadHistoryCompanion.insert(
                id: id,
                bookId: bookId,
                readNumber: readNumber,
                startedAt: startedAt,
                finishedAt: finishedAt,
                sections: sections,
                progress: progress,
                segmentProgress: segmentProgress,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$ReadHistoryTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$ReadHistoryTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadHistoryTable,
      ReadHistoryData,
      $$ReadHistoryTableFilterComposer,
      $$ReadHistoryTableOrderingComposer,
      $$ReadHistoryTableAnnotationComposer,
      $$ReadHistoryTableCreateCompanionBuilder,
      $$ReadHistoryTableUpdateCompanionBuilder,
      (ReadHistoryData, $$ReadHistoryTableReferences),
      ReadHistoryData,
      PrefetchHooks Function({bool bookId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookTagsTableTableManager get bookTags =>
      $$BookTagsTableTableManager(_db, _db.bookTags);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db, _db.shelves);
  $$ShelfTagsTableTableManager get shelfTags =>
      $$ShelfTagsTableTableManager(_db, _db.shelfTags);
  $$ReadingGoalsTableTableManager get readingGoals =>
      $$ReadingGoalsTableTableManager(_db, _db.readingGoals);
  $$ReadingLogTableTableManager get readingLog =>
      $$ReadingLogTableTableManager(_db, _db.readingLog);
  $$StatWidgetConfigsTableTableManager get statWidgetConfigs =>
      $$StatWidgetConfigsTableTableManager(_db, _db.statWidgetConfigs);
  $$ReadHistoryTableTableManager get readHistory =>
      $$ReadHistoryTableTableManager(_db, _db.readHistory);
}
