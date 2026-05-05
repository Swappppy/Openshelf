enum LibraryViewMode { list, grid }

const _defaultFieldOrder = [
  'tags',
  'author',
  'publisher',
  'rating',
];

const _fixedFields = [
  'progress',
  'status',
];

class DisplayPreferences {
  final LibraryViewMode viewMode;
  final bool showProgress;
  final bool showTags;
  final bool showRating;
  final bool showAuthor;
  final bool showStatusChip;
  final bool showPublisher;
  final List<String> fieldOrder;

  const DisplayPreferences({
    this.viewMode = LibraryViewMode.list,
    this.showProgress = true,
    this.showTags = true,
    this.showRating = false,
    this.showAuthor = true,
    this.showStatusChip = true,
    this.showPublisher = false,
    this.fieldOrder = const [..._defaultFieldOrder],
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
    );
  }
}