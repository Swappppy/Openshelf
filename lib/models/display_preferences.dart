enum LibraryViewMode { list, grid }

const _defaultFieldOrder = [
  'tags',
  'spacer',
  'info', 
  'rating',
];

const _defaultSortOrder = [
  'title',
  'author',
  'publisher',
  'collection',
  'imprint',
  'publishYear',
  'createdAt',
  'rating',
];

/// Default sorting for different organization tabs in Shelves view.
const _defaultShelfSortOrder = ['name', 'count', 'progress'];
const _defaultCategorySortOrder = ['name', 'usage', 'color'];
const _defaultImprintSortOrder = ['name', 'count'];
const _defaultCollectionSortOrder = ['name', 'count'];

/// User preferences for how the book library and other sections are displayed and sorted.
class DisplayPreferences {
  final LibraryViewMode viewMode;
  final bool showProgress;
  final bool showTags;
  final bool showRating;
  final bool showAuthor; 
  final bool showStatusChip;
  final bool showPublisher; 
  final List<String> fieldOrder;
  final bool showYear; 
  final bool showSpacer;
  
  // Library Sorting
  final List<String> sortOrder;
  final Map<String, bool> sortDirections; 
  final bool emptyAtEnd; 

  // Shelves Tab Sorting
  final List<String> shelfSortOrder;
  final Map<String, bool> shelfSortDirections;

  // Categories Tab Sorting
  final List<String> categorySortOrder;
  final Map<String, bool> categorySortDirections;
  final int tagCloudMaxCount;

  // Imprints Tab Sorting
  final List<String> imprintSortOrder;
  final Map<String, bool> imprintSortDirections;

  // Collections Tab Sorting
  final List<String> collectionSortOrder;
  final Map<String, bool> collectionSortDirections;

  const DisplayPreferences({
    this.viewMode = LibraryViewMode.list,
    this.showProgress = true,
    this.showTags = true,
    this.showRating = false,
    this.showAuthor = true,
    this.showStatusChip = true,
    this.showPublisher = true,
    this.fieldOrder = const [..._defaultFieldOrder],
    this.showYear = true,
    this.showSpacer = true,
    
    // Library
    this.sortOrder = const [..._defaultSortOrder],
    this.sortDirections = const {
      'title': true, 'author': true, 'publisher': true, 
      'collection': true, 'imprint': true, 'publishYear': true, 
      'createdAt': true, 'rating': false,
    },
    this.emptyAtEnd = true,

    // Shelves context
    this.shelfSortOrder = const [..._defaultShelfSortOrder],
    this.shelfSortDirections = const {'name': true, 'count': false, 'progress': false},

    // Category context
    this.categorySortOrder = const [..._defaultCategorySortOrder],
    this.categorySortDirections = const {'name': true, 'usage': false, 'color': true},
    this.tagCloudMaxCount = 50,

    // Imprint context
    this.imprintSortOrder = const [..._defaultImprintSortOrder],
    this.imprintSortDirections = const {'name': true, 'count': false},

    // Collection context
    this.collectionSortOrder = const [..._defaultCollectionSortOrder],
    this.collectionSortDirections = const {'name': true, 'count': false},
  });

  Map<String, dynamic> toJson() {
    return {
      'viewMode': viewMode.name,
      'showProgress': showProgress,
      'showTags': showTags,
      'showRating': showRating,
      'showAuthor': showAuthor,
      'showStatusChip': showStatusChip,
      'showPublisher': showPublisher,
      'fieldOrder': fieldOrder,
      'showYear': showYear,
      'showSpacer': showSpacer,
      'sortOrder': sortOrder,
      'sortDirections': sortDirections,
      'emptyAtEnd': emptyAtEnd,
      'shelfSortOrder': shelfSortOrder,
      'shelfSortDirections': shelfSortDirections,
      'categorySortOrder': categorySortOrder,
      'categorySortDirections': categorySortDirections,
      'tagCloudMaxCount': tagCloudMaxCount,
      'imprintSortOrder': imprintSortOrder,
      'imprintSortDirections': imprintSortDirections,
      'collectionSortOrder': collectionSortOrder,
      'collectionSortDirections': collectionSortDirections,
    };
  }

  factory DisplayPreferences.fromJson(Map<String, dynamic> json) {
    return DisplayPreferences(
      viewMode: LibraryViewMode.values.byName(json['viewMode'] as String? ?? 'list'),
      showProgress: json['showProgress'] as bool? ?? true,
      showTags: json['showTags'] as bool? ?? true,
      showRating: json['showRating'] as bool? ?? false,
      showAuthor: json['showAuthor'] as bool? ?? true,
      showStatusChip: json['showStatusChip'] as bool? ?? true,
      showPublisher: json['showPublisher'] as bool? ?? true,
      fieldOrder: (json['fieldOrder'] as List<dynamic>?)?.cast<String>() ?? [..._defaultFieldOrder],
      showYear: json['showYear'] as bool? ?? true,
      showSpacer: json['showSpacer'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as List<dynamic>?)?.cast<String>() ?? [..._defaultSortOrder],
      sortDirections: (json['sortDirections'] as Map<String, dynamic>?)?.cast<String, bool>() ?? const {
        'title': true, 'author': true, 'publisher': true, 
        'collection': true, 'imprint': true, 'publishYear': true, 
        'createdAt': true, 'rating': false,
      },
      emptyAtEnd: json['emptyAtEnd'] as bool? ?? true,
      shelfSortOrder: (json['shelfSortOrder'] as List<dynamic>?)?.cast<String>() ?? [..._defaultShelfSortOrder],
      shelfSortDirections: (json['shelfSortDirections'] as Map<String, dynamic>?)?.cast<String, bool>() ?? const {'name': true, 'count': false, 'progress': false},
      categorySortOrder: (json['categorySortOrder'] as List<dynamic>?)?.cast<String>() ?? [..._defaultCategorySortOrder],
      categorySortDirections: (json['categorySortDirections'] as Map<String, dynamic>?)?.cast<String, bool>() ?? const {'name': true, 'usage': false, 'color': true},
      tagCloudMaxCount: json['tagCloudMaxCount'] as int? ?? 50,
      imprintSortOrder: (json['imprintSortOrder'] as List<dynamic>?)?.cast<String>() ?? [..._defaultImprintSortOrder],
      imprintSortDirections: (json['imprintSortDirections'] as Map<String, dynamic>?)?.cast<String, bool>() ?? const {'name': true, 'count': false},
      collectionSortOrder: (json['collectionSortOrder'] as List<dynamic>?)?.cast<String>() ?? [..._defaultCollectionSortOrder],
      collectionSortDirections: (json['collectionSortDirections'] as Map<String, dynamic>?)?.cast<String, bool>() ?? const {'name': true, 'count': false},
    );
  }

  DisplayPreferences copyWith({
    LibraryViewMode? viewMode,
    bool? showProgress,
    bool? showTags,
    bool? showRating,
    bool? showAuthor,
    bool? showStatusChip,
    bool? showPublisher,
    List<String>? fieldOrder,
    bool? showYear,
    bool? showSpacer,
    
    List<String>? sortOrder,
    Map<String, bool>? sortDirections,
    bool? emptyAtEnd,

    List<String>? shelfSortOrder,
    Map<String, bool>? shelfSortDirections,

    List<String>? categorySortOrder,
    Map<String, bool>? categorySortDirections,
    int? tagCloudMaxCount,

    List<String>? imprintSortOrder,
    Map<String, bool>? imprintSortDirections,

    List<String>? collectionSortOrder,
    Map<String, bool>? collectionSortDirections,
  }) {
    return DisplayPreferences(
      viewMode: viewMode ?? this.viewMode,
      showProgress: showProgress ?? this.showProgress,
      showTags: showTags ?? this.showTags,
      showRating: showRating ?? this.showRating,
      showAuthor: showAuthor ?? this.showAuthor,
      showStatusChip: showStatusChip ?? this.showStatusChip,
      showPublisher: showPublisher ?? this.showPublisher,
      fieldOrder: fieldOrder ?? this.fieldOrder,
      showYear: showYear ?? this.showYear,
      showSpacer: showSpacer ?? this.showSpacer,
      
      sortOrder: sortOrder ?? this.sortOrder,
      sortDirections: sortDirections ?? this.sortDirections,
      emptyAtEnd: emptyAtEnd ?? this.emptyAtEnd,

      shelfSortOrder: shelfSortOrder ?? this.shelfSortOrder,
      shelfSortDirections: shelfSortDirections ?? this.shelfSortDirections,

      categorySortOrder: categorySortOrder ?? this.categorySortOrder,
      categorySortDirections: categorySortDirections ?? this.categorySortDirections,
      tagCloudMaxCount: tagCloudMaxCount ?? this.tagCloudMaxCount,

      imprintSortOrder: imprintSortOrder ?? this.imprintSortOrder,
      imprintSortDirections: imprintSortDirections ?? this.imprintSortDirections,

      collectionSortOrder: collectionSortOrder ?? this.collectionSortOrder,
      collectionSortDirections: collectionSortDirections ?? this.collectionSortDirections,
    );
  }
}
