// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => '';

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
    return '';
  }

  @override
  String get navLibrary => '';

  @override
  String get navShelves => '';

  @override
  String get navStats => '';

  @override
  String get libraryTitle => '';

  @override
  String get libraryEmpty => '';

  @override
  String get libraryEmptyHint => '';

  @override
  String get libraryAddFirstBook => '';

  @override
  String get libraryNoResults => '';

  @override
  String get libraryNoResultsHint => '';

  @override
  String get addBook => '';

  @override
  String get displaySettings => '';

  @override
  String get displaySettingsDragHint => '';

  @override
  String get settingsButton => '';

  @override
  String get fieldAuthor => '';

  @override
  String get fieldPublisher => '';

  @override
  String get fieldYear => '';

  @override
  String get fieldRating => '';

  @override
  String get fieldTags => '';

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
  String get loadingImport => 'Importando libros, por favor espera...';

  @override
  String get loadingExport => 'Exportando libros, por favor espera...';

  @override
  String get exportProgressData => 'Exportando datos...';

  @override
  String get exportProgressMedia => 'Preparando archivos multimedia...';

  @override
  String get exportProgressCompress => 'Comprimiendo copia de seguridad...';

  @override
  String get exportProgressFinalize => 'Abriendo menú de compartir...';

  @override
  String exportSaveSuccess(String path) {
    return 'Copia de seguridad guardada en $path';
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
  String get duplicate => 'Duplicar';

  @override
  String get photo => '';

  @override
  String get url => '';

  @override
  String get download => '';

  @override
  String get retry => '';

  @override
  String get share => 'Compartir';

  @override
  String get saveToDevice => 'Guardar en dispositivo';

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
  String get scanIsbnText => 'Escanear número ISBN';

  @override
  String get scanIsbnTextSubtitle => '';

  @override
  String get scanIsbnSelect => 'Toca un ISBN para seleccionarlo';

  @override
  String get scanOcrHoldMessage => '';

  @override
  String get scanBarcodePermission => '';

  @override
  String get scanBatch => '';

  @override
  String get scanBatchSubtitle => '';

  @override
  String get scanModeBarcode => 'Código de barras';

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
  String get fieldSubtitle => 'Subtítulo';

  @override
  String get fieldDescription => '';

  @override
  String get fieldIsbn => '';

  @override
  String get fieldLanguage => 'Idioma';

  @override
  String get fieldIsTranslation => '¿Es una traducción?';

  @override
  String get fieldOriginalTitle => 'Título original';

  @override
  String get fieldOriginalLanguage => 'Idioma original';

  @override
  String get fieldTranslator => '';

  @override
  String get fieldReads => 'Lecturas';

  @override
  String get fieldCopies => 'Copias';

  @override
  String get fieldTotalPages => '';

  @override
  String get fieldTotalBooks => 'Libros totales';

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
  String get imageProcessError => 'No se pudo procesar la imagen';

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
  String get statusPaused => 'Pausado';

  @override
  String get ownershipStatusBought => 'Comprado';

  @override
  String get ownershipStatusGifted => 'Regalado';

  @override
  String get ownershipStatusBorrowed => 'Prestado';

  @override
  String get ownershipStatusReturned => 'Devuelto';

  @override
  String get ownershipStatusSold => 'Vendido';

  @override
  String get ownershipStatusOther => 'Otro';

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
  String get bookDetailDuplicateTitle => 'Duplicar libro';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return '¿Quieres crear una copia exacta de \"$title\"?';
  }

  @override
  String get bookDetailNewReadingWholeBook => 'Todo el libro';

  @override
  String get bookDetailNewReadingWholeBookDescription =>
      'Se registrará una relectura completa a partir de hoy.';

  @override
  String get bookDetailNewReadingSections => 'Secciones';

  @override
  String bookDetailNewReadingSectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secciones',
      one: '1 sección',
    );
    return '$_temp0';
  }

  @override
  String bookDetailNewReadingReadCount(Object count) {
    return 'Leída ${count}x';
  }

  @override
  String get bookDetailNewReadingSelectSections =>
      'Seleccionar secciones para releer';

  @override
  String get bookDetailStartNewReadingPrompt =>
      '¿Quieres empezar una nueva lectura?';

  @override
  String get bookDetailStartNewReadingTitle => 'Nueva lectura';

  @override
  String get bookDetailStartNewReadingButton => 'Empezar nueva lectura';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get bookDetailDeleteReadPrompt =>
      '¿Eliminar la última lectura en curso? Se perderán las fechas de esta sesión.';

  @override
  String get bookDetailReadHistoryTitle => 'HISTORIAL DE LECTURAS';

  @override
  String get bookDetailReadOngoing => 'en curso';

  @override
  String bookDetailReadNumber(int number) {
    return 'Lectura $number';
  }

  @override
  String bookDetailReadEditDialogTitle(Object number) {
    return 'Editar lectura $number';
  }

  @override
  String get bookDetailReadDeleteConfirm =>
      '¿Eliminar esta entrada del historial?';

  @override
  String get bookDetailReadNumberLabel => 'Número de lectura';

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
  String get fieldOwnershipStatus => 'Estado de propiedad';

  @override
  String get ownershipHistoryTitle => 'HISTORIAL DE PROPIEDAD';

  @override
  String get ownershipLogEmpty => 'No hay eventos de propiedad registrados.';

  @override
  String get ownershipEventPerson => 'Persona / Quién';

  @override
  String get ownershipEventDate => 'Fecha';

  @override
  String get ownershipEventNotes => 'Notas';

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
  String get shelfEmptySubtitle => 'Organiza tus lecturas como quieras';

  @override
  String get shelvesAddFirstShelf => 'Crear estantería';

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
  String get collectionNameLabel => 'Nombre de la colección';

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
  String get shelfStatusLabelPaused => 'Pausados';

  @override
  String get managementCategories => '';

  @override
  String get managementCategoryCount => '';

  @override
  String get managementImprints => '';

  @override
  String get managementCollections => '';

  @override
  String get managementCategoryCloudCurve => 'Curva algorítmica (Libros)';

  @override
  String get tagNone => '';

  @override
  String get tagNoneSubtitle => '';

  @override
  String get categoriesAddFirst => 'Nueva categoría';

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
  String get imprintNoneSubtitle =>
      'Agrupa tus libros por editoriales o sus sellos';

  @override
  String get imprintsAddFirst => 'Añadir sello';

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
  String get collectionsAddFirst => 'Nueva colección';

  @override
  String get collectionDeleteTitle => '';

  @override
  String collectionDeleteConfirm(String name) {
    return '';
  }

  @override
  String get onboardingWelcomeTitle => '';

  @override
  String get onboardingWelcomeSub => 'Tu biblioteca personal, reimaginada';

  @override
  String get onboardingOrganizeTitle => '';

  @override
  String get onboardingOrganizeSub =>
      'Crea estanterías inteligentes y colecciones temáticas';

  @override
  String get onboardingProgressTitle => '';

  @override
  String get onboardingProgressSub => '';

  @override
  String get onboardingAddTitle => 'Añade al instante';

  @override
  String get onboardingAddSub => 'Escanea códigos de barras o busca en la nube';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Empezar ahora';

  @override
  String get settingsApplyIcon => '';

  @override
  String get settingsDynamicIcon => 'Icono de la app dinámico';

  @override
  String get settingsDynamicIconSub =>
      'Cambia el icono de la pantalla de inicio para que coincida con el color elegido (La app se reiniciará)';

  @override
  String get settingsLibraryColumns => '';

  @override
  String get settingsLibraryColumnsSub =>
      'Ajusta el número de libros por fila en la vista de cuadrícula';

  @override
  String get settingsTitle => '';

  @override
  String get settingsSectionAppearance => '';

  @override
  String get settingsLanguage => '';

  @override
  String get settingsLanguageSystem => '';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'Inglés';

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
  String get settingsSectionData => 'Gestión de datos';

  @override
  String get dataManagementOpenShelf => '';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => '';

  @override
  String get dataManagementExport => '';

  @override
  String dataManagementImportHint(String source) {
    return 'Importar desde CSV de $source';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return 'Importar desde JSON de $source';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Exportar a CSV de $source';
  }

  @override
  String dataManagementExportHintJson(Object source) {
    return 'Exportar a JSON de $source';
  }

  @override
  String get dataManagementRestoreBackup => 'Restaurar copia de seguridad';

  @override
  String get dataManagementRestoreBackupHint =>
      'Restaurar desde CSV/ZIP de OpenShelf';

  @override
  String get dataManagementCreateBackup => 'Crear copia de seguridad';

  @override
  String get dataManagementCreateBackupHint =>
      'Exportación completa con opción de portadas';

  @override
  String get settingsImportBookshelf => 'Importar desde Bookshelf';

  @override
  String get settingsImportBookshelfHint => '';

  @override
  String get settingsExportCsv => '';

  @override
  String get settingsExportCsvHint => '';

  @override
  String get settingsFullBackup => 'Restaurar biblioteca';

  @override
  String get settingsFullBackupHint =>
      'Restaurar libros desde una copia de seguridad CSV';

  @override
  String get settingsAllFilesAccess => 'All Files Access';

  @override
  String get settingsAllFilesAccessSub =>
      'Required to move database to external folders (Android 11+)';

  @override
  String get settingsAllFilesAccessInfo =>
      'This permission allows Openshelf to manage files outside its private directory. It is required to move the database to a custom folder.';

  @override
  String get settingsAutoNoCoverTitle => 'Estantería sin portadas';

  @override
  String get settingsAutoNoCoverSub => '';

  @override
  String get noCoverShelfTitle => 'Libros sin portada';

  @override
  String get settingsCompressImagesTitle => '';

  @override
  String get settingsCompressImagesSub =>
      'Reduce el peso de las imágenes al guardarlas o importarlas';

  @override
  String get settingsBatchCompressTitle => '';

  @override
  String get settingsBatchCompressSub => '';

  @override
  String settingsBatchCompressSuccess(int count) {
    return 'Se han optimizado $count portadas.';
  }

  @override
  String get exportTitle => 'Exportar biblioteca';

  @override
  String get exportCoversPrompt =>
      '¿Quieres incluir las imágenes de las portadas en la copia de seguridad? (Se creará un archivo ZIP junto al CSV)';

  @override
  String get importRestoreCoversTitle => 'Restaurar portadas';

  @override
  String get importRestoreCoversPrompt => '';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get devDeleteAllBooks => '';

  @override
  String get settingsDevClearDbSub => '';

  @override
  String get settingsDevDbCleared => 'Base de datos limpiada';

  @override
  String get settingsImportSelectBackup =>
      'Seleccionar copia de seguridad de Openshelf';

  @override
  String get settingsImportSelectCovers => '';

  @override
  String get devDeleteConfirmTitle => '¿Vaciar Biblioteca?';

  @override
  String get devDeleteConfirmContent =>
      'Esto eliminará permanentemente TODOS los libros y categorías. Solo para pruebas. ¿Continuar?';

  @override
  String importSuccess(int count) {
    return 'Importación completada: $count libros añadidos.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Importación parcial: $added añadidos, $skipped omitidos.';
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
  String get bookSearchRecommended => 'RECOMENDADO POR OPENSHELF';

  @override
  String get bookSearchRecommendedSource => '';

  @override
  String get bookSearchServerOpenLibrary => '';

  @override
  String get bookSearchServerGoogleBooks => '';

  @override
  String get bookSearchServerInventaire => '';

  @override
  String get searchTabStatus => 'Estado';

  @override
  String get searchTabImprint => '';

  @override
  String get searchTabCategory => '';

  @override
  String get searchTabCollection => 'Colección';

  @override
  String searchFilterStatus(String value) {
    return '';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Sello: $value';
  }

  @override
  String searchFilterCategory(String value) {
    return '';
  }

  @override
  String searchFilterCollection(String value) {
    return 'Col.: $value';
  }

  @override
  String searchActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtros activos',
      one: '1 filtro activo',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => '';

  @override
  String get shelfShowInLibrary => 'Mostrar en biblioteca';

  @override
  String get searchClearAll => 'Limpiar todo';

  @override
  String get addedToLibrary => 'Añadido a la biblioteca';

  @override
  String get errorDuplicateIsbn => 'Ya está en la biblioteca';

  @override
  String get bookDuplicateTitle => 'Libro duplicado';

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
  String get statsEmptySubtitle =>
      'Añade widgets para ver tus hábitos de lectura, metas y récords personales.';

  @override
  String get statsAddFirstWidget => '';

  @override
  String get statsAddWidgetTitle => '';

  @override
  String get statsGoalTargetShelf => '';

  @override
  String searchFilterIsbnLabel(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String searchFilterLanguageLabel(String language) {
    return 'Idioma: $language';
  }

  @override
  String searchFilterAuthorLabel(String author) {
    return 'Autor: $author';
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
  String get statsGoalUnitBooks => 'libros';

  @override
  String get statsGoalUnitPages => '';

  @override
  String statsGoalRemaining(int count) {
    return '';
  }

  @override
  String get statsGoalCompleted => '¡Listo!';

  @override
  String get statsGoalNew => 'Nueva meta';

  @override
  String get statsGoalEdit => '';

  @override
  String get statsGoalDelete => 'Eliminar';

  @override
  String get statsGoalNameLabel => '';

  @override
  String get statsGoalTypeLabel => 'Tipo';

  @override
  String get statsGoalTypeBooks => '';

  @override
  String get statsGoalTypePages => 'Páginas leídas';

  @override
  String get statsGoalTargetLabel => '';

  @override
  String get statsGoalFromLabel => '';

  @override
  String get statsGoalToLabel => 'Hasta';

  @override
  String get statsPagesTitle => '';

  @override
  String get statsPagesSub => 'páginas leídas';

  @override
  String get statsStreakTitle => '';

  @override
  String get statsStreakSub => '';

  @override
  String get statsStatusTitle => 'ESTADOS';

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
  String get statsReadByYearTitle => 'LIBROS LEÍDOS POR AÑO';

  @override
  String get statsCollectionsTitle => '';

  @override
  String get statsLastAddedTitle => '';

  @override
  String get statsDailyReadingTitle => 'LECTURA DIARIA';

  @override
  String get statsAvgPagesTitle => 'PÁGINAS PROMEDIO';

  @override
  String get statsAvgPagesSub => '';

  @override
  String get statsOptPagesTitle => 'Páginas totales';

  @override
  String get statsOptPagesSub => '';

  @override
  String get statsOptStreakTitle => 'Racha';

  @override
  String get statsOptStreakSub => 'Días consecutivos leyendo';

  @override
  String get statsOptGoalTitle => 'Meta de lectura';

  @override
  String get statsOptGoalSub => 'Libros, estanterías o colecciones';

  @override
  String get statsOptStatusTitle => 'Estados de lectura';

  @override
  String get statsOptStatusSub => 'Libros por estado';

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
  String get statsOptReadYearSub => 'Gráfico de lectura anual';

  @override
  String get statsOptCollectionsTitle => '';

  @override
  String get statsOptCollectionsSub => '';

  @override
  String get statsOptLastAddedTitle => 'Últimos añadidos';

  @override
  String get statsOptLastAddedSub => '';

  @override
  String get statsOptAvgPagesTitle => 'Extensión promedio';

  @override
  String get statsOptAvgPagesSub => 'Páginas promedio por libro';

  @override
  String get statsOptReadListTitle => 'Lista de leídos';

  @override
  String get statsOptReadListSub => 'Libros leídos en un periodo';

  @override
  String get statsOptAvgCompletionTitle => 'Tiempo de lectura';

  @override
  String get statsOptAvgCompletionSub => 'Tiempo promedio en terminar un libro';

  @override
  String get statsOptDailyReadingTitle => 'Lectura diaria';

  @override
  String get statsOptDailyReadingSub => 'Páginas leídas por día';

  @override
  String statsAvgCompletionValue(String days) {
    return '$days días';
  }

  @override
  String get statsPeriodThisMonth => '';

  @override
  String get statsPeriodLast3Months => 'Últimos 3 meses';

  @override
  String get statsPeriodThisYear => 'Leídos este año';

  @override
  String get statsPeriodLast3Years => 'Últimos 3 años';

  @override
  String get tabMore => 'más';

  @override
  String get sortTitle => 'Ordenar';

  @override
  String get openSettings => '';

  @override
  String get permissionRequired => '';

  @override
  String get paginationMarkersAndIndices => 'Secciones y marcadores';

  @override
  String get paginationSaveProgress => 'Guardar Progreso';

  @override
  String get paginationAllPagesAssigned =>
      'Todas las páginas ya han sido asignadas.';

  @override
  String get paginationChooseColor => 'Elegir color';

  @override
  String paginationSegmentRequired(Object index) {
    return 'Segmento $index: Todos los campos de página son obligatorios.';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return 'Segmento $index: El inicio no puede ser mayor que el fin.';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return 'Segmento $index: Los valores exceden el total de páginas ($total).';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return 'El segmento $index1 se solapa con el segmento $index2';
  }

  @override
  String get paginationAdvancedConfig => 'Configuración avanzada';

  @override
  String get paginationBlocksSegments => 'BLOQUES / SEGMENTOS';

  @override
  String get paginationNoSegmentsDefined =>
      'No hay segmentos definidos. Se usa el rango 1-N por defecto.';

  @override
  String get paginationAddBlock => 'Añadir bloque';

  @override
  String get paginationAllPagesAssignedNote =>
      'Nota: Ya has asignado todas las páginas disponibles.';

  @override
  String paginationPagesRemainingWarning(int count) {
    return 'Aviso: Quedan $count páginas físicas sin asignar.';
  }

  @override
  String get paginationPhysicalTotalNote =>
      'Nota: El total de páginas se refiere a las páginas físicas del libro (hojas totales).';

  @override
  String get paginationCorrectErrors => 'CORRIJA LOS SIGUIENTES ERRORES:';

  @override
  String get paginationMarkersLabels => 'MARCADORES / ETIQUETAS';

  @override
  String get paginationMarkerDefaultName => 'Marcador';

  @override
  String get paginationSegmentsDefaultName => 'Bloque';

  @override
  String get paginationAddMarker => 'Añadir marcador';

  @override
  String get paginationLabelOptional => 'Etiqueta (opcional)';

  @override
  String get paginationType => 'Tipo:';

  @override
  String get paginationArabic => 'Arábigo';

  @override
  String get paginationRoman => 'Romano';

  @override
  String get paginationOffset => 'Offset';

  @override
  String get paginationMarkerLabel => 'Etiqueta del marcador';

  @override
  String get paginationVisualPage => 'Página Visual';

  @override
  String get paginationVisualPageHint => 'Ej: xiv o 501';

  @override
  String paginationPhysicalLabel(Object page) {
    return 'Física: $page';
  }

  @override
  String get paginationAdjustsAutomatically => 'Se ajusta automáticamente';

  @override
  String get paginationVisualMode => 'Modo visual';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return 'Equivale a físicas: $start - $end';
  }

  @override
  String paginationSectionLabel(int index) {
    return 'Sección $index';
  }

  @override
  String paginationProgress(String current, String total) {
    return '$current / $total';
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
  String get paginationCurrentPageShort => 'Pág.';

  @override
  String get paginationStartPhysical => 'Inicio (Físico)';

  @override
  String get paginationEndPhysical => 'Fin (Físico)';

  @override
  String get paginationStartVisual => 'Inicio (Visual)';

  @override
  String get paginationEndVisual => 'Fin (Visual)';

  @override
  String get paginationAdvancedButton => 'Avanzada';

  @override
  String get unknownAuthor => 'Desconocido';

  @override
  String get storagePermissionExplanation => '';

  @override
  String get cameraPermissionExplanation =>
      'Para hacer una foto necesitas conceder acceso a la cámara. Puedes hacerlo desde los ajustes de la aplicación.';
}
