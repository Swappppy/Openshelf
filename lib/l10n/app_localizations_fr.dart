// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => '';

  @override
  String errorPrefix(String message) {
    return '';
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
  String get libraryAddFirstBook => 'Añadir primer libro';

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
    return '$count libros';
  }

  @override
  String get filterTagsLabel => '';

  @override
  String get done => '';

  @override
  String get loading => 'Cargando...';

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
  String get scanIsbnTextSubtitle => 'Apunta al número impreso';

  @override
  String get scanIsbnSelect => 'Toca un ISBN para seleccionarlo';

  @override
  String get scanOcrHoldMessage => 'Mantén la imagen unos segundos...';

  @override
  String get scanBarcodePermission =>
      'Se requiere permiso de cámara para escanear códigos';

  @override
  String get scanBatch => '';

  @override
  String get scanBatchSubtitle => '';

  @override
  String get scanModeBarcode => 'Código de barras';

  @override
  String get scanModeIsbn => 'Número ISBN';

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
  String get fieldDescription => 'Sinopsis';

  @override
  String get fieldIsbn => '';

  @override
  String get fieldLanguage => 'Idioma';

  @override
  String get fieldTranslator => 'Traducción';

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
  String pageProgress(int current, int total, String percent) {
    return '';
  }

  @override
  String pageProgressShort(int current, int total) {
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
  String get shelfWantToRead => '';

  @override
  String get shelfAbandoned => '';

  @override
  String get shelfPaused => 'Pausados';

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
  String get managementCategoryCount => 'Nº de libros';

  @override
  String get managementImprints => '';

  @override
  String get managementCollections => '';

  @override
  String get managementCategoryCloudCurve => 'Curva algorítmica (Libros)';

  @override
  String get tagNone => '';

  @override
  String get tagNoneSubtitle =>
      'Las categorías te ayudan a encontrar libros y a construir un mapa mental de tu biblioteca';

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
  String get collectionNoneSubtitle => 'Crea colecciones y organiza tus libros';

  @override
  String get collectionsAddFirst => 'Nueva colección';

  @override
  String get collectionDeleteTitle => '';

  @override
  String collectionDeleteConfirm(String name) {
    return '';
  }

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Openshelf';

  @override
  String get onboardingWelcomeSub => 'Tu biblioteca personal, reimaginada';

  @override
  String get onboardingOrganizeTitle => 'Organiza tu mundo';

  @override
  String get onboardingOrganizeSub =>
      'Crea estanterías inteligentes y colecciones temáticas';

  @override
  String get onboardingProgressTitle => 'Sigue tu progreso';

  @override
  String get onboardingProgressSub =>
      'Metas de lectura y estadísticas detalladas';

  @override
  String get onboardingAddTitle => 'Añade al instante';

  @override
  String get onboardingAddSub => 'Escanea códigos de barras o busca en la nube';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Empezar ahora';

  @override
  String get settingsApplyIcon => 'Aplicar cambio de icono';

  @override
  String get settingsDynamicIcon => 'Icono de la app dinámico';

  @override
  String get settingsDynamicIconSub =>
      'Cambia el icono de la pantalla de inicio para que coincida con el color elegido (La app se reiniciará)';

  @override
  String get settingsLibraryColumns => 'Columnas en la biblioteca';

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
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementImport => 'Importar libros';

  @override
  String get dataManagementExport => 'Exportar libros';

  @override
  String dataManagementImportHint(String source) {
    return 'Importar desde CSV de $source';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Exportar a CSV de $source';
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
  String get settingsImportBookshelfHint =>
      'Importar libros desde un archivo CSV';

  @override
  String get settingsExportCsv => 'Exportar biblioteca';

  @override
  String get settingsExportCsvHint =>
      'Exportar todos los libros a un archivo CSV';

  @override
  String get settingsFullBackup => 'Restaurar biblioteca';

  @override
  String get settingsFullBackupHint =>
      'Restaurar libros desde una copia de seguridad CSV';

  @override
  String get settingsAutoNoCoverTitle => 'Estantería sin portadas';

  @override
  String get settingsAutoNoCoverSub =>
      'Crea automáticamente una estantería si faltan portadas';

  @override
  String get noCoverShelfTitle => 'Libros sin portada';

  @override
  String get settingsCompressImagesTitle =>
      'Comprimir portadas automáticamente';

  @override
  String get settingsCompressImagesSub =>
      'Reduce el peso de las imágenes al guardarlas o importarlas';

  @override
  String get settingsBatchCompressTitle => 'Optimizar biblioteca ahora';

  @override
  String get settingsBatchCompressSub =>
      'Comprime todas las portadas existentes que no estén optimizadas';

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
  String get importRestoreCoversPrompt =>
      '¿Tienes también un archivo ZIP con las portadas para restaurar?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get devDeleteAllBooks => 'BORRAR TODOS LOS LIBROS (DEV)';

  @override
  String get settingsDevClearDbSub =>
      'Herramienta de desarrollador: limpiar base de datos';

  @override
  String get settingsDevDbCleared => 'Base de datos limpiada';

  @override
  String get settingsImportSelectBackup =>
      'Seleccionar copia de seguridad de Openshelf';

  @override
  String get settingsImportSelectCovers =>
      'Seleccionar ZIP de portadas de Openshelf';

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
    return 'Resultados de: $providers.';
  }

  @override
  String get bookSearchRecommended => 'RECOMENDADO POR OPENSHELF';

  @override
  String get bookSearchRecommendedSource => 'Recomendado por Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Open Library';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get searchTabStatus => 'Estado';

  @override
  String get searchTabImprint => 'Sello';

  @override
  String get searchTabCategory => 'Categoría';

  @override
  String get searchTabCollection => 'Colección';

  @override
  String searchFilterStatus(String value) {
    return 'Estado: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Sello: $value';
  }

  @override
  String searchFilterCategory(String value) {
    return 'Cat.: $value';
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
  String get searchSaveAsShelf => 'Guardar como estantería';

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
    return 'Ya tienes un libro con el ISBN $isbn en tu biblioteca.';
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
  String get statsAddFirstWidget => 'Añadir primer widget';

  @override
  String get statsAddWidgetTitle => 'Añadir widget';

  @override
  String get statsGoalTargetShelf => 'Estantería objetivo';

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
  String searchFilterPublisherLabel(String publisher) {
    return 'Editorial: $publisher';
  }

  @override
  String get statsGoalTitle => 'META';

  @override
  String get statsGoalFullTitle => 'META DE LECTURA';

  @override
  String get statsGoalUnitBooks => 'libros';

  @override
  String get statsGoalUnitPages => 'págs';

  @override
  String statsGoalRemaining(int count) {
    return 'Faltan $count';
  }

  @override
  String get statsGoalCompleted => '¡Listo!';

  @override
  String get statsGoalNew => 'Nueva meta';

  @override
  String get statsGoalEdit => 'Editar meta';

  @override
  String get statsGoalDelete => 'Eliminar';

  @override
  String get statsGoalNameLabel => 'Nombre (ej: Reto 2026)';

  @override
  String get statsGoalTypeLabel => 'Tipo';

  @override
  String get statsGoalTypeBooks => 'Libros leídos';

  @override
  String get statsGoalTypePages => 'Páginas leídas';

  @override
  String get statsGoalTargetLabel => 'Objetivo numérico';

  @override
  String get statsGoalFromLabel => 'Desde';

  @override
  String get statsGoalToLabel => 'Hasta';

  @override
  String get statsPagesTitle => 'PÁGINAS';

  @override
  String get statsPagesSub => 'páginas leídas';

  @override
  String get statsStreakTitle => 'RACHA';

  @override
  String get statsStreakSub => 'días seguidos';

  @override
  String get statsStatusTitle => 'ESTADOS';

  @override
  String get statsAddedTitle => 'LIBROS AÑADIDOS';

  @override
  String get statsAddedNoData => 'Sin datos';

  @override
  String get statsCategoriesTitle => 'CATEGORÍAS';

  @override
  String get statsYearsTitle => 'AÑOS DE PUBLICACIÓN';

  @override
  String get statsReadingTitle => 'LECTURA';

  @override
  String get statsReadingNowTitle => 'LEYENDO AHORA';

  @override
  String get statsReadingNone => 'Nada en lectura';

  @override
  String get statsReadByYearTitle => 'LIBROS LEÍDOS POR AÑO';

  @override
  String get statsCollectionsTitle => 'COLECCIONES';

  @override
  String get statsLastAddedTitle => 'ÚLTIMOS AÑADIDOS';

  @override
  String get statsDailyReadingTitle => 'LECTURA DIARIA';

  @override
  String get statsAvgPagesTitle => 'PÁGINAS PROMEDIO';

  @override
  String get statsAvgPagesSub => 'páginas por libro';

  @override
  String get statsOptPagesTitle => 'Páginas totales';

  @override
  String get statsOptPagesSub => 'Total de páginas leídas';

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
  String get statsOptCurrentTitle => 'Libro actual';

  @override
  String get statsOptCurrentSub => 'Progreso de lectura en curso';

  @override
  String get statsOptAddedTimeTitle => 'Libros añadidos';

  @override
  String get statsOptAddedTimeSub => 'Gráfico temporal de adquisiciones';

  @override
  String get statsOptCategoriesTitle => 'Categorías';

  @override
  String get statsOptCategoriesSub => 'Distribución por géneros';

  @override
  String get statsOptYearsTitle => 'Año de publicación';

  @override
  String get statsOptYearsSub => 'Histograma histórico';

  @override
  String get statsOptReadYearTitle => 'Leídos por año';

  @override
  String get statsOptReadYearSub => 'Gráfico de lectura anual';

  @override
  String get statsOptCollectionsTitle => 'Colecciones';

  @override
  String get statsOptCollectionsSub => 'Libros por colección';

  @override
  String get statsOptLastAddedTitle => 'Últimos añadidos';

  @override
  String get statsOptLastAddedSub => 'Recién llegados';

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
  String get statsPeriodThisMonth => 'Leídos este mes';

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
  String get openSettings => 'Abrir ajustes';

  @override
  String get permissionRequired => 'Permiso necesario';

  @override
  String get storagePermissionExplanation =>
      'Para seleccionar una portada necesitas conceder acceso al almacenamiento. Puedes hacerlo desde los ajustes de la aplicación.';

  @override
  String get cameraPermissionExplanation =>
      'Para hacer una foto necesitas conceder acceso a la cámara. Puedes hacerlo desde los ajustes de la aplicación.';
}
