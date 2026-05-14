enum LibraryViewMode { list, grid }

const _defaultFieldOrder = [
  'tags',
  'spacer',
  'info', // Combined author, year, publisher
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

/// User preferences for how the book library is displayed and sorted.
class DisplayPreferences {
  final LibraryViewMode viewMode;
  final bool showProgress;
  final bool showTags;
  final bool showRating;
  final bool showAuthor; // Visible inside the 'info' row
  final bool showStatusChip;
  final bool showPublisher; // Visible inside the 'info' row
  final List<String> fieldOrder;
  final bool showYear; // Visible inside the 'info' row
  final bool showSpacer;
  
  /// The hierarchical list of sorting criteria.
  final List<String> sortOrder;
  
  /// Per-field sorting direction (true for ascending).
  final Map<String, bool> sortDirections; 
  
  /// Whether to push books with missing metadata to the end of the list.
  final bool emptyAtEnd; 

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
    this.sortOrder = const [..._defaultSortOrder],
    this.sortDirections = const {
      'title': true,
      'author': true,
      'publisher': true,
      'collection': true,
      'imprint': true,
      'publishYear': true,
      'createdAt': true,
      'rating': false, // Rating defaults to highest first (descending)
    },
    this.emptyAtEnd = true,
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
    );
  }
}
