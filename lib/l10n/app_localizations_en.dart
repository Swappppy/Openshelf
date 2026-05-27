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
  String errorGeneric(String error) {
    return 'Error: $error';
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
  String get libraryTitle => 'Library';

  @override
  String get libraryEmpty => 'Your library is empty';

  @override
  String get libraryEmptyHint =>
      'Every great reader started with a first book. What will yours be?';

  @override
  String get libraryAddFirstBook => 'Add first book';

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
  String get searchHint => 'Search by title...';

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
  String get loading => 'Loading...';

  @override
  String get loadingImport => 'Importing books, please wait...';

  @override
  String get loadingExport => 'Exporting books, please wait...';

  @override
  String get exportProgressData => 'Exporting data...';

  @override
  String get exportProgressMedia => 'Bundling media...';

  @override
  String get exportProgressCompress => 'Compressing backup...';

  @override
  String get exportProgressFinalize => 'Opening share menu...';

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
  String get duplicate => 'Duplicate';

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
  String get fieldSubtitle => 'Subtitle';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Language';

  @override
  String get fieldTranslator => 'Translator';

  @override
  String get fieldTotalPages => 'Total pages';

  @override
  String get fieldTotalBooks => 'Total books';

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
  String get bookDetailNotesHint => 'Write your notes here...';

  @override
  String get bookDetailNotesEmpty => 'Tap to add notes...';

  @override
  String get bookDetailDeleteTitle => 'Delete book';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get bookDetailDuplicateTitle => 'Duplicate book';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return 'Do you want to create an exact copy of \"$title\"?';
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
  String get shelvesSectionMine => 'Shelves';

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
  String get shelfEmpty => 'You don\'t have any custom shelves';

  @override
  String get shelfEmptySubtitle =>
      'Organize your reads however you like: by genre, mood, or whatever comes to mind.';

  @override
  String get shelvesAddFirstShelf => 'Create shelf';

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
  String get collectionNameLabel => 'Collection name';

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
  String get managementCategoryCount => 'Book count';

  @override
  String get managementImprints => 'Imprints';

  @override
  String get managementCollections => 'Collections';

  @override
  String get managementCategoryCloudCurve => 'Algorithmic curve (Books)';

  @override
  String get tagNone => 'No categories yet';

  @override
  String get tagNoneSubtitle =>
      'Categories help you find the perfect book based on how you feel.';

  @override
  String get categoriesAddFirst => 'New category';

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
  String get imprintNoneSubtitle =>
      'Group your books by publisher to discover your favorites.';

  @override
  String get imprintsAddFirst => 'Add imprint';

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
  String get collectionNone => 'No collections yet';

  @override
  String get collectionNoneSubtitle =>
      'Create themed collections: sagas, reading challenges, wishlists...';

  @override
  String get collectionsAddFirst => 'New collection';

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
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguageEnglish => 'English';

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
  String get settingsSectionData => 'Data management';

  @override
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementImport => 'Import books';

  @override
  String get dataManagementExport => 'Export books';

  @override
  String dataManagementImportHint(String source) {
    return 'Import from $source CSV';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Export to $source CSV';
  }

  @override
  String get dataManagementRestoreBackup => 'Restore backup';

  @override
  String get dataManagementRestoreBackupHint =>
      'Restore from OpenShelf CSV/ZIP';

  @override
  String get dataManagementCreateBackup => 'Create backup';

  @override
  String get dataManagementCreateBackupHint => 'Full export with covers option';

  @override
  String get settingsImportBookshelf => 'Import from Bookshelf';

  @override
  String get settingsImportBookshelfHint => 'Import books from a CSV export';

  @override
  String get settingsExportCsv => 'Export library';

  @override
  String get settingsExportCsvHint => 'Export all books to a CSV file';

  @override
  String get settingsFullBackup => 'Restore library';

  @override
  String get settingsFullBackupHint => 'Restore books from a CSV backup';

  @override
  String get settingsAutoNoCoverTitle => 'No cover shelf';

  @override
  String get settingsAutoNoCoverSub =>
      'Auto-create a shelf for books without covers';

  @override
  String get noCoverShelfTitle => 'Books without cover';

  @override
  String get settingsCompressImagesTitle => 'Compress covers automatically';

  @override
  String get settingsCompressImagesSub =>
      'Reduces image size when saving or importing';

  @override
  String get settingsBatchCompressTitle => 'Optimize library now';

  @override
  String get settingsBatchCompressSub =>
      'Compresses all existing covers that are not yet optimized';

  @override
  String settingsBatchCompressSuccess(int count) {
    return 'Optimized $count covers.';
  }

  @override
  String get exportTitle => 'Export Library';

  @override
  String get exportCoversPrompt =>
      'Do you want to include cover images in the backup? (This will create a ZIP file alongside the CSV)';

  @override
  String get importRestoreCoversTitle => 'Restore Covers';

  @override
  String get importRestoreCoversPrompt =>
      'Do you also have a ZIP file with the cover images to restore?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get devDeleteAllBooks => 'DELETE ALL BOOKS (DEV)';

  @override
  String get settingsDevClearDbSub => 'Developer tool: clear database';

  @override
  String get settingsDevDbCleared => 'Database cleared';

  @override
  String get settingsImportSelectBackup => 'Select Openshelf Backup';

  @override
  String get settingsImportSelectCovers => 'Select Openshelf Covers ZIP';

  @override
  String get devDeleteConfirmTitle => 'Clear Library?';

  @override
  String get devDeleteConfirmContent =>
      'This will permanently remove ALL books and categories. This is for testing only. Continue?';

  @override
  String importSuccess(int count) {
    return 'Import complete: $count books added.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Import partial: $added added, $skipped skipped.';
  }

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
  String get bookSearchHint => 'Title, author, or ISBN...';

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
  String get bookSearchRecommendedSource => 'Recommended by Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Open Library';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get searchTabStatus => 'Status';

  @override
  String get searchTabImprint => 'Imprint';

  @override
  String get searchTabCategory => 'Category';

  @override
  String get searchTabCollection => 'Collection';

  @override
  String searchFilterStatus(String value) {
    return 'Status: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Imprint: $value';
  }

  @override
  String searchFilterCategory(String value) {
    return 'Cat.: $value';
  }

  @override
  String searchFilterCollection(String value) {
    return 'Coll.: $value';
  }

  @override
  String searchActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active filters',
      one: '1 active filter',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => 'Save as shelf';

  @override
  String get shelfShowInLibrary => 'Show in library';

  @override
  String get searchClearAll => 'Clear all';

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

  @override
  String get statsAddFirstWidget => 'Add your first widget';

  @override
  String get statsAddWidgetTitle => 'Add widget';

  @override
  String get statsGoalTargetShelf => 'Target shelf';

  @override
  String searchFilterIsbnLabel(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String searchFilterLanguageLabel(String language) {
    return 'Language: $language';
  }

  @override
  String searchFilterAuthorLabel(String author) {
    return 'Author: $author';
  }

  @override
  String searchFilterPublisherLabel(String publisher) {
    return 'Publisher: $publisher';
  }

  @override
  String get statsGoalTitle => 'GOAL';

  @override
  String get statsGoalFullTitle => 'READING GOAL';

  @override
  String get statsGoalUnitBooks => 'books';

  @override
  String get statsGoalUnitPages => 'pages';

  @override
  String statsGoalRemaining(int count) {
    return '$count remaining';
  }

  @override
  String get statsGoalCompleted => 'Done!';

  @override
  String get statsGoalNew => 'New goal';

  @override
  String get statsGoalEdit => 'Edit goal';

  @override
  String get statsGoalDelete => 'Delete';

  @override
  String get statsGoalNameLabel => 'Name (e.g., Challenge 2026)';

  @override
  String get statsGoalTypeLabel => 'Type';

  @override
  String get statsGoalTypeBooks => 'Books read';

  @override
  String get statsGoalTypePages => 'Pages read';

  @override
  String get statsGoalTargetLabel => 'Numerical target';

  @override
  String get statsGoalFromLabel => 'From';

  @override
  String get statsGoalToLabel => 'To';

  @override
  String get statsPagesTitle => 'PAGES';

  @override
  String get statsPagesSub => 'pages read';

  @override
  String get statsStreakTitle => 'STREAK';

  @override
  String get statsStreakSub => 'days in a row';

  @override
  String get statsStatusTitle => 'STATUS';

  @override
  String get statsAddedTitle => 'BOOKS ADDED';

  @override
  String get statsAddedNoData => 'No data';

  @override
  String get statsCategoriesTitle => 'CATEGORIES';

  @override
  String get statsYearsTitle => 'PUBLISH YEARS';

  @override
  String get statsReadingTitle => 'READING';

  @override
  String get statsReadingNowTitle => 'READING NOW';

  @override
  String get statsReadingNone => 'Nothing in reading';

  @override
  String get statsReadByYearTitle => 'BOOKS READ BY YEAR';

  @override
  String get statsCollectionsTitle => 'COLLECTIONS';

  @override
  String get statsLastAddedTitle => 'LAST ADDED';

  @override
  String get statsAvgPagesTitle => 'AVERAGE PAGES';

  @override
  String get statsAvgPagesSub => 'pages per book';

  @override
  String get statsOptPagesTitle => 'Total pages';

  @override
  String get statsOptPagesSub => 'Total pages read';

  @override
  String get statsOptStreakTitle => 'Streak';

  @override
  String get statsOptStreakSub => 'Consecutive days reading';

  @override
  String get statsOptGoalTitle => 'Reading goal';

  @override
  String get statsOptGoalSub => 'Books, shelves or collections';

  @override
  String get statsOptStatusTitle => 'Reading status';

  @override
  String get statsOptStatusSub => 'Books by status';

  @override
  String get statsOptCurrentTitle => 'Current book';

  @override
  String get statsOptCurrentSub => 'Current reading progress';

  @override
  String get statsOptAddedTimeTitle => 'Books added';

  @override
  String get statsOptAddedTimeSub => 'Acquisitions timeline';

  @override
  String get statsOptCategoriesTitle => 'Categories';

  @override
  String get statsOptCategoriesSub => 'Distribution by genre';

  @override
  String get statsOptYearsTitle => 'Publish year';

  @override
  String get statsOptYearsSub => 'Historical histogram';

  @override
  String get statsOptReadYearTitle => 'Read by year';

  @override
  String get statsOptReadYearSub => 'Annual reading chart';

  @override
  String get statsOptCollectionsTitle => 'Collections';

  @override
  String get statsOptCollectionsSub => 'Books per collection';

  @override
  String get statsOptLastAddedTitle => 'Last added';

  @override
  String get statsOptLastAddedSub => 'Recent arrivals';

  @override
  String get statsOptAvgPagesTitle => 'Average length';

  @override
  String get statsOptAvgPagesSub => 'Average pages per book';

  @override
  String get statsOptReadListTitle => 'Read books list';

  @override
  String get statsOptReadListSub => 'Books read in a period';

  @override
  String get statsOptAvgCompletionTitle => 'Completion time';

  @override
  String get statsOptAvgCompletionSub => 'Average time to finish a book';

  @override
  String statsAvgCompletionValue(String days) {
    return '$days days';
  }

  @override
  String get statsPeriodThisMonth => 'Read this month';

  @override
  String get statsPeriodLast3Months => 'Read last 3 months';

  @override
  String get statsPeriodThisYear => 'Read this year';

  @override
  String get statsPeriodLast3Years => 'Read last 3 years';

  @override
  String get tabMore => 'more';

  @override
  String get sortTitle => 'Sort';

  @override
  String get openSettings => 'Open settings';

  @override
  String get permissionRequired => 'Permission required';

  @override
  String get storagePermissionExplanation =>
      'To select a cover you need to grant storage access. You can do this from the application settings.';

  @override
  String get cameraPermissionExplanation =>
      'To take a photo you need to grant camera access. You can do this from the application settings.';
}
