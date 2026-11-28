// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

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
    return 'Error al iniciar la aplicación: $error';
  }

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navShelves => 'Estanterías';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmpty => 'Tu biblioteca está vacía';

  @override
  String get libraryEmptyHint => '¿Cuál será tu primer libro?';

  @override
  String get libraryAddFirstBook => 'Añadir primer libro';

  @override
  String get libraryNoResults => 'Sin resultados';

  @override
  String get libraryNoResultsHint => 'Prueba con otros filtros';

  @override
  String get addBook => 'Añadir libro';

  @override
  String get displaySettings => 'Mostrar en la biblioteca';

  @override
  String get displaySettingsDragHint => 'Arrastra para reordenar';

  @override
  String get settingsButton => 'Ajustes';

  @override
  String get fieldAuthor => 'Autor';

  @override
  String get fieldPublisher => 'Editorial';

  @override
  String get fieldYear => 'Año de publicación';

  @override
  String get fieldRating => 'Valoración';

  @override
  String get fieldTags => 'Etiquetas';

  @override
  String get fieldReadingProgress => 'Progreso de lectura';

  @override
  String get fieldStatusChip => 'Chip de estado';

  @override
  String get searchHint => 'Buscar por título...';

  @override
  String get filterAuthor => 'Autor';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Editorial';

  @override
  String get filterCollection => 'Colección';

  @override
  String get filterImprintLabel => 'Sello editorial';

  @override
  String imprintBookCount(int count) {
    return '$count libros';
  }

  @override
  String get filterTagsLabel => 'Categorías';

  @override
  String get done => 'Hecho';

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
  String exportSaveSuccess(String path) {
    return 'Copia de seguridad guardada en $path';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get create => 'Crear';

  @override
  String get edit => 'Editar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get photo => 'Foto';

  @override
  String get url => 'URL';

  @override
  String get download => 'Descargar';

  @override
  String get retry => 'Reintentar';

  @override
  String get share => 'Compartir';

  @override
  String get saveToDevice => 'Guardar en dispositivo';

  @override
  String get addBookModalTitle => 'Añadir libro';

  @override
  String get addBookModalSubtitle => 'Elige cómo quieres añadir tu libro';

  @override
  String get addManually => 'Añadir manualmente';

  @override
  String get addManuallySubtitle => 'Rellena los datos tú mismo';

  @override
  String get searchBook => 'Buscar libro';

  @override
  String get searchBookSubtitle => 'Por título, autor o ISBN';

  @override
  String get scanBarcode => 'Escanear código de barras';

  @override
  String get scanBarcodeSubtitle => 'Apunta la cámara al ISBN';

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
  String get scanBatch => 'Escanear en lote';

  @override
  String get scanBatchSubtitle => 'Escanea varios libros seguidos';

  @override
  String get searchHistoryTitle => 'Historial de búsquedas y escaneos';

  @override
  String get searchHistorySubtitle =>
      'Ver búsquedas pasadas y escaneos fallidos u offline';

  @override
  String get searchHistoryEmpty =>
      'No hay historial de búsquedas o escaneos aún';

  @override
  String get searchHistoryClear => 'Borrar historial';

  @override
  String get searchHistoryTypeBarcode => 'Escaneo de código de barras';

  @override
  String get searchHistoryTypeBatch => 'Escaneo en lote';

  @override
  String get searchHistoryTypeText => 'Búsqueda de texto';

  @override
  String get searchHistoryStatusSuccess => 'ÉXITO';

  @override
  String get searchHistoryStatusFailed => 'FALLIDO';

  @override
  String get searchHistoryStatusPending => 'PENDIENTE';

  @override
  String get searchHistorySaved => 'Guardado en el historial';

  @override
  String get scanModeBarcode => 'Código de barras';

  @override
  String get scanModeIsbn => 'Número ISBN';

  @override
  String get bookFormNewTitle => 'Nuevo libro';

  @override
  String get bookFormEditTitle => 'Editar libro';

  @override
  String get tabMain => 'Principal';

  @override
  String get tabDetails => 'Detalles';

  @override
  String get fieldTitle => 'Título';

  @override
  String get fieldSubtitle => 'Subtítulo';

  @override
  String get fieldDescription => 'Sinopsis';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Idioma';

  @override
  String get fieldIsTranslation => '¿Es una traducción?';

  @override
  String get fieldOriginalTitle => 'Título original';

  @override
  String get fieldOriginalLanguage => 'Idioma original';

  @override
  String get fieldTranslator => 'Traductor';

  @override
  String get fieldReads => 'Lecturas';

  @override
  String get fieldCopies => 'Copias';

  @override
  String get fieldTotalPages => 'Páginas totales';

  @override
  String get fieldTotalBooks => 'Libros totales';

  @override
  String get fieldCurrentPage => 'Página actual';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldCollection => 'Colección / Serie';

  @override
  String get fieldCollectionNumber => 'Número en la colección';

  @override
  String get sectionBasicInfo => 'Información básica';

  @override
  String get sectionCategories => 'Categorías';

  @override
  String get sectionReadingStatus => 'Estado de lectura';

  @override
  String get sectionFormat => 'Formato';

  @override
  String get sectionRating => 'Valoración';

  @override
  String get sectionImprint => 'Sello editorial';

  @override
  String get coverPickPhoto => 'Foto';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Buscar';

  @override
  String get coverUrlDialogTitle => 'URL de la portada';

  @override
  String get coverUrlHint => 'https://ejemplo.com/portada.jpg';

  @override
  String get coverDownloadError => 'No se pudo descargar la imagen';

  @override
  String get imageProcessError => 'No se pudo procesar la imagen';

  @override
  String get imageProcessing => 'Procesando imagen...';

  @override
  String get imagePreparing => 'Preparando imagen...';

  @override
  String get imageOptimizing => 'Optimizando imagen...';

  @override
  String get cropCoverTitle => 'Recortar portada';

  @override
  String get cropImprintTitle => 'Recortar sello';

  @override
  String get tagSearchOrCreate => 'Buscar o crear categoría';

  @override
  String get tagCreateHint => 'Escribe y pulsa Enter para añadir o crear';

  @override
  String get tagNoCategories => 'No hay categorías creadas todavía';

  @override
  String get imprintSearch => 'Buscar sello editorial';

  @override
  String get requiredField => 'Campo obligatorio';

  @override
  String get statusWantToRead => 'Por leer';

  @override
  String get statusReading => 'Leyendo';

  @override
  String get statusRead => 'Leído';

  @override
  String get statusAbandoned => 'Abandonado';

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
  String get formatPaperback => 'Tapa blanda';

  @override
  String get formatHardcover => 'Tapa dura';

  @override
  String get formatLeatherbound => 'Piel';

  @override
  String get formatRustic => 'Rústica';

  @override
  String get formatDigital => 'Digital';

  @override
  String get formatOther => 'Otro';

  @override
  String get bookDetailNotFound => 'Libro no encontrado';

  @override
  String get bookDetailPagePickerTitle => 'Página actual';

  @override
  String get bookDetailNotesTitle => 'Notas personales';

  @override
  String get bookDetailNotesHint => 'Escribe tus notas aquí...';

  @override
  String get bookDetailNotesEmpty => 'Toca para añadir notas...';

  @override
  String get bookDetailDeleteTitle => 'Eliminar libro';

  @override
  String bookDetailDeleteConfirm(String title) {
    return '¿Eliminar \"$title\"? Esta acción no se puede deshacer.';
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
  String get bookDetailFieldPages => 'PÁGINAS';

  @override
  String get bookDetailFieldCategories => 'CATEGORÍAS';

  @override
  String get bookDetailFieldFormat => 'Formato';

  @override
  String get bookDetailFieldRating => 'VALORACIÓN';

  @override
  String get bookDetailFieldImprintSection => 'SELLO EDITORIAL';

  @override
  String get bookDetailFieldPersonalNotes => 'NOTAS PERSONALES';

  @override
  String get bookDetailFieldAdded => 'Añadido';

  @override
  String get bookDetailFieldStarted => 'Inicio lectura';

  @override
  String get bookDetailFieldFinished => 'Fin lectura';

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
    return '$current / $total págs · $percent%';
  }

  @override
  String pageProgressShort(String current, String total) {
    return '$current / $total';
  }

  @override
  String pageSuffix(int count) {
    return '$count págs.';
  }

  @override
  String get pagesLabel => 'páginas';

  @override
  String get shelvesTitle => 'Estanterías';

  @override
  String get shelvesSectionByStatus => 'Por estado';

  @override
  String get shelvesSectionMine => 'Estanterías';

  @override
  String get shelvesSectionManagement => 'Gestión';

  @override
  String get shelfAllBooks => 'Todos los libros';

  @override
  String get shelfReading => 'Leyendo';

  @override
  String get shelfRead => 'Leídos';

  @override
  String booksReadProgress(int readCount, int totalCount) {
    return '$readCount / $totalCount libros leídos';
  }

  @override
  String get shelfWantToRead => 'Por leer';

  @override
  String get shelfAbandoned => 'Abandonados';

  @override
  String get shelfPaused => 'Pausados';

  @override
  String get shelfNewTooltip => 'Nueva estantería';

  @override
  String get shelfEmpty => 'No tienes estanterías personalizadas';

  @override
  String get shelfEmptySubtitle => 'Organiza tus lecturas como quieras';

  @override
  String get shelvesAddFirstShelf => 'Crear estantería';

  @override
  String get shelfBooksEmpty => 'Esta estantería está vacía';

  @override
  String get shelfBooksEmptyHint =>
      'Los libros que coincidan con sus filtros aparecerán aquí.';

  @override
  String get shelfStatusBooksEmpty => 'No hay libros aquí';

  @override
  String get shelfFormNew => 'Nueva estantería';

  @override
  String get shelfFormEdit => 'Editar estantería';

  @override
  String get shelfFormNameLabel => 'Nombre de la estantería';

  @override
  String get collectionNameLabel => 'Nombre de la colección';

  @override
  String get shelfFormSectionStatus => 'Estado de lectura';

  @override
  String get shelfFormSectionTitle => 'Título';

  @override
  String get shelfFormSectionAuthor => 'Autor';

  @override
  String get shelfFormSectionPublisher => 'Editorial';

  @override
  String get shelfFormSectionIsbn => 'ISBN';

  @override
  String get shelfFormSectionCollection => 'Colección';

  @override
  String get shelfFormSectionCategories => 'Categorías';

  @override
  String get shelfFormSectionImprint => 'Sello editorial';

  @override
  String get shelfFormHintTitle => 'Buscar en título';

  @override
  String get shelfFormHintAuthor => 'Nombre del autor';

  @override
  String get shelfFormHintPublisher => 'Nombre de la editorial';

  @override
  String get shelfFormHintIsbn => 'ISBN';

  @override
  String get shelfFormHintCollection => 'Nombre de la colección';

  @override
  String get shelfFormStatusAny => 'Cualquiera';

  @override
  String get shelfOptionEdit => 'Editar estantería';

  @override
  String get shelfOptionDelete => 'Eliminar';

  @override
  String get shelfStatusLabelReading => 'Leyendo';

  @override
  String get shelfStatusLabelRead => 'Leídos';

  @override
  String get shelfStatusLabelWantToRead => 'Por leer';

  @override
  String get shelfStatusLabelAbandoned => 'Abandonados';

  @override
  String get shelfStatusLabelPaused => 'Pausados';

  @override
  String get managementCategories => 'Categorías';

  @override
  String get managementCategoryCount => 'Nº de libros';

  @override
  String get managementImprints => 'Sellos';

  @override
  String get managementCollections => 'Colecciones';

  @override
  String get managementCategoryCloudCurve => 'Curva algorítmica (Libros)';

  @override
  String get tagNone => 'No hay categorías todavía';

  @override
  String get tagNoneSubtitle =>
      'Las categorías te ayudan a encontrar libros y a construir un mapa mental de tu biblioteca';

  @override
  String get categoriesAddFirst => 'Nueva categoría';

  @override
  String get tagNew => 'Nueva categoría';

  @override
  String get tagNewDialogTitle => 'Nueva categoría';

  @override
  String get tagNameLabel => 'Nombre';

  @override
  String get tagColorLabel => 'Color';

  @override
  String get tagDeleteTitle => 'Eliminar categoría';

  @override
  String tagDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get imprintNone => 'No hay sellos todavía';

  @override
  String get imprintNoneSubtitle =>
      'Agrupa tus libros por editoriales o sus sellos';

  @override
  String get imprintsAddFirst => 'Añadir sello';

  @override
  String get imprintNew => 'Nuevo sello';

  @override
  String get imprintNewDialogTitle => 'Nuevo sello editorial';

  @override
  String get imprintEditDialogTitle => 'Editar sello';

  @override
  String get imprintNameLabel => 'Nombre del sello';

  @override
  String get imprintAddImageHint => 'Pulsa para añadir imagen';

  @override
  String get imprintChangeImageHint => 'Pulsa para cambiar imagen';

  @override
  String get imprintUrlDialogTitle => 'URL de la imagen';

  @override
  String get imprintUrlHint => 'https://ejemplo.com/sello.jpg';

  @override
  String get imprintDeleteTitle => 'Eliminar sello';

  @override
  String imprintDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get imprintNoImprints => 'No hay sellos creados';

  @override
  String get collectionNone => 'No hay colecciones todavía';

  @override
  String get collectionNoneSubtitle => 'Crea colecciones y organiza tus libros';

  @override
  String get collectionsAddFirst => 'Nueva colección';

  @override
  String get collectionDeleteTitle => 'Eliminar colección';

  @override
  String collectionDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
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
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema (automático)';

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
  String get settingsLanguageRussian => 'Ruso';

  @override
  String get settingsThemeMode => 'Modo de tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsAccentColor => 'Color de acento';

  @override
  String get settingsAccentColorHint => 'Toca un color para aplicarlo';

  @override
  String get settingsSectionStorage => 'Almacenamiento';

  @override
  String get settingsCoversFolder => 'Carpeta de portadas';

  @override
  String get settingsDatabase => 'Base de datos';

  @override
  String get settingsDefaultDir => 'Directorio por defecto';

  @override
  String get settingsDbMoveTitle => 'Mover base de datos';

  @override
  String get settingsDbMoveContent =>
      'Mover la base de datos requiere reiniciar la app. Los datos se copiarán al nuevo directorio. ¿Continuar?';

  @override
  String get settingsDbMoveConfirm => 'Mover y reiniciar';

  @override
  String get settingsSectionSearch => 'Búsqueda de libros';

  @override
  String get settingsSearchServer => 'Servidor';

  @override
  String get settingsSearchServerHint =>
      'Se usará para buscar libros por ISBN o título';

  @override
  String get settingsSectionData => 'Gestión de datos';

  @override
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => 'Importar libros';

  @override
  String get dataManagementExport => 'Exportar libros';

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
  String get settingsAllFilesAccess => 'Acceso a todos los archivos';

  @override
  String get settingsAllFilesAccessSub =>
      'Necesario para mover la base de datos a carpetas externas (Android 11+)';

  @override
  String get settingsAllFilesAccessInfo =>
      'Este permiso permite a Openshelf gestionar archivos fuera de su directorio privado. Es necesario para mover la base de datos a una carpeta personalizada. Nota: Es posible que la aplicación se cierre automáticamente al conceder este permiso.';

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
  String get settingsApiKeyTitle => 'Google Books API key';

  @override
  String get settingsApiKeyConfigured =>
      'Clave configurada. Google Books está disponible.';

  @override
  String get settingsApiKeyMissing =>
      'Sin clave, Google Books usará Open Library como alternativa.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Mostrar';

  @override
  String get settingsApiKeyHide => 'Ocultar';

  @override
  String get settingsApiKeySave => 'Guardar clave';

  @override
  String get settingsApiKeySaved => 'Clave guardada';

  @override
  String get settingsApiKeyClear => 'Borrar clave';

  @override
  String get settingsApiKeyHowTo => 'Cómo obtenerla';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'Cómo obtener una clave de Google Books';

  @override
  String get settingsApiKeyStep1 =>
      'Abre console.cloud.google.com e inicia sesión con tu cuenta de Google.';

  @override
  String get settingsApiKeyStep2 =>
      'Crea un proyecto nuevo (el nombre es indiferente).';

  @override
  String get settingsApiKeyStep3 =>
      'Ve a APIs y servicios → Biblioteca, busca \"Books API\" y actívala.';

  @override
  String get settingsApiKeyStep4 =>
      'Ve a APIs y servicios → Credenciales → Crear credenciales → Clave de API.';

  @override
  String get settingsApiKeyStep5 =>
      'Opcional pero recomendado: restringe la clave a la Books API únicamente.';

  @override
  String get settingsApiKeyStep6 =>
      'Copia la clave resultante (empieza por \"AIza…\") y pégala en el campo de arriba.';

  @override
  String get settingsApiKeyNote =>
      'La clave es gratuita y permite hasta 1.000 búsquedas diarias. No se comparte con nadie: se guarda solo en este dispositivo.';

  @override
  String get bookSearchHint => 'Título, autor o ISBN...';

  @override
  String get bookSearchPrompt => 'Busca por título, autor o ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Sin resultados para \"$query\"';
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
  String get bookSearchServerAnnasArchive => 'Anna\'s Archive';

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
  String get bookSearchErrorNoApiKey =>
      'Google Books requiere una clave de API.\nConfigúrala en Ajustes → Búsqueda de libros.';

  @override
  String get bookSearchErrorRateLimit =>
      'Google Books ha limitado las peticiones.\nEspera un momento e inténtalo de nuevo.';

  @override
  String get bookSearchErrorNetwork =>
      'No se pudo conectar con ningún servidor.\nComprueba tu conexión e inténtalo de nuevo.';

  @override
  String get coverPickerTitle => 'Portadas';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults =>
      'No se encontraron portadas para este libro.';

  @override
  String get coverPickerNetworkError =>
      'No se pudo conectar. Comprueba tu conexión.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsPlaceholder => 'Tus estadísticas aparecerán aquí';

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
  String searchFilterSubtitleLabel(String subtitle) {
    return 'Subtítulo: $subtitle';
  }

  @override
  String searchFilterTranslatorLabel(String translator) {
    return 'Traductor: $translator';
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
  String statsAvgCompletionValue(int days) {
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
  String get paginationRestartFromZero => 'Empezar desde 0 en modo visual';

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
  String get storagePermissionExplanation =>
      'Para seleccionar una portada necesitas conceder acceso al almacenamiento. Puedes hacerlo desde los ajustes de la aplicación.';

  @override
  String get cameraPermissionExplanation =>
      'Para hacer una foto necesitas conceder acceso a la cámara. Puedes hacerlo desde los ajustes de la aplicación.';

  @override
  String get settingsAutoPruneTagsTitle => 'Limpiar categorías huérfanas';

  @override
  String get settingsAutoPruneTagsSub =>
      'Elimina automáticamente las categorías que no se usan en ningún libro';

  @override
  String get settingsExcludedPruneTagsTitle => 'Categorías excluidas';

  @override
  String settingsExcludedPruneTagsSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categorías protegidas',
      one: '1 categoría protegida',
      zero: 'Sin categorías excluidas',
    );
    return '$_temp0';
  }

  @override
  String get settingsPruneWarningTitle => 'Categorías huérfanas detectadas';

  @override
  String get settingsPruneWarningContent =>
      'Activar esta opción eliminará las siguientes categorías porque no se usan en ningún libro. ¿Quieres continuar?';

  @override
  String get settingsAutomationTitle => 'Automatización';

  @override
  String get removeFromCollection => 'Eliminar de la colección';

  @override
  String get removeFromImprint => 'Eliminar del sello';

  @override
  String get removeFromCategory => 'Eliminar de la categoría';

  @override
  String get workEditionsEmpty =>
      'No se pudieron cargar ediciones adicionales.';

  @override
  String get workEditionsUseGeneral => 'Usar metadatos generales';

  @override
  String workEditionsCount(int count) {
    return '$count ed.';
  }

  @override
  String get settingsLanguageGerman => 'Alemán';

  @override
  String bulkSelectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get bulkActionEdit => 'Editar masivamente';

  @override
  String get bulkActionDuplicate => 'Duplicar';

  @override
  String get bulkActionDelete => 'Eliminar';

  @override
  String get bulkDeleteTitle => 'Eliminar libros';

  @override
  String bulkDeleteConfirm(int count) {
    return '¿Eliminar los $count libros seleccionados? Esta acción no se puede deshacer.';
  }

  @override
  String bulkEditTitle(int count) {
    return 'Editar $count libros';
  }

  @override
  String bulkEditSaveSuccess(int count) {
    return 'Se han actualizado $count libros';
  }

  @override
  String bulkDuplicateSuccess(int count) {
    return 'Se han duplicado $count libros';
  }

  @override
  String bulkDeleteSuccess(int count) {
    return 'Se han eliminado $count libros';
  }

  @override
  String get padlockLockedHint => 'Campo bloqueado (sin cambios)';

  @override
  String get padlockUnlockedHint => 'Campo desbloqueado (se aplicará a todos)';

  @override
  String get bulkNotesMode => 'Modo de notas';

  @override
  String get bulkNotesModeOverwrite => 'Reemplazar nota existente';

  @override
  String get bulkNotesModeAppend => 'Añadir al final de la nota';

  @override
  String get bulkEditNoFieldsUnlocked =>
      'Desbloquea al menos un campo para aplicar cambios';

  @override
  String get authorMultiHelpTitle => 'Múltiples autores';

  @override
  String get authorMultiHelpContent =>
      'Puedes indicar múltiples autores separándolos con punto y coma (;), barra (/) o coma (,). El autocompletado te sugerirá nombres individuales para cada autor.';

  @override
  String get translatorMultiHelpTitle => 'Múltiples traductores';

  @override
  String get translatorMultiHelpContent =>
      'Puedes indicar múltiples traductores separándolos con punto y coma (;), barra (/) o coma (,). El autocompletado te sugerirá nombres individuales para cada traductor.';

  @override
  String get narratorMultiHelpTitle => 'Múltiples narradores';

  @override
  String get narratorMultiHelpContent =>
      'Puedes indicar múltiples narradores separándolos con punto y coma (;), barra (/) o coma (,). El autocompletado te sugerirá nombres individuales para cada narrador.';

  @override
  String get padlockResetTitle => '¿Bloquear campo?';

  @override
  String get padlockResetContent =>
      'Se perderán los cambios introducidos en este campo. ¿Deseas continuar?';

  @override
  String get storageDbMoveSuccess =>
      'Base de datos movida correctamente. Reiniciando la aplicación...';

  @override
  String get storageDbErrorNotWritable =>
      'No se puede escribir en la carpeta seleccionada. Prueba con otra ubicación.';

  @override
  String get storageDbErrorNeedsAllFiles =>
      'No se puede escribir en la carpeta seleccionada. En Android 11 o superior, activa «Acceso a todos los archivos» en los ajustes de almacenamiento para usar carpetas externas.';

  @override
  String get storageDbErrorSameFolder =>
      'La base de datos ya está en la carpeta seleccionada.';

  @override
  String get storageDbErrorSourceMissing =>
      'No se ha encontrado el archivo de la base de datos actual.';

  @override
  String get storageDbErrorCloseFailed =>
      'No se pudo cerrar la base de datos de forma segura. No se ha movido nada; inténtalo de nuevo.';

  @override
  String get storageDbErrorCopyFailed =>
      'Error al copiar la base de datos. Tus datos no han cambiado. Reiniciando la aplicación...';

  @override
  String storageCoversMoved(int count) {
    return 'Portadas movidas: $count';
  }

  @override
  String get dbMissingTitle => 'Biblioteca no encontrada';

  @override
  String dbMissingBody(String path) {
    return 'No se encontró la base de datos de la biblioteca en la carpeta personalizada:\n$path\n\nSi está en un almacenamiento extraíble, conéctalo y reintenta. También puedes volver a la ubicación predeterminada; allí se abrirá la biblioteca existente o se creará una vacía.';
  }

  @override
  String get dbMissingUseDefault => 'Usar ubicación predeterminada';

  @override
  String get bookFormFinishDateRequired =>
      'La fecha de finalización es obligatoria cuando el libro está marcado como Leído';

  @override
  String get ownershipEventDeleteConfirm =>
      '¿Eliminar esta entrada del historial de propiedad?';

  @override
  String get mediaTypeReading => 'Lectura';

  @override
  String get mediaTypeAudio => 'Audio';

  @override
  String get mediaTypeBoth => 'Ambos';

  @override
  String get fieldNarrator => 'Narrador';

  @override
  String get fieldPlatform => 'Plataforma';

  @override
  String get fieldDuration => 'Duración total';

  @override
  String get fieldAudioPosition => 'Posición actual';

  @override
  String get durationInvalid => 'Usa hh:mm o un número de horas';

  @override
  String get audioPositionBeyondDuration =>
      'La posición supera la duración total';

  @override
  String get audioProgressTitle => 'Progreso de escucha';

  @override
  String get audioDurationMissing =>
      'Indica la duración total en la ficha del libro para registrar el progreso';

  @override
  String audioProgress(String current, String total, String percent) {
    return '$current / $total · $percent%';
  }

  @override
  String get fieldAudioPublisher => 'Editorial del audio';

  @override
  String get fieldAudioIdentifier => 'ISBN / ASIN del audio';

  @override
  String get mixedStartTitle => '¿Dónde empiezas?';

  @override
  String get mixedStartPage => 'Página de inicio';

  @override
  String get mixedStartPosition => 'Posición de inicio';

  @override
  String mixedLastAudio(String position) {
    return 'Último audio: $position';
  }

  @override
  String mixedLastPage(String page) {
    return 'Última página leída: $page';
  }

  @override
  String get mixedOverlapWarning =>
      'Empiezas antes de donde lo dejaste en este medio: ese tramo se contará una sola vez.';

  @override
  String get mixedSkip => 'Seguir donde lo dejé';

  @override
  String get mixedContinue => 'Continuar';

  @override
  String get mixedInvalidPage => 'Introduce una página válida';

  @override
  String get mixedSuggested => 'Estimación según las secciones';

  @override
  String get audioAnchorStart => 'Inicio en audio';

  @override
  String get audioAnchorEnd => 'Fin en audio';

  @override
  String get audioAnchorMarker => 'Posición en audio';

  @override
  String get audioSectionStart => 'Inicio';

  @override
  String get audioSectionEnd => 'Fin';

  @override
  String get audioSectionsButton => 'Secciones';

  @override
  String get fieldMediaType => 'Tipo de medio';

  @override
  String get statsListeningTitle => 'ESCUCHA';

  @override
  String get statsListeningSub => 'tiempo escuchado';

  @override
  String get statsDailyListeningTitle => 'ESCUCHA DIARIA';

  @override
  String get statsOptListeningTitle => 'Tiempo escuchado';

  @override
  String get statsOptListeningSub => 'Total de horas de audiolibro escuchadas';

  @override
  String get statsOptDailyListeningTitle => 'Escucha diaria';

  @override
  String get statsOptDailyListeningSub => 'Horas escuchadas por día';

  @override
  String get statsGoalTypeListening => 'Horas escuchadas';

  @override
  String get statsGoalTargetTimeLabel => 'Objetivo (hh:mm o horas)';

  @override
  String statsGoalRemainingTime(String time) {
    return 'Faltan $time';
  }

  @override
  String get statsHeatmapTitle => 'ACTIVIDAD';

  @override
  String get statsOptHeatmapTitle => 'Mapa de actividad';

  @override
  String get statsOptHeatmapSub => 'Calendario de días de lectura y escucha';

  @override
  String get statsHeatmapAll => 'Todo';

  @override
  String get statsHeatmapPages => 'Páginas';

  @override
  String get statsHeatmapListening => 'Escucha';

  @override
  String statsHeatmapActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días activos',
      one: '1 día activo',
    );
    return '$_temp0';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => '';

  @override
  String errorPrefix(String message) {
    return '';
  }

  @override
  String errorGeneric(String error) {
    return '';
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
  String get searchHistoryTitle => '';

  @override
  String get searchHistorySubtitle => '';

  @override
  String get searchHistoryEmpty => '';

  @override
  String get searchHistoryClear => '';

  @override
  String get searchHistoryTypeBarcode => '';

  @override
  String get searchHistoryTypeBatch => '';

  @override
  String get searchHistoryTypeText => '';

  @override
  String get searchHistoryStatusSuccess => '';

  @override
  String get searchHistoryStatusFailed => '';

  @override
  String get searchHistoryStatusPending => '';

  @override
  String get searchHistorySaved => '';

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
  String get imageProcessing => '';

  @override
  String get imagePreparing => '';

  @override
  String get imageOptimizing => '';

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
    return '';
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
  String get shelfBooksEmptyHint => '';

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
  String get settingsLanguageFrench => '';

  @override
  String get settingsLanguageItalian => '';

  @override
  String get settingsLanguageCatalan => '';

  @override
  String get settingsLanguagePortuguese => '';

  @override
  String get settingsLanguagePortugueseBR => '';

  @override
  String get settingsLanguageRussian => '';

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
  String get settingsAllFilesAccess => '';

  @override
  String get settingsAllFilesAccessSub => '';

  @override
  String get settingsAllFilesAccessInfo => '';

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
  String get bookSearchServerAnnasArchive => '';

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
    return '';
  }

  @override
  String searchFilterTranslatorLabel(String translator) {
    return '';
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
  String statsAvgCompletionValue(int days) {
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
  String get paginationRestartFromZero => '';

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
  String get searchModeBasic => '';

  @override
  String get searchModeAdvanced => '';

  @override
  String get searchModeBoolean => '';

  @override
  String get searchAddCondition => '';

  @override
  String get searchPreview => '';

  @override
  String get searchFieldTitle => '';

  @override
  String get searchFieldAuthor => '';

  @override
  String get searchFieldPublisher => '';

  @override
  String get searchFieldIsbn => '';

  @override
  String get searchFieldLanguage => '';

  @override
  String get searchFieldOriginalTitle => '';

  @override
  String get searchFieldOriginalLanguage => '';

  @override
  String get searchFieldYear => '';

  @override
  String get searchFieldPages => '';

  @override
  String get searchFieldStatus => '';

  @override
  String get searchFieldCategory => '';

  @override
  String get searchFieldImprint => '';

  @override
  String get searchFieldCollection => '';

  @override
  String get searchFieldNoCover => '';

  @override
  String get searchFieldNotes => '';

  @override
  String get searchFieldHasNotes => '';

  @override
  String get searchOpContains => '';

  @override
  String get searchOpExactly => '';

  @override
  String get searchOpStartsWith => '';

  @override
  String get searchOpIncludes => '';

  @override
  String get searchOpNotIncludes => '';

  @override
  String get searchOpIncludesAll => '';

  @override
  String get searchOpEquals => '';

  @override
  String get searchOpNotEquals => '';

  @override
  String get searchOpGreaterThan => '';

  @override
  String get searchOpLessThan => '';

  @override
  String get searchOpBetween => '';

  @override
  String get searchOpIs => '';

  @override
  String get searchOpIsNot => '';

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
  String get settingsAutoPruneTagsTitle => '';

  @override
  String get settingsAutoPruneTagsSub => '';

  @override
  String get settingsExcludedPruneTagsTitle => '';

  @override
  String settingsExcludedPruneTagsSub(int count) {
    return '';
  }

  @override
  String get settingsPruneWarningTitle => '';

  @override
  String get settingsPruneWarningContent => '';

  @override
  String get settingsAutomationTitle => '';

  @override
  String get removeFromCollection => '';

  @override
  String get removeFromImprint => '';

  @override
  String get removeFromCategory => '';

  @override
  String get workEditionsEmpty => '';

  @override
  String get workEditionsUseGeneral => '';

  @override
  String workEditionsCount(int count) {
    return '';
  }

  @override
  String get settingsLanguageGerman => '';

  @override
  String bulkSelectionCount(int count) {
    return '';
  }

  @override
  String get bulkActionEdit => '';

  @override
  String get bulkActionDuplicate => '';

  @override
  String get bulkActionDelete => '';

  @override
  String get bulkDeleteTitle => '';

  @override
  String bulkDeleteConfirm(int count) {
    return '';
  }

  @override
  String bulkEditTitle(int count) {
    return '';
  }

  @override
  String bulkEditSaveSuccess(int count) {
    return '';
  }

  @override
  String bulkDuplicateSuccess(int count) {
    return '';
  }

  @override
  String bulkDeleteSuccess(int count) {
    return '';
  }

  @override
  String get padlockLockedHint => '';

  @override
  String get padlockUnlockedHint => '';

  @override
  String get bulkNotesMode => '';

  @override
  String get bulkNotesModeOverwrite => '';

  @override
  String get bulkNotesModeAppend => '';

  @override
  String get bulkEditNoFieldsUnlocked => '';

  @override
  String get authorMultiHelpTitle => '';

  @override
  String get authorMultiHelpContent => '';

  @override
  String get translatorMultiHelpTitle => '';

  @override
  String get translatorMultiHelpContent => '';

  @override
  String get padlockResetTitle => '';

  @override
  String get padlockResetContent => '';
}
