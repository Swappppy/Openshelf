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
  String get libraryTitle => 'Mi Biblioteca';

  @override
  String get libraryEmpty => 'Tu biblioteca está vacía';

  @override
  String get libraryEmptyHint => 'Pulsa + para añadir tu primer libro';

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
  String get searchHint => 'Buscar por título…';

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
  String get filterTagsLabel => 'Categorías';

  @override
  String get done => 'Hecho';

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
  String get scanBarcodePermission =>
      'Se requiere permiso de cámara para escanear códigos';

  @override
  String get scanBatch => 'Escanear en lote';

  @override
  String get scanBatchSubtitle => 'Próximamente';

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
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldTotalPages => 'Páginas totales';

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
  String get bookDetailNotesHint => 'Escribe tus notas aquí…';

  @override
  String get bookDetailNotesEmpty => 'Toca para añadir notas…';

  @override
  String get bookDetailDeleteTitle => 'Eliminar libro';

  @override
  String bookDetailDeleteConfirm(String title) {
    return '¿Eliminar \"$title\"? Esta acción no se puede deshacer.';
  }

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
  String get shelvesSectionMine => 'Mis estanterías';

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
  String get shelfNewTooltip => 'Nueva estantería';

  @override
  String get shelfEmpty => 'No tienes estanterías personalizadas';

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
  String get managementCategories => 'Categorías';

  @override
  String get managementImprints => 'Sellos editoriales';

  @override
  String get managementCollections => 'Colecciones';

  @override
  String get tagNone => 'No hay categorías todavía';

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
  String get collectionNone => 'Las colecciones se crean al guardar un libro';

  @override
  String get collectionDeleteTitle => 'Eliminar colección';

  @override
  String collectionDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema (automático)';

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
  String get bookSearchHint => 'Título, autor o ISBN…';

  @override
  String get bookSearchPrompt => 'Busca por título, autor o ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String bookSearchFallbackNotice(String provider) {
    return 'Sin resultados en el proveedor principal. Mostrando resultados de $provider.';
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
}
