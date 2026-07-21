// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get fieldTranslator => 'Traducción';

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
  String get bookDetailNewReadingSections => 'Secciones específicas';

  @override
  String get bookDetailNewReadingSelectSections =>
      'Seleccionar secciones para releer';

  @override
  String get bookDetailStartNewReadingPrompt =>
      '¿Quieres empezar una nueva lectura?';

  @override
  String get bookDetailStartNewReadingButton => 'Empezar nueva lectura';

  @override
  String get bookDetailDeleteReadPrompt =>
      '¿Eliminar la última lectura en curso? Se perderán las fechas de esta sesión.';

  @override
  String get bookDetailReadHistoryTitle => 'HISTORIAL DE LECTURAS';

  @override
  String get bookDetailReadOngoing => 'en curso';

  @override
  String bookDetailReadNumber(Object number) {
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
  String pageProgress(int current, int total, String percent) {
    return '$current / $total págs · $percent%';
  }

  @override
  String pageProgressShort(int current, int total) {
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
  String get shelfBooksEmpty => 'Sin libros en esta estantería';

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
      'Copia la clave resultante (empieza por \"AIza...\") y pégala en el campo de arriba.';

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
  String paginationSegmentOverlap(int index1, int index2) {
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
}
