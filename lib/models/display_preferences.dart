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
