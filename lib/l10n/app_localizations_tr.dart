// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Openshelf';

  @override
  String errorPrefix(String message) {
    return 'Hata: $message';
  }

  @override
  String errorGeneric(String error) {
    return 'Hata: $error';
  }

  @override
  String criticalStartError(String error) {
    return 'Uygulamayı başlatırken bir hata meydana geldi: $error';
  }

  @override
  String get navLibrary => 'Kütüphane';

  @override
  String get navShelves => 'Raflar';

  @override
  String get navStats => 'İstatistikler';

  @override
  String get libraryTitle => 'Kütüphane';

  @override
  String get libraryEmpty => 'Kütüphaneniz henüz boş';

  @override
  String get libraryEmptyHint => 'Ekleyeceğiniz ilk kitap ne olacak?';

  @override
  String get libraryAddFirstBook => 'İlk kitabı ekle';

  @override
  String get libraryNoResults => 'Sonuç bulunamadı';

  @override
  String get libraryNoResultsHint => 'Başka bir filtre deneyin';

  @override
  String get addBook => 'Kitap ekle';

  @override
  String get displaySettings => 'Kütüphanede göster';

  @override
  String get displaySettingsDragHint => 'Sırayı değiştirmek için sürükleyin';

  @override
  String get settingsButton => 'Ayarlar';

  @override
  String get fieldAuthor => 'Yazar';

  @override
  String get fieldPublisher => 'Editör';

  @override
  String get fieldYear => 'Yayın yılı';

  @override
  String get fieldRating => 'Değerlendirme';

  @override
  String get fieldTags => 'Etiketler';

  @override
  String get fieldReadingProgress => '';

  @override
  String get fieldStatusChip => '';

  @override
  String get searchHint => '';

  @override
  String get filterAuthor => '';

  @override
  String get filterIsbn => '';

  @override
  String get filterPublisher => '';

  @override
  String get filterCollection => '';

  @override
  String get filterImprintLabel => '';

  @override
  String imprintBookCount(int count) {
    return '';
  }

  @override
  String get filterTagsLabel => '';

  @override
  String get done => '';

  @override
  String get loading => '';

  @override
  String get loadingImport => '';

  @override
  String get loadingExport => '';

  @override
  String get exportProgressData => '';

  @override
  String get exportProgressMedia => '';

  @override
  String get exportProgressCompress => '';

  @override
  String get exportProgressFinalize => '';

  @override
  String exportSaveSuccess(String path) {
    return '';
  }

  @override
  String get cancel => '';

  @override
  String get save => '';

  @override
  String get delete => '';

  @override
  String get create => '';

  @override
  String get edit => '';

  @override
  String get duplicate => '';

  @override
  String get photo => '';

  @override
  String get url => '';

  @override
  String get download => '';

  @override
  String get retry => '';

  @override
  String get share => '';

  @override
  String get saveToDevice => '';

  @override
  String get addBookModalTitle => '';

  @override
  String get addBookModalSubtitle => '';

  @override
  String get addManually => '';

  @override
  String get addManuallySubtitle => '';

  @override
  String get searchBook => '';

  @override
  String get searchBookSubtitle => '';

  @override
  String get scanBarcode => '';

  @override
  String get scanBarcodeSubtitle => '';

  @override
  String get scanIsbnText => '';

  @override
  String get scanIsbnTextSubtitle => '';

  @override
  String get scanIsbnSelect => '';

  @override
  String get scanOcrHoldMessage => '';

  @override
  String get scanBarcodePermission => '';

  @override
  String get scanBatch => '';

  @override
  String get scanBatchSubtitle => '';

  @override
  String get scanModeBarcode => '';

  @override
  String get scanModeIsbn => '';

  @override
  String get bookFormNewTitle => '';

  @override
  String get bookFormEditTitle => '';

  @override
  String get tabMain => '';

  @override
  String get tabDetails => '';

  @override
  String get fieldTitle => '';

  @override
  String get fieldSubtitle => '';

  @override
  String get fieldDescription => '';

  @override
  String get fieldIsbn => '';

  @override
  String get fieldLanguage => '';

  @override
  String get fieldIsTranslation => '';

  @override
  String get fieldOriginalTitle => '';

  @override
  String get fieldOriginalLanguage => '';

  @override
  String get fieldTranslator => '';

  @override
  String get fieldReads => '';

  @override
  String get fieldCopies => '';

  @override
  String get fieldTotalPages => '';

  @override
  String get fieldTotalBooks => '';

  @override
  String get fieldCurrentPage => '';

  @override
  String get fieldNotes => '';

  @override
  String get fieldCollection => '';

  @override
  String get fieldCollectionNumber => '';

  @override
  String get sectionBasicInfo => '';

  @override
  String get sectionCategories => '';

  @override
  String get sectionReadingStatus => '';

  @override
  String get sectionFormat => '';

  @override
  String get sectionRating => '';

  @override
  String get sectionImprint => '';

  @override
  String get coverPickPhoto => '';

  @override
  String get coverPickUrl => '';

  @override
  String get coverSearch => '';

  @override
  String get coverUrlDialogTitle => '';

  @override
  String get coverUrlHint => '';

  @override
  String get coverDownloadError => '';

  @override
  String get imageProcessError => '';

  @override
  String get imageProcessing => 'Görüntü işleniyor...';

  @override
  String get imagePreparing => 'Görüntü hazırlanıyor...';

  @override
  String get imageOptimizing => 'Görüntü optimize ediliyor...';

  @override
  String get cropCoverTitle => '';

  @override
  String get cropImprintTitle => '';

  @override
  String get tagSearchOrCreate => '';

  @override
  String get tagCreateHint => '';

  @override
  String get tagNoCategories => '';

  @override
  String get imprintSearch => '';

  @override
  String get requiredField => '';

  @override
  String get statusWantToRead => '';

  @override
  String get statusReading => '';

  @override
  String get statusRead => '';

  @override
  String get statusAbandoned => '';

  @override
  String get statusPaused => '';

  @override
  String get ownershipStatusBought => '';

  @override
  String get ownershipStatusGifted => '';

  @override
  String get ownershipStatusBorrowed => '';

  @override
  String get ownershipStatusReturned => '';

  @override
  String get ownershipStatusSold => '';

  @override
  String get ownershipStatusOther => '';

  @override
  String get formatPaperback => '';

  @override
  String get formatHardcover => '';

  @override
  String get formatLeatherbound => '';

  @override
  String get formatRustic => '';

  @override
  String get formatDigital => '';

  @override
  String get formatOther => '';

  @override
  String get bookDetailNotFound => '';

  @override
  String get bookDetailPagePickerTitle => '';

  @override
  String get bookDetailNotesTitle => '';

  @override
  String get bookDetailNotesHint => '';

  @override
  String get bookDetailNotesEmpty => '';

  @override
  String get bookDetailDeleteTitle => '';

  @override
  String bookDetailDeleteConfirm(String title) {
    return '';
  }

  @override
  String get bookDetailDuplicateTitle => '';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return '';
  }

  @override
  String get bookDetailNewReadingWholeBook => '';

  @override
  String get bookDetailNewReadingWholeBookDescription => '';

  @override
  String get bookDetailNewReadingSections => '';

  @override
  String bookDetailNewReadingSectionsCount(int count) {
    return '';
  }

  @override
  String bookDetailNewReadingReadCount(Object count) {
    return '';
  }

  @override
  String get bookDetailNewReadingSelectSections => '';

  @override
  String get bookDetailStartNewReadingPrompt => '';

  @override
  String get bookDetailStartNewReadingTitle => '';

  @override
  String get bookDetailStartNewReadingButton => '';

  @override
  String get selectAll => '';

  @override
  String get bookDetailDeleteReadPrompt => '';

  @override
  String get bookDetailReadHistoryTitle => '';

  @override
  String get bookDetailReadOngoing => '';

  @override
  String bookDetailReadNumber(int number) {
    return '';
  }

  @override
  String bookDetailReadEditDialogTitle(Object number) {
    return '';
  }

  @override
  String get bookDetailReadDeleteConfirm => '';

  @override
  String get bookDetailReadNumberLabel => '';

  @override
  String get bookDetailFieldPages => '';

  @override
  String get bookDetailFieldCategories => '';

  @override
  String get bookDetailFieldFormat => '';

  @override
  String get bookDetailFieldRating => '';

  @override
  String get bookDetailFieldImprintSection => '';

  @override
  String get bookDetailFieldPersonalNotes => '';

  @override
  String get bookDetailFieldAdded => '';

  @override
  String get bookDetailFieldStarted => '';

  @override
  String get bookDetailFieldFinished => '';

  @override
  String get fieldOwnershipStatus => '';

  @override
  String get ownershipHistoryTitle => '';

  @override
  String get ownershipLogEmpty => '';

  @override
  String get ownershipEventPerson => '';

  @override
  String get ownershipEventDate => '';

  @override
  String get ownershipEventNotes => '';

  @override
  String pageProgress(String current, String total, String percent) {
    return '';
  }

  @override
  String pageProgressShort(String current, String total) {
    return '';
  }

  @override
  String pageSuffix(int count) {
    return '';
  }

  @override
  String get pagesLabel => '';

  @override
  String get shelvesTitle => '';

  @override
  String get shelvesSectionByStatus => '';

  @override
  String get shelvesSectionMine => '';

  @override
  String get shelvesSectionManagement => '';

  @override
  String get shelfAllBooks => '';

  @override
  String get shelfReading => '';

  @override
  String get shelfRead => '';

  @override
  String booksReadProgress(int readCount, int totalCount) {
    return '$readCount / $totalCount libros leídos';
  }

  @override
  String get shelfWantToRead => '';

  @override
  String get shelfAbandoned => '';

  @override
  String get shelfPaused => '';

  @override
  String get shelfNewTooltip => '';

  @override
  String get shelfEmpty => '';

  @override
  String get shelfEmptySubtitle => '';

  @override
  String get shelvesAddFirstShelf => '';

  @override
  String get shelfBooksEmpty => '';

  @override
  String get shelfBooksEmptyHint =>
      'Los libros que coincidan con sus filtros aparecerán aquí.';

  @override
  String get shelfStatusBooksEmpty => '';

  @override
  String get shelfFormNew => '';

  @override
  String get shelfFormEdit => '';

  @override
  String get shelfFormNameLabel => '';

  @override
  String get collectionNameLabel => '';

  @override
  String get shelfFormSectionStatus => '';

  @override
  String get shelfFormSectionTitle => '';

  @override
  String get shelfFormSectionAuthor => '';

  @override
  String get shelfFormSectionPublisher => '';

  @override
  String get shelfFormSectionIsbn => '';

  @override
  String get shelfFormSectionCollection => '';

  @override
  String get shelfFormSectionCategories => '';

  @override
  String get shelfFormSectionImprint => '';

  @override
  String get shelfFormHintTitle => '';

  @override
  String get shelfFormHintAuthor => '';

  @override
  String get shelfFormHintPublisher => '';

  @override
  String get shelfFormHintIsbn => '';

  @override
  String get shelfFormHintCollection => '';

  @override
  String get shelfFormStatusAny => '';

  @override
  String get shelfOptionEdit => '';

  @override
  String get shelfOptionDelete => '';

  @override
  String get shelfStatusLabelReading => '';

  @override
  String get shelfStatusLabelRead => '';

  @override
  String get shelfStatusLabelWantToRead => '';

  @override
  String get shelfStatusLabelAbandoned => '';

  @override
  String get shelfStatusLabelPaused => '';

  @override
  String get managementCategories => '';

  @override
  String get managementCategoryCount => '';

  @override
  String get managementImprints => '';

  @override
  String get managementCollections => '';

  @override
  String get managementCategoryCloudCurve => '';

  @override
  String get tagNone => '';

  @override
  String get tagNoneSubtitle => '';

  @override
  String get categoriesAddFirst => '';

  @override
  String get tagNew => '';

  @override
  String get tagNewDialogTitle => '';

  @override
  String get tagNameLabel => '';

  @override
  String get tagColorLabel => '';

  @override
  String get tagDeleteTitle => '';

  @override
  String tagDeleteConfirm(String name) {
    return '';
  }

  @override
  String get imprintNone => '';

  @override
  String get imprintNoneSubtitle => '';

  @override
  String get imprintsAddFirst => '';

  @override
  String get imprintNew => '';

  @override
  String get imprintNewDialogTitle => '';

  @override
  String get imprintEditDialogTitle => '';

  @override
  String get imprintNameLabel => '';

  @override
  String get imprintAddImageHint => '';

  @override
  String get imprintChangeImageHint => '';

  @override
  String get imprintUrlDialogTitle => '';

  @override
  String get imprintUrlHint => '';

  @override
  String get imprintDeleteTitle => '';

  @override
  String imprintDeleteConfirm(String name) {
    return '';
  }

  @override
  String get imprintNoImprints => '';

  @override
  String get collectionNone => '';

  @override
  String get collectionNoneSubtitle => '';

  @override
  String get collectionsAddFirst => '';

  @override
  String get collectionDeleteTitle => '';

  @override
  String collectionDeleteConfirm(String name) {
    return '';
  }

  @override
  String get onboardingWelcomeTitle => '';

  @override
  String get onboardingWelcomeSub => '';

  @override
  String get onboardingOrganizeTitle => '';

  @override
  String get onboardingOrganizeSub => '';

  @override
  String get onboardingProgressTitle => '';

  @override
  String get onboardingProgressSub => '';

  @override
  String get onboardingAddTitle => '';

  @override
  String get onboardingAddSub => '';

  @override
  String get onboardingNext => '';

  @override
  String get onboardingStart => '';

  @override
  String get settingsApplyIcon => '';

  @override
  String get settingsDynamicIcon => '';

  @override
  String get settingsDynamicIconSub => '';

  @override
  String get settingsLibraryColumns => '';

  @override
  String get settingsLibraryColumnsSub => '';

  @override
  String get settingsTitle => '';

  @override
  String get settingsSectionAppearance => '';

  @override
  String get settingsLanguage => '';

  @override
  String get settingsLanguageSystem => '';

  @override
  String get settingsLanguageSpanish => '';

  @override
  String get settingsLanguageEnglish => '';

  @override
  String get settingsLanguageFrench => 'Francés';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsLanguageCatalan => 'Catalán';

  @override
  String get settingsLanguagePortuguese => 'Portugués (Portugal)';

  @override
  String get settingsLanguagePortugueseBR => 'Portugués (Brasil)';

  @override
  String get settingsThemeMode => '';

  @override
  String get settingsThemeLight => '';

  @override
  String get settingsThemeSystem => '';

  @override
  String get settingsThemeDark => '';

  @override
  String get settingsAccentColor => '';

  @override
  String get settingsAccentColorHint => '';

  @override
  String get settingsSectionStorage => '';

  @override
  String get settingsCoversFolder => '';

  @override
  String get settingsDatabase => '';

  @override
  String get settingsDefaultDir => '';

  @override
  String get settingsDbMoveTitle => '';

  @override
  String get settingsDbMoveContent => '';

  @override
  String get settingsDbMoveConfirm => '';

  @override
  String get settingsSectionSearch => '';

  @override
  String get settingsSearchServer => '';

  @override
  String get settingsSearchServerHint => '';

  @override
  String get settingsSectionData => '';

  @override
  String get dataManagementOpenShelf => '';

  @override
  String get dataManagementBookshelf => '';

  @override
  String get dataManagementGoodreads => '';

  @override
  String get dataManagementLibraryThing => '';

  @override
  String get dataManagementImport => '';

  @override
  String get dataManagementExport => '';

  @override
  String dataManagementImportHint(String source) {
    return '';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return '';
  }

  @override
  String dataManagementExportHint(String source) {
    return '';
  }

  @override
  String dataManagementExportHintJson(Object source) {
    return '';
  }

  @override
  String get dataManagementRestoreBackup => '';

  @override
  String get dataManagementRestoreBackupHint => '';

  @override
  String get dataManagementCreateBackup => '';

  @override
  String get dataManagementCreateBackupHint => '';

  @override
  String get settingsImportBookshelf => '';

  @override
  String get settingsImportBookshelfHint => '';

  @override
  String get settingsExportCsv => '';

  @override
  String get settingsExportCsvHint => '';

  @override
  String get settingsFullBackup => '';

  @override
  String get settingsFullBackupHint => '';

  @override
  String get settingsAllFilesAccess => 'All Files Access';

  @override
  String get settingsAllFilesAccessSub =>
      'Required to move database to external folders (Android 11+)';

  @override
  String get settingsAllFilesAccessInfo =>
      'This permission allows Openshelf to manage files outside its private directory. It is required to move the database to a custom folder.';

  @override
  String get settingsAutoNoCoverTitle => '';

  @override
  String get settingsAutoNoCoverSub => '';

  @override
  String get noCoverShelfTitle => '';

  @override
  String get settingsCompressImagesTitle => '';

  @override
  String get settingsCompressImagesSub => '';

  @override
  String get settingsBatchCompressTitle => '';

  @override
  String get settingsBatchCompressSub => '';

  @override
  String settingsBatchCompressSuccess(int count) {
    return '';
  }

  @override
  String get exportTitle => '';

  @override
  String get exportCoversPrompt => '';

  @override
  String get importRestoreCoversTitle => '';

  @override
  String get importRestoreCoversPrompt => '';

  @override
  String get yes => '';

  @override
  String get no => '';

  @override
  String get devDeleteAllBooks => '';

  @override
  String get settingsDevClearDbSub => '';

  @override
  String get settingsDevDbCleared => '';

  @override
  String get settingsImportSelectBackup => '';

  @override
  String get settingsImportSelectCovers => '';

  @override
  String get devDeleteConfirmTitle => '';

  @override
  String get devDeleteConfirmContent => '';

  @override
  String importSuccess(int count) {
    return '';
  }

  @override
  String importPartial(int added, int skipped) {
    return '';
  }

  @override
  String get settingsApiKeyTitle => '';

  @override
  String get settingsApiKeyConfigured => '';

  @override
  String get settingsApiKeyMissing => '';

  @override
  String get settingsApiKeyHint => '';

  @override
  String get settingsApiKeyShow => '';

  @override
  String get settingsApiKeyHide => '';

  @override
  String get settingsApiKeySave => '';

  @override
  String get settingsApiKeySaved => '';

  @override
  String get settingsApiKeyClear => '';

  @override
  String get settingsApiKeyHowTo => '';

  @override
  String get settingsApiKeyInstructionsTitle => '';

  @override
  String get settingsApiKeyStep1 => '';

  @override
  String get settingsApiKeyStep2 => '';

  @override
  String get settingsApiKeyStep3 => '';

  @override
  String get settingsApiKeyStep4 => '';

  @override
  String get settingsApiKeyStep5 => '';

  @override
  String get settingsApiKeyStep6 => '';

  @override
  String get settingsApiKeyNote => '';

  @override
  String get bookSearchHint => '';

  @override
  String get bookSearchPrompt => '';

  @override
  String bookSearchNoResults(String query) {
    return '';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return '';
  }

  @override
  String get bookSearchRecommended => '';

  @override
  String get bookSearchRecommendedSource => '';

  @override
  String get bookSearchServerOpenLibrary => '';

  @override
  String get bookSearchServerGoogleBooks => '';

  @override
  String get bookSearchServerInventaire => '';

  @override
  String get searchTabStatus => '';

  @override
  String get searchTabImprint => '';

  @override
  String get searchTabCategory => '';

  @override
  String get searchTabCollection => '';

  @override
  String searchFilterStatus(String value) {
    return '';
  }

  @override
  String searchFilterImprint(String value) {
    return '';
  }

  @override
  String searchFilterCategory(String value) {
    return '';
  }

  @override
  String searchFilterCollection(String value) {
    return '';
  }

  @override
  String searchActiveFilters(int count) {
    return '';
  }

  @override
  String get searchSaveAsShelf => '';

  @override
  String get shelfShowInLibrary => '';

  @override
  String get searchClearAll => '';

  @override
  String get addedToLibrary => '';

  @override
  String get errorDuplicateIsbn => '';

  @override
  String get bookDuplicateTitle => '';

  @override
  String bookDuplicateContent(String isbn) {
    return '';
  }

  @override
  String get bookSearchErrorNoApiKey => '';

  @override
  String get bookSearchErrorRateLimit => '';

  @override
  String get bookSearchErrorNetwork => '';

  @override
  String get coverPickerTitle => '';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return '';
  }

  @override
  String get coverPickerNoResults => '';

  @override
  String get coverPickerNetworkError => '';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '';
  }

  @override
  String get statsTitle => '';

  @override
  String get statsPlaceholder => '';

  @override
  String get statsEmptySubtitle => '';

  @override
  String get statsAddFirstWidget => '';

  @override
  String get statsAddWidgetTitle => '';

  @override
  String get statsGoalTargetShelf => '';

  @override
  String searchFilterIsbnLabel(String isbn) {
    return '';
  }

  @override
  String searchFilterLanguageLabel(String language) {
    return '';
  }

  @override
  String searchFilterAuthorLabel(String author) {
    return '';
  }

  @override
  String searchFilterSubtitleLabel(String subtitle) {
    return 'Subtítulo: $subtitle';
  }

  @override
  String searchFilterTranslatorLabel(String translator) {
    return 'Traductor: $translator';
  }

  @override
  String searchFilterPublisherLabel(String publisher) {
    return '';
  }

  @override
  String get statsGoalTitle => '';

  @override
  String get statsGoalFullTitle => '';

  @override
  String get statsGoalUnitBooks => '';

  @override
  String get statsGoalUnitPages => '';

  @override
  String statsGoalRemaining(int count) {
    return '';
  }

  @override
  String get statsGoalCompleted => '';

  @override
  String get statsGoalNew => '';

  @override
  String get statsGoalEdit => '';

  @override
  String get statsGoalDelete => '';

  @override
  String get statsGoalNameLabel => '';

  @override
  String get statsGoalTypeLabel => '';

  @override
  String get statsGoalTypeBooks => '';

  @override
  String get statsGoalTypePages => '';

  @override
  String get statsGoalTargetLabel => '';

  @override
  String get statsGoalFromLabel => '';

  @override
  String get statsGoalToLabel => '';

  @override
  String get statsPagesTitle => '';

  @override
  String get statsPagesSub => '';

  @override
  String get statsStreakTitle => '';

  @override
  String get statsStreakSub => '';

  @override
  String get statsStatusTitle => '';

  @override
  String get statsAddedTitle => '';

  @override
  String get statsAddedNoData => '';

  @override
  String get statsCategoriesTitle => '';

  @override
  String get statsYearsTitle => '';

  @override
  String get statsReadingTitle => '';

  @override
  String get statsReadingNowTitle => '';

  @override
  String get statsReadingNone => '';

  @override
  String get statsReadByYearTitle => '';

  @override
  String get statsCollectionsTitle => '';

  @override
  String get statsLastAddedTitle => '';

  @override
  String get statsDailyReadingTitle => '';

  @override
  String get statsAvgPagesTitle => '';

  @override
  String get statsAvgPagesSub => '';

  @override
  String get statsOptPagesTitle => '';

  @override
  String get statsOptPagesSub => '';

  @override
  String get statsOptStreakTitle => '';

  @override
  String get statsOptStreakSub => '';

  @override
  String get statsOptGoalTitle => '';

  @override
  String get statsOptGoalSub => '';

  @override
  String get statsOptStatusTitle => '';

  @override
  String get statsOptStatusSub => '';

  @override
  String get statsOptCurrentTitle => '';

  @override
  String get statsOptCurrentSub => '';

  @override
  String get statsOptAddedTimeTitle => '';

  @override
  String get statsOptAddedTimeSub => '';

  @override
  String get statsOptCategoriesTitle => '';

  @override
  String get statsOptCategoriesSub => '';

  @override
  String get statsOptYearsTitle => '';

  @override
  String get statsOptYearsSub => '';

  @override
  String get statsOptReadYearTitle => '';

  @override
  String get statsOptReadYearSub => '';

  @override
  String get statsOptCollectionsTitle => '';

  @override
  String get statsOptCollectionsSub => '';

  @override
  String get statsOptLastAddedTitle => '';

  @override
  String get statsOptLastAddedSub => '';

  @override
  String get statsOptAvgPagesTitle => '';

  @override
  String get statsOptAvgPagesSub => '';

  @override
  String get statsOptReadListTitle => '';

  @override
  String get statsOptReadListSub => '';

  @override
  String get statsOptAvgCompletionTitle => '';

  @override
  String get statsOptAvgCompletionSub => '';

  @override
  String get statsOptDailyReadingTitle => '';

  @override
  String get statsOptDailyReadingSub => '';

  @override
  String statsAvgCompletionValue(String days) {
    return '';
  }

  @override
  String get statsPeriodThisMonth => '';

  @override
  String get statsPeriodLast3Months => '';

  @override
  String get statsPeriodThisYear => '';

  @override
  String get statsPeriodLast3Years => '';

  @override
  String get tabMore => '';

  @override
  String get sortTitle => '';

  @override
  String get openSettings => '';

  @override
  String get permissionRequired => '';

  @override
  String get paginationMarkersAndIndices => '';

  @override
  String get paginationSaveProgress => '';

  @override
  String get paginationAllPagesAssigned => '';

  @override
  String get paginationChooseColor => '';

  @override
  String paginationSegmentRequired(Object index) {
    return '';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return '';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return '';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return '';
  }

  @override
  String get paginationAdvancedConfig => '';

  @override
  String get paginationBlocksSegments => '';

  @override
  String get paginationNoSegmentsDefined => '';

  @override
  String get paginationAddBlock => '';

  @override
  String get paginationAllPagesAssignedNote => '';

  @override
  String paginationPagesRemainingWarning(int count) {
    return '';
  }

  @override
  String get paginationPhysicalTotalNote => '';

  @override
  String get paginationCorrectErrors => '';

  @override
  String get paginationMarkersLabels => '';

  @override
  String get paginationMarkerDefaultName => '';

  @override
  String get paginationSegmentsDefaultName => '';

  @override
  String get paginationAddMarker => '';

  @override
  String get paginationLabelOptional => '';

  @override
  String get paginationType => '';

  @override
  String get paginationArabic => '';

  @override
  String get paginationRoman => '';

  @override
  String get paginationOffset => '';

  @override
  String get paginationMarkerLabel => '';

  @override
  String get paginationVisualPage => '';

  @override
  String get paginationVisualPageHint => '';

  @override
  String paginationPhysicalLabel(Object page) {
    return '';
  }

  @override
  String get paginationAdjustsAutomatically => '';

  @override
  String get paginationVisualMode => '';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return '';
  }

  @override
  String paginationSectionLabel(int index) {
    return '';
  }

  @override
  String paginationProgress(String current, String total) {
    return '';
  }

  @override
  String get searchModeBasic => 'Básica';

  @override
  String get searchModeAdvanced => 'Avanzada';

  @override
  String get searchModeBoolean => 'Booleana';

  @override
  String get searchAddCondition => 'Añadir condición';

  @override
  String get searchPreview => 'Vista previa';

  @override
  String get searchFieldTitle => 'Título';

  @override
  String get searchFieldAuthor => 'Autor';

  @override
  String get searchFieldPublisher => 'Editorial';

  @override
  String get searchFieldIsbn => 'ISBN';

  @override
  String get searchFieldLanguage => 'Idioma';

  @override
  String get searchFieldOriginalTitle => 'Título original';

  @override
  String get searchFieldOriginalLanguage => 'Idioma original';

  @override
  String get searchFieldYear => 'Año';

  @override
  String get searchFieldPages => 'Páginas';

  @override
  String get searchFieldStatus => 'Estado';

  @override
  String get searchFieldCategory => 'Categoría';

  @override
  String get searchFieldImprint => 'Sello';

  @override
  String get searchFieldCollection => 'Colección';

  @override
  String get searchFieldNoCover => 'Sin portada';

  @override
  String get searchFieldNotes => 'Notas';

  @override
  String get searchFieldHasNotes => 'Tiene notas';

  @override
  String get searchOpContains => 'contiene';

  @override
  String get searchOpExactly => 'es exactamente';

  @override
  String get searchOpStartsWith => 'empieza por';

  @override
  String get searchOpIncludes => 'incluye';

  @override
  String get searchOpNotIncludes => 'no incluye';

  @override
  String get searchOpIncludesAll => 'incluye todos';

  @override
  String get searchOpEquals => '=';

  @override
  String get searchOpNotEquals => '≠';

  @override
  String get searchOpGreaterThan => '>';

  @override
  String get searchOpLessThan => '<';

  @override
  String get searchOpBetween => 'entre';

  @override
  String get searchOpIs => 'es';

  @override
  String get searchOpIsNot => 'no es';

  @override
  String get paginationCurrentPageShort => '';

  @override
  String get paginationStartPhysical => '';

  @override
  String get paginationEndPhysical => '';

  @override
  String get paginationStartVisual => '';

  @override
  String get paginationEndVisual => '';

  @override
  String get paginationAdvancedButton => '';

  @override
  String get unknownAuthor => '';

  @override
  String get storagePermissionExplanation => '';

  @override
  String get cameraPermissionExplanation => '';

  @override
  String get settingsAutoPruneTagsTitle => 'Kullanılmayan kategorileri temizle';

  @override
  String get settingsAutoPruneTagsSub =>
      'Herhangi bir kitap tarafından kullanılmayan kategorileri otomatik olarak sil';

  @override
  String get settingsExcludedPruneTagsTitle => 'Hariç tutulan kategoriler';

  @override
  String settingsExcludedPruneTagsSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kategori koruma altında',
      one: '1 kategori koruma altında',
      zero: 'Hariç tutulan kategori yok',
    );
    return '$_temp0';
  }

  @override
  String get settingsPruneWarningTitle =>
      'Kullanılmayan kategoriler tespit edildi';

  @override
  String get settingsPruneWarningContent =>
      'Bu seçeneği etkinleştirmek, herhangi bir kitap tarafından kullanılmadıkları için aşağıdaki kategorileri silecektir. Devam etmek istiyor musunuz?';

  @override
  String get settingsAutomationTitle => 'Otomasyon';

  @override
  String get removeFromCollection => 'Koleksiyondan kaldır';

  @override
  String get removeFromImprint => 'Künyeden kaldır';

  @override
  String get removeFromCategory => 'Kategoriden kaldır';
}
