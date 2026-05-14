// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Openshelf';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String criticalStartError(String error) {
    return 'Error starting application: $error';
  }

  @override
  String get navLibrary => 'Library';

  @override
  String get navShelves => 'Shelves';

  @override
  String get navStats => 'Stats';

  @override
  String get libraryTitle => 'My Library';

  @override
  String get libraryEmpty => 'Your library is empty';

  @override
  String get libraryEmptyHint => 'Tap + to add your first book';

  @override
  String get libraryNoResults => 'No results';

  @override
  String get libraryNoResultsHint => 'Try different filters';

  @override
  String get addBook => 'Add book';

  @override
  String get displaySettings => 'Show in library';

  @override
  String get displaySettingsDragHint => 'Drag to reorder';

  @override
  String get settingsButton => 'Settings';

  @override
  String get fieldAuthor => 'Author';

  @override
  String get fieldPublisher => 'Publisher';

  @override
  String get fieldYear => 'Published year';

  @override
  String get fieldRating => 'Rating';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldReadingProgress => 'Reading progress';

  @override
  String get fieldStatusChip => 'Status chip';

  @override
  String get searchHint => 'Search by title…';

  @override
  String get filterAuthor => 'Author';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Publisher';

  @override
  String get filterCollection => 'Collection';

  @override
  String get filterImprintLabel => 'Imprint';

  @override
  String imprintBookCount(int count) {
    return '$count books';
  }

  @override
  String get filterTagsLabel => 'Categories';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get photo => 'Photo';

  @override
  String get url => 'URL';

  @override
  String get download => 'Download';

  @override
  String get retry => 'Retry';

  @override
  String get addBookModalTitle => 'Add book';

  @override
  String get addBookModalSubtitle => 'Choose how you want to add your book';

  @override
  String get addManually => 'Add manually';

  @override
  String get addManuallySubtitle => 'Fill in the data yourself';

  @override
  String get searchBook => 'Search book';

  @override
  String get searchBookSubtitle => 'By title, author, or ISBN';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scanBarcodeSubtitle => 'Point the camera at the ISBN';

  @override
  String get scanIsbnText => 'Scan ISBN Number';

  @override
  String get scanIsbnTextSubtitle => 'Point at the printed number';

  @override
  String get scanBarcodePermission =>
      'Camera permission required to scan barcodes';

  @override
  String get scanBatch => 'Batch scan';

  @override
  String get scanBatchSubtitle => 'Scan multiple books in a row';

  @override
  String get bookFormNewTitle => 'New book';

  @override
  String get bookFormEditTitle => 'Edit book';

  @override
  String get tabMain => 'Main';

  @override
  String get tabDetails => 'Details';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldTotalPages => 'Total pages';

  @override
  String get fieldCurrentPage => 'Current page';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldCollection => 'Collection / Series';

  @override
  String get fieldCollectionNumber => 'Number in collection';

  @override
  String get sectionBasicInfo => 'Basic info';

  @override
  String get sectionCategories => 'Categories';

  @override
  String get sectionReadingStatus => 'Reading status';

  @override
  String get sectionFormat => 'Format';

  @override
  String get sectionRating => 'Rating';

  @override
  String get sectionImprint => 'Imprint';

  @override
  String get coverPickPhoto => 'Photo';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Search';

  @override
  String get coverUrlDialogTitle => 'Cover URL';

  @override
  String get coverUrlHint => 'https://example.com/cover.jpg';

  @override
  String get coverDownloadError => 'Could not download image';

  @override
  String get cropCoverTitle => 'Crop cover';

  @override
  String get cropImprintTitle => 'Crop imprint';

  @override
  String get tagSearchOrCreate => 'Search or create category';

  @override
  String get tagCreateHint => 'Type and press Enter to add or create';

  @override
  String get tagNoCategories => 'No categories created yet';

  @override
  String get imprintSearch => 'Search imprint';

  @override
  String get requiredField => 'Required field';

  @override
  String get statusWantToRead => 'Want to read';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusRead => 'Read';

  @override
  String get statusAbandoned => 'Abandoned';

  @override
  String get statusPaused => 'Paused';

  @override
  String get formatPaperback => 'Paperback';

  @override
  String get formatHardcover => 'Hardcover';

  @override
  String get formatLeatherbound => 'Leatherbound';

  @override
  String get formatRustic => 'Rustic';

  @override
  String get formatDigital => 'Digital';

  @override
  String get formatOther => 'Other';

  @override
  String get bookDetailNotFound => 'Book not found';

  @override
  String get bookDetailPagePickerTitle => 'Current page';

  @override
  String get bookDetailNotesTitle => 'Personal notes';

  @override
  String get bookDetailNotesHint => 'Write your notes here…';

  @override
  String get bookDetailNotesEmpty => 'Tap to add notes…';

  @override
  String get bookDetailDeleteTitle => 'Delete book';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get bookDetailFieldPages => 'PAGES';

  @override
  String get bookDetailFieldCategories => 'CATEGORIES';

  @override
  String get bookDetailFieldFormat => 'Format';

  @override
  String get bookDetailFieldRating => 'RATING';

  @override
  String get bookDetailFieldImprintSection => 'IMPRINT';

  @override
  String get bookDetailFieldPersonalNotes => 'PERSONAL NOTES';

  @override
  String get bookDetailFieldAdded => 'Added';

  @override
  String get bookDetailFieldStarted => 'Started reading';

  @override
  String get bookDetailFieldFinished => 'Finished reading';

  @override
  String pageProgress(int current, int total, String percent) {
    return '$current / $total pages · $percent%';
  }

  @override
  String pageProgressShort(int current, int total) {
    return '$current / $total';
  }

  @override
  String pageSuffix(int count) {
    return '$count pages';
  }

  @override
  String get pagesLabel => 'pages';

  @override
  String get shelvesTitle => 'Shelves';

  @override
  String get shelvesSectionByStatus => 'By status';

  @override
  String get shelvesSectionMine => 'My shelves';

  @override
  String get shelvesSectionManagement => 'Management';

  @override
  String get shelfAllBooks => 'All books';

  @override
  String get shelfReading => 'Reading';

  @override
  String get shelfRead => 'Read';

  @override
  String get shelfWantToRead => 'To read';

  @override
  String get shelfAbandoned => 'Abandoned';

  @override
  String get shelfPaused => 'Paused';

  @override
  String get shelfNewTooltip => 'New shelf';

  @override
  String get shelfEmpty => 'No custom shelves created';

  @override
  String get shelfBooksEmpty => 'No books in this shelf';

  @override
  String get shelfStatusBooksEmpty => 'No books here';

  @override
  String get shelfFormNew => 'New shelf';

  @override
  String get shelfFormEdit => 'Edit shelf';

  @override
  String get shelfFormNameLabel => 'Shelf name';

  @override
  String get shelfFormSectionStatus => 'Reading status';

  @override
  String get shelfFormSectionTitle => 'Title';

  @override
  String get shelfFormSectionAuthor => 'Author';

  @override
  String get shelfFormSectionPublisher => 'Publisher';

  @override
  String get shelfFormSectionIsbn => 'ISBN';

  @override
  String get shelfFormSectionCollection => 'Collection';

  @override
  String get shelfFormSectionCategories => 'Categories';

  @override
  String get shelfFormSectionImprint => 'Imprint';

  @override
  String get shelfFormHintTitle => 'Search in title';

  @override
  String get shelfFormHintAuthor => 'Author name';

  @override
  String get shelfFormHintPublisher => 'Publisher name';

  @override
  String get shelfFormHintIsbn => 'ISBN';

  @override
  String get shelfFormHintCollection => 'Collection name';

  @override
  String get shelfFormStatusAny => 'Any';

  @override
  String get shelfOptionEdit => 'Edit shelf';

  @override
  String get shelfOptionDelete => 'Delete';

  @override
  String get shelfStatusLabelReading => 'Reading';

  @override
  String get shelfStatusLabelRead => 'Read';

  @override
  String get shelfStatusLabelWantToRead => 'To read';

  @override
  String get shelfStatusLabelAbandoned => 'Abandoned';

  @override
  String get shelfStatusLabelPaused => 'Paused';

  @override
  String get managementCategories => 'Categories';

  @override
  String get managementImprints => 'Imprints';

  @override
  String get managementCollections => 'Collections';

  @override
  String get tagNone => 'No categories yet';

  @override
  String get tagNew => 'New category';

  @override
  String get tagNewDialogTitle => 'New category';

  @override
  String get tagNameLabel => 'Name';

  @override
  String get tagColorLabel => 'Color';

  @override
  String get tagDeleteTitle => 'Delete category';

  @override
  String tagDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get imprintNone => 'No imprints yet';

  @override
  String get imprintNew => 'New imprint';

  @override
  String get imprintNewDialogTitle => 'New imprint';

  @override
  String get imprintEditDialogTitle => 'Edit imprint';

  @override
  String get imprintNameLabel => 'Imprint name';

  @override
  String get imprintAddImageHint => 'Tap to add image';

  @override
  String get imprintChangeImageHint => 'Tap to change image';

  @override
  String get imprintUrlDialogTitle => 'Image URL';

  @override
  String get imprintUrlHint => 'https://example.com/imprint.jpg';

  @override
  String get imprintDeleteTitle => 'Delete imprint';

  @override
  String imprintDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get imprintNoImprints => 'No imprints created';

  @override
  String get collectionNone => 'Collections are created when saving a book';

  @override
  String get collectionDeleteTitle => 'Delete collection';

  @override
  String collectionDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System (automatic)';

  @override
  String get settingsThemeMode => 'Theme mode';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAccentColor => 'Accent color';

  @override
  String get settingsAccentColorHint => 'Tap a color to apply it';

  @override
  String get settingsSectionStorage => 'Storage';

  @override
  String get settingsCoversFolder => 'Covers folder';

  @override
  String get settingsDatabase => 'Database';

  @override
  String get settingsDefaultDir => 'Default directory';

  @override
  String get settingsDbMoveTitle => 'Move database';

  @override
  String get settingsDbMoveContent =>
      'Moving the database requires an app restart. Data will be copied to the new directory. Continue?';

  @override
  String get settingsDbMoveConfirm => 'Move and restart';

  @override
  String get settingsSectionSearch => 'Book search';

  @override
  String get settingsSearchServer => 'Server';

  @override
  String get settingsSearchServerHint =>
      'Used to search for books by ISBN or title';

  @override
  String get settingsApiKeyTitle => 'Google Books API key';

  @override
  String get settingsApiKeyConfigured =>
      'Key configured. Google Books is available.';

  @override
  String get settingsApiKeyMissing =>
      'No key, Google Books will use Open Library as fallback.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Show';

  @override
  String get settingsApiKeyHide => 'Hide';

  @override
  String get settingsApiKeySave => 'Save key';

  @override
  String get settingsApiKeySaved => 'Key saved';

  @override
  String get settingsApiKeyClear => 'Clear key';

  @override
  String get settingsApiKeyHowTo => 'How to get it';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'How to get a Google Books API key';

  @override
  String get settingsApiKeyStep1 =>
      'Open console.cloud.google.com and log in with your Google account.';

  @override
  String get settingsApiKeyStep2 => 'Create a new project (any name will do).';

  @override
  String get settingsApiKeyStep3 =>
      'Go to APIs & Services → Library, search for \"Books API\" and enable it.';

  @override
  String get settingsApiKeyStep4 =>
      'Go to APIs & Services → Credentials → Create Credentials → API Key.';

  @override
  String get settingsApiKeyStep5 =>
      'Optional but recommended: restrict the key to the Books API only.';

  @override
  String get settingsApiKeyStep6 =>
      'Copy the resulting key (starts with \"AIza...\") and paste it here.';

  @override
  String get settingsApiKeyNote =>
      'The key is free and allows up to 1,000 searches per day. It is not shared with anyone: it is only saved on this device.';

  @override
  String get bookSearchHint => 'Title, author, or ISBN…';

  @override
  String get bookSearchPrompt => 'Search by title, author, or ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return 'Results from: $providers.';
  }

  @override
  String get bookSearchRecommended => 'RECOMMENDED BY OPENSHELF';

  @override
  String get addedToLibrary => 'Added to library';

  @override
  String get errorDuplicateIsbn => 'Already in library';

  @override
  String get bookDuplicateTitle => 'Duplicate Book';

  @override
  String bookDuplicateContent(String isbn) {
    return 'You already have a book with ISBN $isbn in your library.';
  }

  @override
  String get bookSearchErrorNoApiKey =>
      'Google Books requires an API key.\nConfigure it in Settings → Book Search.';

  @override
  String get bookSearchErrorRateLimit =>
      'Google Books has rate limited requests.\nWait a moment and try again.';

  @override
  String get bookSearchErrorNetwork =>
      'Could not connect to any server.\nCheck your connection and try again.';

  @override
  String get coverPickerTitle => 'Covers';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults => 'No covers found for this book.';

  @override
  String get coverPickerNetworkError =>
      'Could not connect. Check your connection.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsPlaceholder => 'Your statistics will appear here';
}
