import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ro'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Openshelf'**
  String get appTitle;

  /// Generic error prefix
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// Generic error message with parameter
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// Critical app startup error
  ///
  /// In en, this message translates to:
  /// **'Error starting application: {error}'**
  String criticalStartError(String error);

  /// Nav tab: library
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Nav tab: shelves
  ///
  /// In en, this message translates to:
  /// **'Shelves'**
  String get navShelves;

  /// Nav tab: stats
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// Library screen title
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Empty library state
  ///
  /// In en, this message translates to:
  /// **'Your library is empty'**
  String get libraryEmpty;

  /// Hint when library is empty
  ///
  /// In en, this message translates to:
  /// **'Every great reader started with a first book. What will yours be?'**
  String get libraryEmptyHint;

  /// Text for the action button in the empty library state
  ///
  /// In en, this message translates to:
  /// **'Add first book'**
  String get libraryAddFirstBook;

  /// No search results
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get libraryNoResults;

  /// Hint when no search results
  ///
  /// In en, this message translates to:
  /// **'Try different filters'**
  String get libraryNoResultsHint;

  /// Add book FAB label
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBook;

  /// Display settings title
  ///
  /// In en, this message translates to:
  /// **'Show in library'**
  String get displaySettings;

  /// Reorder hint
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get displaySettingsDragHint;

  /// Settings button label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsButton;

  /// Author field name
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get fieldAuthor;

  /// Publisher field name
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get fieldPublisher;

  /// Year field name
  ///
  /// In en, this message translates to:
  /// **'Published year'**
  String get fieldYear;

  /// Rating field name
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get fieldRating;

  /// Tags field name
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get fieldTags;

  /// Reading progress field
  ///
  /// In en, this message translates to:
  /// **'Reading progress'**
  String get fieldReadingProgress;

  /// Status chip field
  ///
  /// In en, this message translates to:
  /// **'Status chip'**
  String get fieldStatusChip;

  /// Library search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by title...'**
  String get searchHint;

  /// Author filter placeholder
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get filterAuthor;

  /// ISBN filter placeholder
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get filterIsbn;

  /// Publisher filter placeholder
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get filterPublisher;

  /// Collection filter placeholder
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get filterCollection;

  /// Imprint filter label
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get filterImprintLabel;

  /// No description provided for @imprintBookCount.
  ///
  /// In en, this message translates to:
  /// **'{count} books'**
  String imprintBookCount(int count);

  /// Categories filter label
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get filterTagsLabel;

  /// Generic close button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Generic loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Loading message during import
  ///
  /// In en, this message translates to:
  /// **'Importing books, please wait...'**
  String get loadingImport;

  /// Loading message during export
  ///
  /// In en, this message translates to:
  /// **'Exporting books, please wait...'**
  String get loadingExport;

  /// No description provided for @exportProgressData.
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportProgressData;

  /// No description provided for @exportProgressMedia.
  ///
  /// In en, this message translates to:
  /// **'Bundling media...'**
  String get exportProgressMedia;

  /// No description provided for @exportProgressCompress.
  ///
  /// In en, this message translates to:
  /// **'Compressing backup...'**
  String get exportProgressCompress;

  /// No description provided for @exportProgressFinalize.
  ///
  /// In en, this message translates to:
  /// **'Opening share menu...'**
  String get exportProgressFinalize;

  /// No description provided for @exportSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to {path}'**
  String exportSaveSuccess(String path);

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Generic create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Generic edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Generic duplicate action
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// Take photo button
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// Enter URL button
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// Download button
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Save to device action
  ///
  /// In en, this message translates to:
  /// **'Save to device'**
  String get saveToDevice;

  /// Add book modal title
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBookModalTitle;

  /// Add book modal subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add your book'**
  String get addBookModalSubtitle;

  /// Add book manually option
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// Add manually option subtitle
  ///
  /// In en, this message translates to:
  /// **'Fill in the data yourself'**
  String get addManuallySubtitle;

  /// Search book online option
  ///
  /// In en, this message translates to:
  /// **'Search book'**
  String get searchBook;

  /// Search book option subtitle
  ///
  /// In en, this message translates to:
  /// **'By title, author, or ISBN'**
  String get searchBookSubtitle;

  /// Scan barcode option
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// Scan barcode option subtitle
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the ISBN'**
  String get scanBarcodeSubtitle;

  /// Option to scan ISBN as text
  ///
  /// In en, this message translates to:
  /// **'Scan ISBN Number'**
  String get scanIsbnText;

  /// Subtitle for scanning ISBN as text
  ///
  /// In en, this message translates to:
  /// **'Point at the printed number'**
  String get scanIsbnTextSubtitle;

  /// Instruction to tap a detected ISBN
  ///
  /// In en, this message translates to:
  /// **'Tap an ISBN to select it'**
  String get scanIsbnSelect;

  /// Instruction to hold the camera steady for OCR
  ///
  /// In en, this message translates to:
  /// **'Hold the image for a couple of seconds...'**
  String get scanOcrHoldMessage;

  /// Camera permission missing message
  ///
  /// In en, this message translates to:
  /// **'Camera permission required to scan barcodes'**
  String get scanBarcodePermission;

  /// Batch scan option
  ///
  /// In en, this message translates to:
  /// **'Batch scan'**
  String get scanBatch;

  /// Batch scan option subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan multiple books in a row'**
  String get scanBatchSubtitle;

  /// Label for scanner mode: barcode
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get scanModeBarcode;

  /// Label for scanner mode: ISBN number / text
  ///
  /// In en, this message translates to:
  /// **'ISBN Number'**
  String get scanModeIsbn;

  /// New book form title
  ///
  /// In en, this message translates to:
  /// **'New book'**
  String get bookFormNewTitle;

  /// Edit book form title
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get bookFormEditTitle;

  /// Main tab label
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get tabMain;

  /// Details tab label
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get tabDetails;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// Subtitle field label
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get fieldSubtitle;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get fieldDescription;

  /// ISBN field label
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get fieldIsbn;

  /// Language field label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get fieldLanguage;

  /// Translator field label
  ///
  /// In en, this message translates to:
  /// **'Translator'**
  String get fieldTranslator;

  /// Name of the reads field
  ///
  /// In en, this message translates to:
  /// **'Reads'**
  String get fieldReads;

  /// Name of the copies field
  ///
  /// In en, this message translates to:
  /// **'Copies'**
  String get fieldCopies;

  /// Total pages field
  ///
  /// In en, this message translates to:
  /// **'Total pages'**
  String get fieldTotalPages;

  /// Total books field
  ///
  /// In en, this message translates to:
  /// **'Total books'**
  String get fieldTotalBooks;

  /// Current page field
  ///
  /// In en, this message translates to:
  /// **'Current page'**
  String get fieldCurrentPage;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// Collection field label
  ///
  /// In en, this message translates to:
  /// **'Collection / Series'**
  String get fieldCollection;

  /// Number in collection field
  ///
  /// In en, this message translates to:
  /// **'Number in collection'**
  String get fieldCollectionNumber;

  /// Basic info header
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get sectionBasicInfo;

  /// Categories header
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get sectionCategories;

  /// Reading status header
  ///
  /// In en, this message translates to:
  /// **'Reading status'**
  String get sectionReadingStatus;

  /// Format header
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get sectionFormat;

  /// Rating header
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sectionRating;

  /// Imprint header
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get sectionImprint;

  /// Photo pick button
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get coverPickPhoto;

  /// URL pick button
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get coverPickUrl;

  /// Cover search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get coverSearch;

  /// Cover URL dialog title
  ///
  /// In en, this message translates to:
  /// **'Cover URL'**
  String get coverUrlDialogTitle;

  /// Cover URL placeholder
  ///
  /// In en, this message translates to:
  /// **'https://example.com/cover.jpg'**
  String get coverUrlHint;

  /// Download error message
  ///
  /// In en, this message translates to:
  /// **'Could not download image'**
  String get coverDownloadError;

  /// Error when image processing fails
  ///
  /// In en, this message translates to:
  /// **'Could not process image'**
  String get imageProcessError;

  /// Title for cover cropping screen
  ///
  /// In en, this message translates to:
  /// **'Crop cover'**
  String get cropCoverTitle;

  /// Title for imprint cropping screen
  ///
  /// In en, this message translates to:
  /// **'Crop imprint'**
  String get cropImprintTitle;

  /// Tag search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search or create category'**
  String get tagSearchOrCreate;

  /// Tag create hint
  ///
  /// In en, this message translates to:
  /// **'Type and press Enter to add or create'**
  String get tagCreateHint;

  /// No categories message
  ///
  /// In en, this message translates to:
  /// **'No categories created yet'**
  String get tagNoCategories;

  /// Imprint search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search imprint'**
  String get imprintSearch;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// Status: want to read
  ///
  /// In en, this message translates to:
  /// **'Want to read'**
  String get statusWantToRead;

  /// Status: reading
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get statusReading;

  /// Status: read
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get statusRead;

  /// Status: abandoned
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get statusAbandoned;

  /// Status: paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// Format: paperback
  ///
  /// In en, this message translates to:
  /// **'Paperback'**
  String get formatPaperback;

  /// Format: hardcover
  ///
  /// In en, this message translates to:
  /// **'Hardcover'**
  String get formatHardcover;

  /// Format: leatherbound
  ///
  /// In en, this message translates to:
  /// **'Leatherbound'**
  String get formatLeatherbound;

  /// Format: rustic
  ///
  /// In en, this message translates to:
  /// **'Rustic'**
  String get formatRustic;

  /// Format: digital
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get formatDigital;

  /// Format: other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get formatOther;

  /// Book not found message
  ///
  /// In en, this message translates to:
  /// **'Book not found'**
  String get bookDetailNotFound;

  /// Page picker title
  ///
  /// In en, this message translates to:
  /// **'Current page'**
  String get bookDetailPagePickerTitle;

  /// Personal notes section title
  ///
  /// In en, this message translates to:
  /// **'Personal notes'**
  String get bookDetailNotesTitle;

  /// Notes field placeholder
  ///
  /// In en, this message translates to:
  /// **'Write your notes here...'**
  String get bookDetailNotesHint;

  /// Notes empty message
  ///
  /// In en, this message translates to:
  /// **'Tap to add notes...'**
  String get bookDetailNotesEmpty;

  /// Delete book dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete book'**
  String get bookDetailDeleteTitle;

  /// Delete book confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This action cannot be undone.'**
  String bookDetailDeleteConfirm(String title);

  /// Duplicate book dialog title
  ///
  /// In en, this message translates to:
  /// **'Duplicate book'**
  String get bookDetailDuplicateTitle;

  /// Duplicate book confirmation
  ///
  /// In en, this message translates to:
  /// **'Do you want to create an exact copy of \"{title}\"?'**
  String bookDetailDuplicateConfirm(String title);

  /// No description provided for @bookDetailNewReadingWholeBook.
  ///
  /// In en, this message translates to:
  /// **'Whole book'**
  String get bookDetailNewReadingWholeBook;

  /// No description provided for @bookDetailNewReadingWholeBookDescription.
  ///
  /// In en, this message translates to:
  /// **'A complete re-read will be recorded starting today.'**
  String get bookDetailNewReadingWholeBookDescription;

  /// No description provided for @bookDetailNewReadingSections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get bookDetailNewReadingSections;

  /// No description provided for @bookDetailNewReadingSectionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 section} other{{count} sections}}'**
  String bookDetailNewReadingSectionsCount(int count);

  /// No description provided for @bookDetailNewReadingReadCount.
  ///
  /// In en, this message translates to:
  /// **'Read {count}x'**
  String bookDetailNewReadingReadCount(Object count);

  /// No description provided for @bookDetailNewReadingSelectSections.
  ///
  /// In en, this message translates to:
  /// **'Select sections to re-read'**
  String get bookDetailNewReadingSelectSections;

  /// No description provided for @bookDetailStartNewReadingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to start a new reading session?'**
  String get bookDetailStartNewReadingPrompt;

  /// No description provided for @bookDetailStartNewReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'New reading'**
  String get bookDetailStartNewReadingTitle;

  /// No description provided for @bookDetailStartNewReadingButton.
  ///
  /// In en, this message translates to:
  /// **'Start new reading'**
  String get bookDetailStartNewReadingButton;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @bookDetailDeleteReadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Delete the latest ongoing reading? Session dates will be lost.'**
  String get bookDetailDeleteReadPrompt;

  /// No description provided for @bookDetailReadHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'READING HISTORY'**
  String get bookDetailReadHistoryTitle;

  /// No description provided for @bookDetailReadOngoing.
  ///
  /// In en, this message translates to:
  /// **'ongoing'**
  String get bookDetailReadOngoing;

  /// No description provided for @bookDetailReadNumber.
  ///
  /// In en, this message translates to:
  /// **'Reading {number}'**
  String bookDetailReadNumber(int number);

  /// No description provided for @bookDetailReadEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reading {number}'**
  String bookDetailReadEditDialogTitle(Object number);

  /// No description provided for @bookDetailReadDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this history entry?'**
  String get bookDetailReadDeleteConfirm;

  /// No description provided for @bookDetailReadNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Reading number'**
  String get bookDetailReadNumberLabel;

  /// Pages field label
  ///
  /// In en, this message translates to:
  /// **'PAGES'**
  String get bookDetailFieldPages;

  /// Categories field label
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get bookDetailFieldCategories;

  /// Format field label
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get bookDetailFieldFormat;

  /// Rating field label
  ///
  /// In en, this message translates to:
  /// **'RATING'**
  String get bookDetailFieldRating;

  /// Imprint section label
  ///
  /// In en, this message translates to:
  /// **'IMPRINT'**
  String get bookDetailFieldImprintSection;

  /// Notes section label
  ///
  /// In en, this message translates to:
  /// **'PERSONAL NOTES'**
  String get bookDetailFieldPersonalNotes;

  /// Date added label
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get bookDetailFieldAdded;

  /// Date started label
  ///
  /// In en, this message translates to:
  /// **'Started reading'**
  String get bookDetailFieldStarted;

  /// Date finished label
  ///
  /// In en, this message translates to:
  /// **'Finished reading'**
  String get bookDetailFieldFinished;

  /// Reading progress pages
  ///
  /// In en, this message translates to:
  /// **'{current} / {total} pages · {percent}%'**
  String pageProgress(String current, String total, String percent);

  /// Short reading progress
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String pageProgressShort(String current, String total);

  /// Page count with suffix
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String pageSuffix(int count);

  /// Generic pages label
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get pagesLabel;

  /// Shelves screen title
  ///
  /// In en, this message translates to:
  /// **'Shelves'**
  String get shelvesTitle;

  /// Status section header
  ///
  /// In en, this message translates to:
  /// **'By status'**
  String get shelvesSectionByStatus;

  /// Custom shelves section header
  ///
  /// In en, this message translates to:
  /// **'Shelves'**
  String get shelvesSectionMine;

  /// Management section header
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get shelvesSectionManagement;

  /// All books shelf
  ///
  /// In en, this message translates to:
  /// **'All books'**
  String get shelfAllBooks;

  /// Reading shelf
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get shelfReading;

  /// Read shelf
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get shelfRead;

  /// To read shelf
  ///
  /// In en, this message translates to:
  /// **'To read'**
  String get shelfWantToRead;

  /// Abandoned shelf
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get shelfAbandoned;

  /// Paused shelf
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get shelfPaused;

  /// New shelf tooltip
  ///
  /// In en, this message translates to:
  /// **'New shelf'**
  String get shelfNewTooltip;

  /// Empty custom shelves state
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any custom shelves'**
  String get shelfEmpty;

  /// Empty shelves state subtitle
  ///
  /// In en, this message translates to:
  /// **'Organize your reads however you like: by genre, mood, or whatever comes to mind.'**
  String get shelfEmptySubtitle;

  /// Action button text for empty shelves state
  ///
  /// In en, this message translates to:
  /// **'Create shelf'**
  String get shelvesAddFirstShelf;

  /// Empty shelf books state
  ///
  /// In en, this message translates to:
  /// **'No books in this shelf'**
  String get shelfBooksEmpty;

  /// Empty status books state
  ///
  /// In en, this message translates to:
  /// **'No books here'**
  String get shelfStatusBooksEmpty;

  /// New shelf form title
  ///
  /// In en, this message translates to:
  /// **'New shelf'**
  String get shelfFormNew;

  /// Edit shelf form title
  ///
  /// In en, this message translates to:
  /// **'Edit shelf'**
  String get shelfFormEdit;

  /// Shelf name field label
  ///
  /// In en, this message translates to:
  /// **'Shelf name'**
  String get shelfFormNameLabel;

  /// Collection name field label
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get collectionNameLabel;

  /// Shelf form status section
  ///
  /// In en, this message translates to:
  /// **'Reading status'**
  String get shelfFormSectionStatus;

  /// Shelf form title section
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get shelfFormSectionTitle;

  /// Shelf form author section
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get shelfFormSectionAuthor;

  /// Shelf form publisher section
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get shelfFormSectionPublisher;

  /// Shelf form ISBN section
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get shelfFormSectionIsbn;

  /// Shelf form collection section
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get shelfFormSectionCollection;

  /// Shelf form categories section
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get shelfFormSectionCategories;

  /// Shelf form imprint section
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get shelfFormSectionImprint;

  /// Shelf form title hint
  ///
  /// In en, this message translates to:
  /// **'Search in title'**
  String get shelfFormHintTitle;

  /// Shelf form author hint
  ///
  /// In en, this message translates to:
  /// **'Author name'**
  String get shelfFormHintAuthor;

  /// Shelf form publisher hint
  ///
  /// In en, this message translates to:
  /// **'Publisher name'**
  String get shelfFormHintPublisher;

  /// Shelf form ISBN hint
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get shelfFormHintIsbn;

  /// Shelf form collection hint
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get shelfFormHintCollection;

  /// Shelf form any status
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get shelfFormStatusAny;

  /// Edit shelf option
  ///
  /// In en, this message translates to:
  /// **'Edit shelf'**
  String get shelfOptionEdit;

  /// Delete shelf option
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get shelfOptionDelete;

  /// Reading status label
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get shelfStatusLabelReading;

  /// Read status label
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get shelfStatusLabelRead;

  /// To read status label
  ///
  /// In en, this message translates to:
  /// **'To read'**
  String get shelfStatusLabelWantToRead;

  /// Abandoned status label
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get shelfStatusLabelAbandoned;

  /// Paused status label
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get shelfStatusLabelPaused;

  /// Management: categories
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get managementCategories;

  /// Number of books in a category
  ///
  /// In en, this message translates to:
  /// **'Book count'**
  String get managementCategoryCount;

  /// Management: imprints
  ///
  /// In en, this message translates to:
  /// **'Imprints'**
  String get managementImprints;

  /// Management: collections
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get managementCollections;

  /// No description provided for @managementCategoryCloudCurve.
  ///
  /// In en, this message translates to:
  /// **'Algorithmic curve (Books)'**
  String get managementCategoryCloudCurve;

  /// Empty categories state
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get tagNone;

  /// Empty categories state subtitle
  ///
  /// In en, this message translates to:
  /// **'Categories help you find the perfect book based on how you feel.'**
  String get tagNoneSubtitle;

  /// Action button text for empty categories state
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoriesAddFirst;

  /// New category button
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get tagNew;

  /// New category title
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get tagNewDialogTitle;

  /// Category name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tagNameLabel;

  /// Category color field label
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get tagColorLabel;

  /// Delete category title
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get tagDeleteTitle;

  /// Delete category confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String tagDeleteConfirm(String name);

  /// Empty imprints state
  ///
  /// In en, this message translates to:
  /// **'No imprints yet'**
  String get imprintNone;

  /// Empty imprints state subtitle
  ///
  /// In en, this message translates to:
  /// **'Group your books by publisher to discover your favorites.'**
  String get imprintNoneSubtitle;

  /// Action button text for empty imprints state
  ///
  /// In en, this message translates to:
  /// **'Add imprint'**
  String get imprintsAddFirst;

  /// New imprint button
  ///
  /// In en, this message translates to:
  /// **'New imprint'**
  String get imprintNew;

  /// New imprint title
  ///
  /// In en, this message translates to:
  /// **'New imprint'**
  String get imprintNewDialogTitle;

  /// Edit imprint title
  ///
  /// In en, this message translates to:
  /// **'Edit imprint'**
  String get imprintEditDialogTitle;

  /// Imprint name field label
  ///
  /// In en, this message translates to:
  /// **'Imprint name'**
  String get imprintNameLabel;

  /// Add imprint image hint
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get imprintAddImageHint;

  /// Change imprint image hint
  ///
  /// In en, this message translates to:
  /// **'Tap to change image'**
  String get imprintChangeImageHint;

  /// Imprint URL title
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imprintUrlDialogTitle;

  /// Imprint URL placeholder
  ///
  /// In en, this message translates to:
  /// **'https://example.com/imprint.jpg'**
  String get imprintUrlHint;

  /// Delete imprint title
  ///
  /// In en, this message translates to:
  /// **'Delete imprint'**
  String get imprintDeleteTitle;

  /// Delete imprint confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String imprintDeleteConfirm(String name);

  /// Shelf form no imprints message
  ///
  /// In en, this message translates to:
  /// **'No imprints created'**
  String get imprintNoImprints;

  /// Empty collections state
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get collectionNone;

  /// Empty collections state subtitle
  ///
  /// In en, this message translates to:
  /// **'Create themed collections: sagas, reading challenges, wishlists...'**
  String get collectionNoneSubtitle;

  /// Action button text for empty collections state
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get collectionsAddFirst;

  /// Delete collection title
  ///
  /// In en, this message translates to:
  /// **'Delete collection'**
  String get collectionDeleteTitle;

  /// Delete collection confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String collectionDeleteConfirm(String name);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Openshelf'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Your personal library, reimagined'**
  String get onboardingWelcomeSub;

  /// No description provided for @onboardingOrganizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your world'**
  String get onboardingOrganizeTitle;

  /// No description provided for @onboardingOrganizeSub.
  ///
  /// In en, this message translates to:
  /// **'Create smart shelves and themed collections'**
  String get onboardingOrganizeSub;

  /// No description provided for @onboardingProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get onboardingProgressTitle;

  /// No description provided for @onboardingProgressSub.
  ///
  /// In en, this message translates to:
  /// **'Reading goals and detailed statistics'**
  String get onboardingProgressSub;

  /// No description provided for @onboardingAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add instantly'**
  String get onboardingAddTitle;

  /// No description provided for @onboardingAddSub.
  ///
  /// In en, this message translates to:
  /// **'Scan barcodes or search in the cloud'**
  String get onboardingAddSub;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get onboardingStart;

  /// No description provided for @settingsApplyIcon.
  ///
  /// In en, this message translates to:
  /// **'Apply icon change'**
  String get settingsApplyIcon;

  /// No description provided for @settingsDynamicIcon.
  ///
  /// In en, this message translates to:
  /// **'Dynamic app icon'**
  String get settingsDynamicIcon;

  /// No description provided for @settingsDynamicIconSub.
  ///
  /// In en, this message translates to:
  /// **'Changes the home screen icon to match the chosen color (App will restart)'**
  String get settingsDynamicIconSub;

  /// No description provided for @settingsLibraryColumns.
  ///
  /// In en, this message translates to:
  /// **'Library columns'**
  String get settingsLibraryColumns;

  /// No description provided for @settingsLibraryColumnsSub.
  ///
  /// In en, this message translates to:
  /// **'Adjust the number of books per row in grid view'**
  String get settingsLibraryColumnsSub;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Appearance section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// Language selector label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option: system
  ///
  /// In en, this message translates to:
  /// **'System (automatic)'**
  String get settingsLanguageSystem;

  /// Language option: spanish
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// Language option: english
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Theme mode label
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeMode;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Accent color label
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get settingsAccentColor;

  /// Accent color hint
  ///
  /// In en, this message translates to:
  /// **'Tap a color to apply it'**
  String get settingsAccentColorHint;

  /// Storage section header
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsSectionStorage;

  /// Covers folder label
  ///
  /// In en, this message translates to:
  /// **'Covers folder'**
  String get settingsCoversFolder;

  /// Database label
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get settingsDatabase;

  /// Default directory label
  ///
  /// In en, this message translates to:
  /// **'Default directory'**
  String get settingsDefaultDir;

  /// Move database dialog title
  ///
  /// In en, this message translates to:
  /// **'Move database'**
  String get settingsDbMoveTitle;

  /// Move database dialog content
  ///
  /// In en, this message translates to:
  /// **'Moving the database requires an app restart. Data will be copied to the new directory. Continue?'**
  String get settingsDbMoveContent;

  /// Move database confirmation
  ///
  /// In en, this message translates to:
  /// **'Move and restart'**
  String get settingsDbMoveConfirm;

  /// Search section header
  ///
  /// In en, this message translates to:
  /// **'Book search'**
  String get settingsSectionSearch;

  /// Search server label
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get settingsSearchServer;

  /// Search server hint
  ///
  /// In en, this message translates to:
  /// **'Used to search for books by ISBN or title'**
  String get settingsSearchServerHint;

  /// Data management section header
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get settingsSectionData;

  /// No description provided for @dataManagementOpenShelf.
  ///
  /// In en, this message translates to:
  /// **'OpenShelf'**
  String get dataManagementOpenShelf;

  /// No description provided for @dataManagementBookshelf.
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get dataManagementBookshelf;

  /// No description provided for @dataManagementGoodreads.
  ///
  /// In en, this message translates to:
  /// **'Goodreads'**
  String get dataManagementGoodreads;

  /// No description provided for @dataManagementLibraryThing.
  ///
  /// In en, this message translates to:
  /// **'LibraryThing'**
  String get dataManagementLibraryThing;

  /// No description provided for @dataManagementImport.
  ///
  /// In en, this message translates to:
  /// **'Import books'**
  String get dataManagementImport;

  /// No description provided for @dataManagementExport.
  ///
  /// In en, this message translates to:
  /// **'Export books'**
  String get dataManagementExport;

  /// No description provided for @dataManagementImportHint.
  ///
  /// In en, this message translates to:
  /// **'Import from {source} CSV'**
  String dataManagementImportHint(String source);

  /// No description provided for @dataManagementImportHintJson.
  ///
  /// In en, this message translates to:
  /// **'Import from {source} JSON'**
  String dataManagementImportHintJson(Object source);

  /// No description provided for @dataManagementExportHint.
  ///
  /// In en, this message translates to:
  /// **'Export to {source} CSV'**
  String dataManagementExportHint(String source);

  /// No description provided for @dataManagementExportHintJson.
  ///
  /// In en, this message translates to:
  /// **'Export to {source} JSON'**
  String dataManagementExportHintJson(Object source);

  /// No description provided for @dataManagementRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get dataManagementRestoreBackup;

  /// No description provided for @dataManagementRestoreBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Restore from OpenShelf CSV/ZIP'**
  String get dataManagementRestoreBackupHint;

  /// No description provided for @dataManagementCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get dataManagementCreateBackup;

  /// No description provided for @dataManagementCreateBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Full export with covers option'**
  String get dataManagementCreateBackupHint;

  /// Import from Bookshelf option
  ///
  /// In en, this message translates to:
  /// **'Import from Bookshelf'**
  String get settingsImportBookshelf;

  /// Import hint
  ///
  /// In en, this message translates to:
  /// **'Import books from a CSV export'**
  String get settingsImportBookshelfHint;

  /// Export title
  ///
  /// In en, this message translates to:
  /// **'Export library'**
  String get settingsExportCsv;

  /// Export hint
  ///
  /// In en, this message translates to:
  /// **'Export all books to a CSV file'**
  String get settingsExportCsvHint;

  /// Restore title
  ///
  /// In en, this message translates to:
  /// **'Restore library'**
  String get settingsFullBackup;

  /// Restore hint
  ///
  /// In en, this message translates to:
  /// **'Restore books from a CSV backup'**
  String get settingsFullBackupHint;

  /// No description provided for @settingsAutoNoCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'No cover shelf'**
  String get settingsAutoNoCoverTitle;

  /// No description provided for @settingsAutoNoCoverSub.
  ///
  /// In en, this message translates to:
  /// **'Auto-create a shelf for books without covers'**
  String get settingsAutoNoCoverSub;

  /// No description provided for @noCoverShelfTitle.
  ///
  /// In en, this message translates to:
  /// **'Books without cover'**
  String get noCoverShelfTitle;

  /// No description provided for @settingsCompressImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Compress covers automatically'**
  String get settingsCompressImagesTitle;

  /// No description provided for @settingsCompressImagesSub.
  ///
  /// In en, this message translates to:
  /// **'Reduces image size when saving or importing'**
  String get settingsCompressImagesSub;

  /// No description provided for @settingsBatchCompressTitle.
  ///
  /// In en, this message translates to:
  /// **'Optimize library now'**
  String get settingsBatchCompressTitle;

  /// No description provided for @settingsBatchCompressSub.
  ///
  /// In en, this message translates to:
  /// **'Compresses all existing covers that are not yet optimized'**
  String get settingsBatchCompressSub;

  /// No description provided for @settingsBatchCompressSuccess.
  ///
  /// In en, this message translates to:
  /// **'Optimized {count} covers.'**
  String settingsBatchCompressSuccess(int count);

  /// Export dialog title
  ///
  /// In en, this message translates to:
  /// **'Export Library'**
  String get exportTitle;

  /// Export covers prompt
  ///
  /// In en, this message translates to:
  /// **'Do you want to include cover images in the backup? (This will create a ZIP file alongside the CSV)'**
  String get exportCoversPrompt;

  /// Import covers title
  ///
  /// In en, this message translates to:
  /// **'Restore Covers'**
  String get importRestoreCoversTitle;

  /// Import covers prompt
  ///
  /// In en, this message translates to:
  /// **'Do you also have a ZIP file with the cover images to restore?'**
  String get importRestoreCoversPrompt;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Developer option to clear database
  ///
  /// In en, this message translates to:
  /// **'DELETE ALL BOOKS (DEV)'**
  String get devDeleteAllBooks;

  /// No description provided for @settingsDevClearDbSub.
  ///
  /// In en, this message translates to:
  /// **'Developer tool: clear database'**
  String get settingsDevClearDbSub;

  /// No description provided for @settingsDevDbCleared.
  ///
  /// In en, this message translates to:
  /// **'Database cleared'**
  String get settingsDevDbCleared;

  /// No description provided for @settingsImportSelectBackup.
  ///
  /// In en, this message translates to:
  /// **'Select Openshelf Backup'**
  String get settingsImportSelectBackup;

  /// No description provided for @settingsImportSelectCovers.
  ///
  /// In en, this message translates to:
  /// **'Select Openshelf Covers ZIP'**
  String get settingsImportSelectCovers;

  /// Dev delete confirmation title
  ///
  /// In en, this message translates to:
  /// **'Clear Library?'**
  String get devDeleteConfirmTitle;

  /// Dev delete confirmation content
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove ALL books and categories. This is for testing only. Continue?'**
  String get devDeleteConfirmContent;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import complete: {count} books added.'**
  String importSuccess(int count);

  /// No description provided for @importPartial.
  ///
  /// In en, this message translates to:
  /// **'Import partial: {added} added, {skipped} skipped.'**
  String importPartial(int added, int skipped);

  /// API key card title
  ///
  /// In en, this message translates to:
  /// **'Google Books API key'**
  String get settingsApiKeyTitle;

  /// Key configured message
  ///
  /// In en, this message translates to:
  /// **'Key configured. Google Books is available.'**
  String get settingsApiKeyConfigured;

  /// Key missing message
  ///
  /// In en, this message translates to:
  /// **'No key, Google Books will use Open Library as fallback.'**
  String get settingsApiKeyMissing;

  /// API key placeholder
  ///
  /// In en, this message translates to:
  /// **'AIza...'**
  String get settingsApiKeyHint;

  /// Show key tooltip
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get settingsApiKeyShow;

  /// Hide key tooltip
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get settingsApiKeyHide;

  /// Save key button
  ///
  /// In en, this message translates to:
  /// **'Save key'**
  String get settingsApiKeySave;

  /// Key saved confirmation
  ///
  /// In en, this message translates to:
  /// **'Key saved'**
  String get settingsApiKeySaved;

  /// Clear key tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear key'**
  String get settingsApiKeyClear;

  /// How to get key button
  ///
  /// In en, this message translates to:
  /// **'How to get it'**
  String get settingsApiKeyHowTo;

  /// Instructions title
  ///
  /// In en, this message translates to:
  /// **'How to get a Google Books API key'**
  String get settingsApiKeyInstructionsTitle;

  /// Step 1
  ///
  /// In en, this message translates to:
  /// **'Open console.cloud.google.com and log in with your Google account.'**
  String get settingsApiKeyStep1;

  /// Step 2
  ///
  /// In en, this message translates to:
  /// **'Create a new project (any name will do).'**
  String get settingsApiKeyStep2;

  /// Step 3
  ///
  /// In en, this message translates to:
  /// **'Go to APIs & Services → Library, search for \"Books API\" and enable it.'**
  String get settingsApiKeyStep3;

  /// Step 4
  ///
  /// In en, this message translates to:
  /// **'Go to APIs & Services → Credentials → Create Credentials → API Key.'**
  String get settingsApiKeyStep4;

  /// Step 5
  ///
  /// In en, this message translates to:
  /// **'Optional but recommended: restrict the key to the Books API only.'**
  String get settingsApiKeyStep5;

  /// Step 6
  ///
  /// In en, this message translates to:
  /// **'Copy the resulting key (starts with \"AIza...\") and paste it here.'**
  String get settingsApiKeyStep6;

  /// API key information note
  ///
  /// In en, this message translates to:
  /// **'The key is free and allows up to 1,000 searches per day. It is not shared with anyone: it is only saved on this device.'**
  String get settingsApiKeyNote;

  /// Book search field hint
  ///
  /// In en, this message translates to:
  /// **'Title, author, or ISBN...'**
  String get bookSearchHint;

  /// Initial search prompt
  ///
  /// In en, this message translates to:
  /// **'Search by title, author, or ISBN'**
  String get bookSearchPrompt;

  /// Search no results message
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String bookSearchNoResults(String query);

  /// Notice of providers that contributed to the search
  ///
  /// In en, this message translates to:
  /// **'Results from: {providers}.'**
  String bookSearchProvidersNotice(String providers);

  /// Label for recommended result
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED BY OPENSHELF'**
  String get bookSearchRecommended;

  /// No description provided for @bookSearchRecommendedSource.
  ///
  /// In en, this message translates to:
  /// **'Recommended by Openshelf'**
  String get bookSearchRecommendedSource;

  /// No description provided for @bookSearchServerOpenLibrary.
  ///
  /// In en, this message translates to:
  /// **'Open Library'**
  String get bookSearchServerOpenLibrary;

  /// No description provided for @bookSearchServerGoogleBooks.
  ///
  /// In en, this message translates to:
  /// **'Google Books'**
  String get bookSearchServerGoogleBooks;

  /// No description provided for @bookSearchServerInventaire.
  ///
  /// In en, this message translates to:
  /// **'Inventaire.io'**
  String get bookSearchServerInventaire;

  /// Search panel: Status tab
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get searchTabStatus;

  /// Search panel: Imprint tab
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get searchTabImprint;

  /// Search panel: Category tab
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get searchTabCategory;

  /// Search panel: Collection tab
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get searchTabCollection;

  /// No description provided for @searchFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String searchFilterStatus(String value);

  /// No description provided for @searchFilterImprint.
  ///
  /// In en, this message translates to:
  /// **'Imprint: {value}'**
  String searchFilterImprint(String value);

  /// No description provided for @searchFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Cat.: {value}'**
  String searchFilterCategory(String value);

  /// No description provided for @searchFilterCollection.
  ///
  /// In en, this message translates to:
  /// **'Coll.: {value}'**
  String searchFilterCollection(String value);

  /// No description provided for @searchActiveFilters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active filter} other{{count} active filters}}'**
  String searchActiveFilters(int count);

  /// No description provided for @searchSaveAsShelf.
  ///
  /// In en, this message translates to:
  /// **'Save as shelf'**
  String get searchSaveAsShelf;

  /// No description provided for @shelfShowInLibrary.
  ///
  /// In en, this message translates to:
  /// **'Show in library'**
  String get shelfShowInLibrary;

  /// Button to clear all search filters
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get searchClearAll;

  /// Success message when book is added
  ///
  /// In en, this message translates to:
  /// **'Added to library'**
  String get addedToLibrary;

  /// Error when book ISBN already exists
  ///
  /// In en, this message translates to:
  /// **'Already in library'**
  String get errorDuplicateIsbn;

  /// Duplicate book warning title
  ///
  /// In en, this message translates to:
  /// **'Duplicate Book'**
  String get bookDuplicateTitle;

  /// Duplicate book warning content
  ///
  /// In en, this message translates to:
  /// **'You already have a book with ISBN {isbn} in your library.'**
  String bookDuplicateContent(String isbn);

  /// Error: no API key
  ///
  /// In en, this message translates to:
  /// **'Google Books requires an API key.\nConfigure it in Settings → Book Search.'**
  String get bookSearchErrorNoApiKey;

  /// Error: rate limit
  ///
  /// In en, this message translates to:
  /// **'Google Books has rate limited requests.\nWait a moment and try again.'**
  String get bookSearchErrorRateLimit;

  /// Search network error
  ///
  /// In en, this message translates to:
  /// **'Could not connect to any server.\nCheck your connection and try again.'**
  String get bookSearchErrorNetwork;

  /// Cover picker sheet title
  ///
  /// In en, this message translates to:
  /// **'Covers'**
  String get coverPickerTitle;

  /// Sheet subtitle with ISBN
  ///
  /// In en, this message translates to:
  /// **'ISBN {isbn}'**
  String coverPickerIsbnLabel(String isbn);

  /// No covers found message
  ///
  /// In en, this message translates to:
  /// **'No covers found for this book.'**
  String get coverPickerNoResults;

  /// Cover search network error
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Check your connection.'**
  String get coverPickerNetworkError;

  /// Cover load progress
  ///
  /// In en, this message translates to:
  /// **'{loaded} / {total}'**
  String coverPickerProgress(int loaded, int total);

  /// Stats screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// Stats placeholder
  ///
  /// In en, this message translates to:
  /// **'Your statistics will appear here'**
  String get statsPlaceholder;

  /// Empty stats state subtitle
  ///
  /// In en, this message translates to:
  /// **'Add widgets to see your reading habits, goals and personal records.'**
  String get statsEmptySubtitle;

  /// No description provided for @statsAddFirstWidget.
  ///
  /// In en, this message translates to:
  /// **'Add your first widget'**
  String get statsAddFirstWidget;

  /// No description provided for @statsAddWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add widget'**
  String get statsAddWidgetTitle;

  /// No description provided for @statsGoalTargetShelf.
  ///
  /// In en, this message translates to:
  /// **'Target shelf'**
  String get statsGoalTargetShelf;

  /// No description provided for @searchFilterIsbnLabel.
  ///
  /// In en, this message translates to:
  /// **'ISBN: {isbn}'**
  String searchFilterIsbnLabel(String isbn);

  /// No description provided for @searchFilterLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language: {language}'**
  String searchFilterLanguageLabel(String language);

  /// No description provided for @searchFilterAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author: {author}'**
  String searchFilterAuthorLabel(String author);

  /// No description provided for @searchFilterPublisherLabel.
  ///
  /// In en, this message translates to:
  /// **'Publisher: {publisher}'**
  String searchFilterPublisherLabel(String publisher);

  /// No description provided for @statsGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'GOAL'**
  String get statsGoalTitle;

  /// No description provided for @statsGoalFullTitle.
  ///
  /// In en, this message translates to:
  /// **'READING GOAL'**
  String get statsGoalFullTitle;

  /// No description provided for @statsGoalUnitBooks.
  ///
  /// In en, this message translates to:
  /// **'books'**
  String get statsGoalUnitBooks;

  /// No description provided for @statsGoalUnitPages.
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get statsGoalUnitPages;

  /// No description provided for @statsGoalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String statsGoalRemaining(int count);

  /// No description provided for @statsGoalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get statsGoalCompleted;

  /// No description provided for @statsGoalNew.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get statsGoalNew;

  /// No description provided for @statsGoalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get statsGoalEdit;

  /// No description provided for @statsGoalDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get statsGoalDelete;

  /// No description provided for @statsGoalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g., Challenge 2026)'**
  String get statsGoalNameLabel;

  /// No description provided for @statsGoalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get statsGoalTypeLabel;

  /// No description provided for @statsGoalTypeBooks.
  ///
  /// In en, this message translates to:
  /// **'Books read'**
  String get statsGoalTypeBooks;

  /// No description provided for @statsGoalTypePages.
  ///
  /// In en, this message translates to:
  /// **'Pages read'**
  String get statsGoalTypePages;

  /// No description provided for @statsGoalTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Numerical target'**
  String get statsGoalTargetLabel;

  /// No description provided for @statsGoalFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get statsGoalFromLabel;

  /// No description provided for @statsGoalToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get statsGoalToLabel;

  /// No description provided for @statsPagesTitle.
  ///
  /// In en, this message translates to:
  /// **'PAGES'**
  String get statsPagesTitle;

  /// No description provided for @statsPagesSub.
  ///
  /// In en, this message translates to:
  /// **'pages read'**
  String get statsPagesSub;

  /// No description provided for @statsStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get statsStreakTitle;

  /// No description provided for @statsStreakSub.
  ///
  /// In en, this message translates to:
  /// **'days in a row'**
  String get statsStreakSub;

  /// No description provided for @statsStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statsStatusTitle;

  /// No description provided for @statsAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'BOOKS ADDED'**
  String get statsAddedTitle;

  /// No description provided for @statsAddedNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get statsAddedNoData;

  /// No description provided for @statsCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get statsCategoriesTitle;

  /// No description provided for @statsYearsTitle.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH YEARS'**
  String get statsYearsTitle;

  /// No description provided for @statsReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'READING'**
  String get statsReadingTitle;

  /// No description provided for @statsReadingNowTitle.
  ///
  /// In en, this message translates to:
  /// **'READING NOW'**
  String get statsReadingNowTitle;

  /// No description provided for @statsReadingNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing in reading'**
  String get statsReadingNone;

  /// No description provided for @statsReadByYearTitle.
  ///
  /// In en, this message translates to:
  /// **'BOOKS READ BY YEAR'**
  String get statsReadByYearTitle;

  /// No description provided for @statsCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'COLLECTIONS'**
  String get statsCollectionsTitle;

  /// No description provided for @statsLastAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'LAST ADDED'**
  String get statsLastAddedTitle;

  /// No description provided for @statsDailyReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'DAILY READING'**
  String get statsDailyReadingTitle;

  /// No description provided for @statsAvgPagesTitle.
  ///
  /// In en, this message translates to:
  /// **'AVERAGE PAGES'**
  String get statsAvgPagesTitle;

  /// No description provided for @statsAvgPagesSub.
  ///
  /// In en, this message translates to:
  /// **'pages per book'**
  String get statsAvgPagesSub;

  /// No description provided for @statsOptPagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Total pages'**
  String get statsOptPagesTitle;

  /// No description provided for @statsOptPagesSub.
  ///
  /// In en, this message translates to:
  /// **'Total pages read'**
  String get statsOptPagesSub;

  /// No description provided for @statsOptStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsOptStreakTitle;

  /// No description provided for @statsOptStreakSub.
  ///
  /// In en, this message translates to:
  /// **'Consecutive days reading'**
  String get statsOptStreakSub;

  /// No description provided for @statsOptGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading goal'**
  String get statsOptGoalTitle;

  /// No description provided for @statsOptGoalSub.
  ///
  /// In en, this message translates to:
  /// **'Books, shelves or collections'**
  String get statsOptGoalSub;

  /// No description provided for @statsOptStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading status'**
  String get statsOptStatusTitle;

  /// No description provided for @statsOptStatusSub.
  ///
  /// In en, this message translates to:
  /// **'Books by status'**
  String get statsOptStatusSub;

  /// No description provided for @statsOptCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Current book'**
  String get statsOptCurrentTitle;

  /// No description provided for @statsOptCurrentSub.
  ///
  /// In en, this message translates to:
  /// **'Current reading progress'**
  String get statsOptCurrentSub;

  /// No description provided for @statsOptAddedTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Books added'**
  String get statsOptAddedTimeTitle;

  /// No description provided for @statsOptAddedTimeSub.
  ///
  /// In en, this message translates to:
  /// **'Acquisitions timeline'**
  String get statsOptAddedTimeSub;

  /// No description provided for @statsOptCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get statsOptCategoriesTitle;

  /// No description provided for @statsOptCategoriesSub.
  ///
  /// In en, this message translates to:
  /// **'Distribution by genre'**
  String get statsOptCategoriesSub;

  /// No description provided for @statsOptYearsTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish year'**
  String get statsOptYearsTitle;

  /// No description provided for @statsOptYearsSub.
  ///
  /// In en, this message translates to:
  /// **'Historical histogram'**
  String get statsOptYearsSub;

  /// No description provided for @statsOptReadYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Read by year'**
  String get statsOptReadYearTitle;

  /// No description provided for @statsOptReadYearSub.
  ///
  /// In en, this message translates to:
  /// **'Annual reading chart'**
  String get statsOptReadYearSub;

  /// No description provided for @statsOptCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get statsOptCollectionsTitle;

  /// No description provided for @statsOptCollectionsSub.
  ///
  /// In en, this message translates to:
  /// **'Books per collection'**
  String get statsOptCollectionsSub;

  /// No description provided for @statsOptLastAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Last added'**
  String get statsOptLastAddedTitle;

  /// No description provided for @statsOptLastAddedSub.
  ///
  /// In en, this message translates to:
  /// **'Recent arrivals'**
  String get statsOptLastAddedSub;

  /// No description provided for @statsOptAvgPagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Average length'**
  String get statsOptAvgPagesTitle;

  /// No description provided for @statsOptAvgPagesSub.
  ///
  /// In en, this message translates to:
  /// **'Average pages per book'**
  String get statsOptAvgPagesSub;

  /// No description provided for @statsOptReadListTitle.
  ///
  /// In en, this message translates to:
  /// **'Read books list'**
  String get statsOptReadListTitle;

  /// No description provided for @statsOptReadListSub.
  ///
  /// In en, this message translates to:
  /// **'Books read in a period'**
  String get statsOptReadListSub;

  /// No description provided for @statsOptAvgCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Completion time'**
  String get statsOptAvgCompletionTitle;

  /// No description provided for @statsOptAvgCompletionSub.
  ///
  /// In en, this message translates to:
  /// **'Average time to finish a book'**
  String get statsOptAvgCompletionSub;

  /// No description provided for @statsOptDailyReadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reading'**
  String get statsOptDailyReadingTitle;

  /// No description provided for @statsOptDailyReadingSub.
  ///
  /// In en, this message translates to:
  /// **'Pages read per day'**
  String get statsOptDailyReadingSub;

  /// No description provided for @statsAvgCompletionValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String statsAvgCompletionValue(String days);

  /// No description provided for @statsPeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Read this month'**
  String get statsPeriodThisMonth;

  /// No description provided for @statsPeriodLast3Months.
  ///
  /// In en, this message translates to:
  /// **'Read last 3 months'**
  String get statsPeriodLast3Months;

  /// No description provided for @statsPeriodThisYear.
  ///
  /// In en, this message translates to:
  /// **'Read this year'**
  String get statsPeriodThisYear;

  /// No description provided for @statsPeriodLast3Years.
  ///
  /// In en, this message translates to:
  /// **'Read last 3 years'**
  String get statsPeriodLast3Years;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get tabMore;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTitle;

  /// Button to open system settings
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// Title for permanently denied permission dialog
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permissionRequired;

  /// No description provided for @paginationMarkersAndIndices.
  ///
  /// In en, this message translates to:
  /// **'Markers & Indices'**
  String get paginationMarkersAndIndices;

  /// No description provided for @paginationSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Save Progress'**
  String get paginationSaveProgress;

  /// No description provided for @paginationAllPagesAssigned.
  ///
  /// In en, this message translates to:
  /// **'All pages have already been assigned.'**
  String get paginationAllPagesAssigned;

  /// No description provided for @paginationChooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose color'**
  String get paginationChooseColor;

  /// No description provided for @paginationSegmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Segment {index}: All page fields are required.'**
  String paginationSegmentRequired(Object index);

  /// No description provided for @paginationSegmentStartGreater.
  ///
  /// In en, this message translates to:
  /// **'Segment {index}: Start cannot be greater than end.'**
  String paginationSegmentStartGreater(Object index);

  /// No description provided for @paginationSegmentExceedsTotal.
  ///
  /// In en, this message translates to:
  /// **'Segment {index}: Values exceed total pages ({total}).'**
  String paginationSegmentExceedsTotal(int index, int total);

  /// No description provided for @paginationSegmentOverlap.
  ///
  /// In en, this message translates to:
  /// **'Segment {index1} overlaps with Segment {index2}'**
  String paginationSegmentOverlap(String index1, String index2);

  /// No description provided for @paginationAdvancedConfig.
  ///
  /// In en, this message translates to:
  /// **'Advanced Configuration'**
  String get paginationAdvancedConfig;

  /// No description provided for @paginationBlocksSegments.
  ///
  /// In en, this message translates to:
  /// **'BLOCKS / SEGMENTS'**
  String get paginationBlocksSegments;

  /// No description provided for @paginationNoSegmentsDefined.
  ///
  /// In en, this message translates to:
  /// **'No segments defined. Defaulting to 1-N range.'**
  String get paginationNoSegmentsDefined;

  /// No description provided for @paginationAddBlock.
  ///
  /// In en, this message translates to:
  /// **'Add block'**
  String get paginationAddBlock;

  /// No description provided for @paginationAllPagesAssignedNote.
  ///
  /// In en, this message translates to:
  /// **'Note: You have already assigned all available pages.'**
  String get paginationAllPagesAssignedNote;

  /// No description provided for @paginationPagesRemainingWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: {count} physical pages remain unassigned.'**
  String paginationPagesRemainingWarning(int count);

  /// No description provided for @paginationPhysicalTotalNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Total pages refer to the physical pages of the book (total sheets).'**
  String get paginationPhysicalTotalNote;

  /// No description provided for @paginationCorrectErrors.
  ///
  /// In en, this message translates to:
  /// **'PLEASE CORRECT THE FOLLOWING ERRORS:'**
  String get paginationCorrectErrors;

  /// No description provided for @paginationMarkersLabels.
  ///
  /// In en, this message translates to:
  /// **'MARKERS / LABELS'**
  String get paginationMarkersLabels;

  /// No description provided for @paginationMarkerDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get paginationMarkerDefaultName;

  /// No description provided for @paginationSegmentsDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get paginationSegmentsDefaultName;

  /// No description provided for @paginationAddMarker.
  ///
  /// In en, this message translates to:
  /// **'Add marker'**
  String get paginationAddMarker;

  /// No description provided for @paginationLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get paginationLabelOptional;

  /// No description provided for @paginationType.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get paginationType;

  /// No description provided for @paginationArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get paginationArabic;

  /// No description provided for @paginationRoman.
  ///
  /// In en, this message translates to:
  /// **'Roman'**
  String get paginationRoman;

  /// No description provided for @paginationOffset.
  ///
  /// In en, this message translates to:
  /// **'Offset'**
  String get paginationOffset;

  /// No description provided for @paginationMarkerLabel.
  ///
  /// In en, this message translates to:
  /// **'Marker label'**
  String get paginationMarkerLabel;

  /// No description provided for @paginationVisualPage.
  ///
  /// In en, this message translates to:
  /// **'Visual Page'**
  String get paginationVisualPage;

  /// No description provided for @paginationVisualPageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., xiv or 501'**
  String get paginationVisualPageHint;

  /// No description provided for @paginationPhysicalLabel.
  ///
  /// In en, this message translates to:
  /// **'Physical: {page}'**
  String paginationPhysicalLabel(Object page);

  /// No description provided for @paginationAdjustsAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Adjusts automatically'**
  String get paginationAdjustsAutomatically;

  /// No description provided for @paginationVisualMode.
  ///
  /// In en, this message translates to:
  /// **'Visual mode'**
  String get paginationVisualMode;

  /// No description provided for @paginationEquivalentPhysical.
  ///
  /// In en, this message translates to:
  /// **'Equivalent to physical: {start} - {end}'**
  String paginationEquivalentPhysical(int start, int end);

  /// No description provided for @paginationSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Section {index}'**
  String paginationSectionLabel(int index);

  /// No description provided for @paginationProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String paginationProgress(String current, String total);

  /// No description provided for @paginationCurrentPageShort.
  ///
  /// In en, this message translates to:
  /// **'Pg.'**
  String get paginationCurrentPageShort;

  /// No description provided for @paginationStartPhysical.
  ///
  /// In en, this message translates to:
  /// **'Start (Physical)'**
  String get paginationStartPhysical;

  /// No description provided for @paginationEndPhysical.
  ///
  /// In en, this message translates to:
  /// **'End (Physical)'**
  String get paginationEndPhysical;

  /// No description provided for @paginationStartVisual.
  ///
  /// In en, this message translates to:
  /// **'Start (Visual)'**
  String get paginationStartVisual;

  /// No description provided for @paginationEndVisual.
  ///
  /// In en, this message translates to:
  /// **'End (Visual)'**
  String get paginationEndVisual;

  /// No description provided for @paginationAdvancedButton.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get paginationAdvancedButton;

  /// No description provided for @unknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownAuthor;

  /// Explanation for permanently denied storage permission
  ///
  /// In en, this message translates to:
  /// **'To select a cover you need to grant storage access. You can do this from the application settings.'**
  String get storagePermissionExplanation;

  /// Explanation for permanently denied camera permission
  ///
  /// In en, this message translates to:
  /// **'To take a photo you need to grant camera access. You can do this from the application settings.'**
  String get cameraPermissionExplanation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ca',
    'de',
    'en',
    'es',
    'et',
    'fr',
    'it',
    'ja',
    'pt',
    'ro',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
