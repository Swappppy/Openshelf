import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
  ];

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Openshelf'**
  String get appTitle;

  /// Prefijo genérico de error
  ///
  /// In es, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// Error crítico al arrancar la app
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar la aplicación: {error}'**
  String criticalStartError(String error);

  /// Pestaña de navegación: biblioteca
  ///
  /// In es, this message translates to:
  /// **'Biblioteca'**
  String get navLibrary;

  /// Pestaña de navegación: estanterías
  ///
  /// In es, this message translates to:
  /// **'Estanterías'**
  String get navShelves;

  /// Pestaña de navegación: estadísticas
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get navStats;

  /// Título de la pantalla de biblioteca
  ///
  /// In es, this message translates to:
  /// **'Mi Biblioteca'**
  String get libraryTitle;

  /// Estado vacío de la biblioteca sin filtros
  ///
  /// In es, this message translates to:
  /// **'Tu biblioteca está vacía'**
  String get libraryEmpty;

  /// Pista cuando la biblioteca está vacía
  ///
  /// In es, this message translates to:
  /// **'Pulsa + para añadir tu primer libro'**
  String get libraryEmptyHint;

  /// Sin resultados con filtros activos
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get libraryNoResults;

  /// Pista cuando no hay resultados con filtros
  ///
  /// In es, this message translates to:
  /// **'Prueba con otros filtros'**
  String get libraryNoResultsHint;

  /// Etiqueta del FAB para añadir libro
  ///
  /// In es, this message translates to:
  /// **'Añadir libro'**
  String get addBook;

  /// Título del panel de preferencias de visualización
  ///
  /// In es, this message translates to:
  /// **'Mostrar en la biblioteca'**
  String get displaySettings;

  /// Pista sobre arrastrar para reordenar campos
  ///
  /// In es, this message translates to:
  /// **'Arrastra para reordenar'**
  String get displaySettingsDragHint;

  /// Botón de ajustes en el panel de visualización
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsButton;

  /// Nombre del campo autor
  ///
  /// In es, this message translates to:
  /// **'Autor'**
  String get fieldAuthor;

  /// Nombre del campo editorial
  ///
  /// In es, this message translates to:
  /// **'Editorial'**
  String get fieldPublisher;

  /// Nombre del campo año de publicación
  ///
  /// In es, this message translates to:
  /// **'Año de publicación'**
  String get fieldYear;

  /// Nombre del campo valoración
  ///
  /// In es, this message translates to:
  /// **'Valoración'**
  String get fieldRating;

  /// Nombre del campo etiquetas
  ///
  /// In es, this message translates to:
  /// **'Etiquetas'**
  String get fieldTags;

  /// Nombre del campo progreso de lectura
  ///
  /// In es, this message translates to:
  /// **'Progreso de lectura'**
  String get fieldReadingProgress;

  /// Nombre del campo chip de estado
  ///
  /// In es, this message translates to:
  /// **'Chip de estado'**
  String get fieldStatusChip;

  /// Placeholder del campo de búsqueda en la biblioteca
  ///
  /// In es, this message translates to:
  /// **'Buscar por título…'**
  String get searchHint;

  /// Placeholder del filtro de autor
  ///
  /// In es, this message translates to:
  /// **'Autor'**
  String get filterAuthor;

  /// Placeholder del filtro de ISBN
  ///
  /// In es, this message translates to:
  /// **'ISBN'**
  String get filterIsbn;

  /// Placeholder del filtro de editorial
  ///
  /// In es, this message translates to:
  /// **'Editorial'**
  String get filterPublisher;

  /// Placeholder del filtro de colección
  ///
  /// In es, this message translates to:
  /// **'Colección'**
  String get filterCollection;

  /// Etiqueta de sección de sello editorial en filtros
  ///
  /// In es, this message translates to:
  /// **'Sello editorial'**
  String get filterImprintLabel;

  /// Etiqueta de sección de categorías en filtros
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get filterTagsLabel;

  /// Botón genérico de confirmación / cerrar
  ///
  /// In es, this message translates to:
  /// **'Hecho'**
  String get done;

  /// Botón genérico de cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Botón genérico de guardar
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Botón genérico de eliminar
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// Botón genérico de crear
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// Acción genérica de editar
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Botón para tomar foto
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get photo;

  /// Botón para introducir URL
  ///
  /// In es, this message translates to:
  /// **'URL'**
  String get url;

  /// Botón para descargar desde URL
  ///
  /// In es, this message translates to:
  /// **'Descargar'**
  String get download;

  /// Botón para reintentar una operación fallida
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Título del modal de añadir libro
  ///
  /// In es, this message translates to:
  /// **'Añadir libro'**
  String get addBookModalTitle;

  /// Subtítulo del modal de añadir libro
  ///
  /// In es, this message translates to:
  /// **'Elige cómo quieres añadir tu libro'**
  String get addBookModalSubtitle;

  /// Opción de añadir libro manualmente
  ///
  /// In es, this message translates to:
  /// **'Añadir manualmente'**
  String get addManually;

  /// Subtítulo de la opción de añadir manualmente
  ///
  /// In es, this message translates to:
  /// **'Rellena los datos tú mismo'**
  String get addManuallySubtitle;

  /// Opción de buscar libro en internet
  ///
  /// In es, this message translates to:
  /// **'Buscar libro'**
  String get searchBook;

  /// Subtítulo de la opción de buscar libro
  ///
  /// In es, this message translates to:
  /// **'Por título, autor o ISBN'**
  String get searchBookSubtitle;

  /// Opción de escanear código de barras
  ///
  /// In es, this message translates to:
  /// **'Escanear código de barras'**
  String get scanBarcode;

  /// Subtítulo de la opción de escanear código de barras
  ///
  /// In es, this message translates to:
  /// **'Apunta la cámara al ISBN'**
  String get scanBarcodeSubtitle;

  /// Opción de escanear ISBN mediante texto
  ///
  /// In es, this message translates to:
  /// **'Escanear número ISBN'**
  String get scanIsbnText;

  /// Subtítulo de la opción de escanear ISBN mediante texto
  ///
  /// In es, this message translates to:
  /// **'Apunta al número impreso'**
  String get scanIsbnTextSubtitle;

  /// Mensaje de falta de permiso de cámara
  ///
  /// In es, this message translates to:
  /// **'Se requiere permiso de cámara para escanear códigos'**
  String get scanBarcodePermission;

  /// Opción de escanear en lote
  ///
  /// In es, this message translates to:
  /// **'Escanear en lote'**
  String get scanBatch;

  /// Subtítulo de la opción de escanear en lote
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get scanBatchSubtitle;

  /// Título del formulario al crear libro
  ///
  /// In es, this message translates to:
  /// **'Nuevo libro'**
  String get bookFormNewTitle;

  /// Título del formulario al editar libro
  ///
  /// In es, this message translates to:
  /// **'Editar libro'**
  String get bookFormEditTitle;

  /// Nombre de la pestaña principal del formulario/detalle
  ///
  /// In es, this message translates to:
  /// **'Principal'**
  String get tabMain;

  /// Nombre de la pestaña de detalles del formulario/detalle
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get tabDetails;

  /// Nombre del campo título del libro
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get fieldTitle;

  /// Nombre del campo ISBN
  ///
  /// In es, this message translates to:
  /// **'ISBN'**
  String get fieldIsbn;

  /// Nombre del campo de páginas totales
  ///
  /// In es, this message translates to:
  /// **'Páginas totales'**
  String get fieldTotalPages;

  /// Nombre del campo de página actual
  ///
  /// In es, this message translates to:
  /// **'Página actual'**
  String get fieldCurrentPage;

  /// Nombre del campo de notas
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get fieldNotes;

  /// Nombre del campo de colección
  ///
  /// In es, this message translates to:
  /// **'Colección / Serie'**
  String get fieldCollection;

  /// Nombre del campo de número en la colección
  ///
  /// In es, this message translates to:
  /// **'Número en la colección'**
  String get fieldCollectionNumber;

  /// Encabezado de sección de información básica
  ///
  /// In es, this message translates to:
  /// **'Información básica'**
  String get sectionBasicInfo;

  /// Encabezado de sección de categorías
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get sectionCategories;

  /// Encabezado de sección de estado de lectura
  ///
  /// In es, this message translates to:
  /// **'Estado de lectura'**
  String get sectionReadingStatus;

  /// Encabezado de sección de formato
  ///
  /// In es, this message translates to:
  /// **'Formato'**
  String get sectionFormat;

  /// Encabezado de sección de valoración
  ///
  /// In es, this message translates to:
  /// **'Valoración'**
  String get sectionRating;

  /// Encabezado de sección de sello editorial
  ///
  /// In es, this message translates to:
  /// **'Sello editorial'**
  String get sectionImprint;

  /// Botón de portada: hacer foto
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get coverPickPhoto;

  /// Botón de portada: URL
  ///
  /// In es, this message translates to:
  /// **'URL'**
  String get coverPickUrl;

  /// Botón de portada: buscar en internet
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get coverSearch;

  /// Título del diálogo de URL de portada
  ///
  /// In es, this message translates to:
  /// **'URL de la portada'**
  String get coverUrlDialogTitle;

  /// Placeholder del campo de URL de portada
  ///
  /// In es, this message translates to:
  /// **'https://ejemplo.com/portada.jpg'**
  String get coverUrlHint;

  /// Error al descargar portada desde URL
  ///
  /// In es, this message translates to:
  /// **'No se pudo descargar la imagen'**
  String get coverDownloadError;

  /// Título de la pantalla de recorte de portada
  ///
  /// In es, this message translates to:
  /// **'Recortar portada'**
  String get cropCoverTitle;

  /// Título de la pantalla de recorte de sello
  ///
  /// In es, this message translates to:
  /// **'Recortar sello'**
  String get cropImprintTitle;

  /// Placeholder del campo de búsqueda/creación de etiquetas
  ///
  /// In es, this message translates to:
  /// **'Buscar o crear categoría'**
  String get tagSearchOrCreate;

  /// Pista sobre cómo crear etiquetas
  ///
  /// In es, this message translates to:
  /// **'Escribe y pulsa Enter para añadir o crear'**
  String get tagCreateHint;

  /// Estado vacío de categorías en el picker
  ///
  /// In es, this message translates to:
  /// **'No hay categorías creadas todavía'**
  String get tagNoCategories;

  /// Placeholder del campo de búsqueda de sello
  ///
  /// In es, this message translates to:
  /// **'Buscar sello editorial'**
  String get imprintSearch;

  /// Mensaje de validación para campos obligatorios
  ///
  /// In es, this message translates to:
  /// **'Campo obligatorio'**
  String get requiredField;

  /// Estado: quiero leer
  ///
  /// In es, this message translates to:
  /// **'Por leer'**
  String get statusWantToRead;

  /// Estado: leyendo
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get statusReading;

  /// Estado: leído
  ///
  /// In es, this message translates to:
  /// **'Leído'**
  String get statusRead;

  /// Estado: abandonado
  ///
  /// In es, this message translates to:
  /// **'Abandonado'**
  String get statusAbandoned;

  /// Formato: tapa blanda
  ///
  /// In es, this message translates to:
  /// **'Tapa blanda'**
  String get formatPaperback;

  /// Formato: tapa dura
  ///
  /// In es, this message translates to:
  /// **'Tapa dura'**
  String get formatHardcover;

  /// Formato: piel
  ///
  /// In es, this message translates to:
  /// **'Piel'**
  String get formatLeatherbound;

  /// Formato: rústica
  ///
  /// In es, this message translates to:
  /// **'Rústica'**
  String get formatRustic;

  /// Formato: digital
  ///
  /// In es, this message translates to:
  /// **'Digital'**
  String get formatDigital;

  /// Formato: otro
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get formatOther;

  /// Mensaje cuando no se encuentra el libro
  ///
  /// In es, this message translates to:
  /// **'Libro no encontrado'**
  String get bookDetailNotFound;

  /// Título del picker de página actual
  ///
  /// In es, this message translates to:
  /// **'Página actual'**
  String get bookDetailPagePickerTitle;

  /// Título de la sección de notas personales
  ///
  /// In es, this message translates to:
  /// **'Notas personales'**
  String get bookDetailNotesTitle;

  /// Placeholder del campo de notas
  ///
  /// In es, this message translates to:
  /// **'Escribe tus notas aquí…'**
  String get bookDetailNotesHint;

  /// Texto cuando no hay notas
  ///
  /// In es, this message translates to:
  /// **'Toca para añadir notas…'**
  String get bookDetailNotesEmpty;

  /// Título del diálogo de eliminar libro
  ///
  /// In es, this message translates to:
  /// **'Eliminar libro'**
  String get bookDetailDeleteTitle;

  /// Confirmación de eliminar libro
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{title}\"? Esta acción no se puede deshacer.'**
  String bookDetailDeleteConfirm(String title);

  /// Etiqueta de sección de páginas en detalle
  ///
  /// In es, this message translates to:
  /// **'PÁGINAS'**
  String get bookDetailFieldPages;

  /// Etiqueta de sección de categorías en detalle
  ///
  /// In es, this message translates to:
  /// **'CATEGORÍAS'**
  String get bookDetailFieldCategories;

  /// Etiqueta del campo formato en detalle
  ///
  /// In es, this message translates to:
  /// **'Formato'**
  String get bookDetailFieldFormat;

  /// Etiqueta de sección de valoración en detalle
  ///
  /// In es, this message translates to:
  /// **'VALORACIÓN'**
  String get bookDetailFieldRating;

  /// Etiqueta de sección de sello editorial en detalle
  ///
  /// In es, this message translates to:
  /// **'SELLO EDITORIAL'**
  String get bookDetailFieldImprintSection;

  /// Etiqueta de sección de notas personales en detalle
  ///
  /// In es, this message translates to:
  /// **'NOTAS PERSONALES'**
  String get bookDetailFieldPersonalNotes;

  /// Etiqueta del campo de fecha de adición
  ///
  /// In es, this message translates to:
  /// **'Añadido'**
  String get bookDetailFieldAdded;

  /// Etiqueta del campo de inicio de lectura
  ///
  /// In es, this message translates to:
  /// **'Inicio lectura'**
  String get bookDetailFieldStarted;

  /// Etiqueta del campo de fin de lectura
  ///
  /// In es, this message translates to:
  /// **'Fin lectura'**
  String get bookDetailFieldFinished;

  /// Progreso de lectura en formato páginas
  ///
  /// In es, this message translates to:
  /// **'{current} / {total} págs · {percent}%'**
  String pageProgress(int current, int total, String percent);

  /// Progreso de lectura corto
  ///
  /// In es, this message translates to:
  /// **'{current} / {total}'**
  String pageProgressShort(int current, int total);

  /// Número de páginas con sufijo
  ///
  /// In es, this message translates to:
  /// **'{count} págs.'**
  String pageSuffix(int count);

  /// Etiqueta genérica de páginas
  ///
  /// In es, this message translates to:
  /// **'páginas'**
  String get pagesLabel;

  /// Título de la pantalla de estanterías
  ///
  /// In es, this message translates to:
  /// **'Estanterías'**
  String get shelvesTitle;

  /// Encabezado de sección por estado
  ///
  /// In es, this message translates to:
  /// **'Por estado'**
  String get shelvesSectionByStatus;

  /// Encabezado de sección de estanterías personalizadas
  ///
  /// In es, this message translates to:
  /// **'Mis estanterías'**
  String get shelvesSectionMine;

  /// Encabezado de sección de gestión
  ///
  /// In es, this message translates to:
  /// **'Gestión'**
  String get shelvesSectionManagement;

  /// Estantería de todos los libros
  ///
  /// In es, this message translates to:
  /// **'Todos los libros'**
  String get shelfAllBooks;

  /// Estantería de libros en lectura
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get shelfReading;

  /// Estantería de libros leídos
  ///
  /// In es, this message translates to:
  /// **'Leídos'**
  String get shelfRead;

  /// Estantería de libros por leer
  ///
  /// In es, this message translates to:
  /// **'Por leer'**
  String get shelfWantToRead;

  /// Estantería de libros abandonados
  ///
  /// In es, this message translates to:
  /// **'Abandonados'**
  String get shelfAbandoned;

  /// Tooltip del botón de nueva estantería
  ///
  /// In es, this message translates to:
  /// **'Nueva estantería'**
  String get shelfNewTooltip;

  /// Estado vacío de estanterías personalizadas
  ///
  /// In es, this message translates to:
  /// **'No tienes estanterías personalizadas'**
  String get shelfEmpty;

  /// Estado vacío de libros en una estantería
  ///
  /// In es, this message translates to:
  /// **'Sin libros en esta estantería'**
  String get shelfBooksEmpty;

  /// Estado vacío de libros por estado
  ///
  /// In es, this message translates to:
  /// **'No hay libros aquí'**
  String get shelfStatusBooksEmpty;

  /// Título del formulario de nueva estantería
  ///
  /// In es, this message translates to:
  /// **'Nueva estantería'**
  String get shelfFormNew;

  /// Título del formulario de editar estantería
  ///
  /// In es, this message translates to:
  /// **'Editar estantería'**
  String get shelfFormEdit;

  /// Label del campo nombre de estantería
  ///
  /// In es, this message translates to:
  /// **'Nombre de la estantería'**
  String get shelfFormNameLabel;

  /// Sección de estado en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'Estado de lectura'**
  String get shelfFormSectionStatus;

  /// Sección de título en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get shelfFormSectionTitle;

  /// Sección de autor en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'Autor'**
  String get shelfFormSectionAuthor;

  /// Sección de editorial en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'Editorial'**
  String get shelfFormSectionPublisher;

  /// Sección de ISBN en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'ISBN'**
  String get shelfFormSectionIsbn;

  /// Sección de colección en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'Colección'**
  String get shelfFormSectionCollection;

  /// Sección de categorías en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get shelfFormSectionCategories;

  /// Sección de sello en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'Sello editorial'**
  String get shelfFormSectionImprint;

  /// Placeholder del filtro de título en estantería
  ///
  /// In es, this message translates to:
  /// **'Buscar en título'**
  String get shelfFormHintTitle;

  /// Placeholder del filtro de autor en estantería
  ///
  /// In es, this message translates to:
  /// **'Nombre del autor'**
  String get shelfFormHintAuthor;

  /// Placeholder del filtro de editorial en estantería
  ///
  /// In es, this message translates to:
  /// **'Nombre de la editorial'**
  String get shelfFormHintPublisher;

  /// Placeholder del filtro de ISBN en estantería
  ///
  /// In es, this message translates to:
  /// **'ISBN'**
  String get shelfFormHintIsbn;

  /// Placeholder del filtro de colección en estantería
  ///
  /// In es, this message translates to:
  /// **'Nombre de la colección'**
  String get shelfFormHintCollection;

  /// Opción de estado: cualquiera en formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'Cualquiera'**
  String get shelfFormStatusAny;

  /// Opción de menú: editar estantería
  ///
  /// In es, this message translates to:
  /// **'Editar estantería'**
  String get shelfOptionEdit;

  /// Opción de menú: eliminar estantería
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get shelfOptionDelete;

  /// Etiqueta de estado: leyendo en subtítulo de estantería
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get shelfStatusLabelReading;

  /// Etiqueta de estado: leídos en subtítulo de estantería
  ///
  /// In es, this message translates to:
  /// **'Leídos'**
  String get shelfStatusLabelRead;

  /// Etiqueta de estado: por leer en subtítulo de estantería
  ///
  /// In es, this message translates to:
  /// **'Por leer'**
  String get shelfStatusLabelWantToRead;

  /// Etiqueta de estado: abandonados en subtítulo de estantería
  ///
  /// In es, this message translates to:
  /// **'Abandonados'**
  String get shelfStatusLabelAbandoned;

  /// Sección de gestión: categorías
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get managementCategories;

  /// Sección de gestión: sellos editoriales
  ///
  /// In es, this message translates to:
  /// **'Sellos editoriales'**
  String get managementImprints;

  /// Sección de gestión: colecciones
  ///
  /// In es, this message translates to:
  /// **'Colecciones'**
  String get managementCollections;

  /// Estado vacío de categorías
  ///
  /// In es, this message translates to:
  /// **'No hay categorías todavía'**
  String get tagNone;

  /// Botón de nueva categoría
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get tagNew;

  /// Título del diálogo de nueva categoría
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get tagNewDialogTitle;

  /// Label del campo nombre de categoría
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get tagNameLabel;

  /// Label de selección de color de categoría
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get tagColorLabel;

  /// Título del diálogo de eliminar categoría
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get tagDeleteTitle;

  /// Confirmación de eliminar categoría
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String tagDeleteConfirm(String name);

  /// Estado vacío de sellos editoriales
  ///
  /// In es, this message translates to:
  /// **'No hay sellos todavía'**
  String get imprintNone;

  /// Botón de nuevo sello
  ///
  /// In es, this message translates to:
  /// **'Nuevo sello'**
  String get imprintNew;

  /// Título del diálogo de nuevo sello
  ///
  /// In es, this message translates to:
  /// **'Nuevo sello editorial'**
  String get imprintNewDialogTitle;

  /// Título del diálogo de editar sello
  ///
  /// In es, this message translates to:
  /// **'Editar sello'**
  String get imprintEditDialogTitle;

  /// Label del campo nombre de sello
  ///
  /// In es, this message translates to:
  /// **'Nombre del sello'**
  String get imprintNameLabel;

  /// Pista para añadir imagen a sello
  ///
  /// In es, this message translates to:
  /// **'Pulsa para añadir imagen'**
  String get imprintAddImageHint;

  /// Pista para cambiar imagen de sello
  ///
  /// In es, this message translates to:
  /// **'Pulsa para cambiar imagen'**
  String get imprintChangeImageHint;

  /// Título del diálogo de URL de imagen de sello
  ///
  /// In es, this message translates to:
  /// **'URL de la imagen'**
  String get imprintUrlDialogTitle;

  /// Placeholder de URL de imagen de sello
  ///
  /// In es, this message translates to:
  /// **'https://ejemplo.com/sello.jpg'**
  String get imprintUrlHint;

  /// Título del diálogo de eliminar sello
  ///
  /// In es, this message translates to:
  /// **'Eliminar sello'**
  String get imprintDeleteTitle;

  /// Confirmación de eliminar sello
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String imprintDeleteConfirm(String name);

  /// Estado vacío de sellos en el formulario de estantería
  ///
  /// In es, this message translates to:
  /// **'No hay sellos creados'**
  String get imprintNoImprints;

  /// Estado vacío de colecciones
  ///
  /// In es, this message translates to:
  /// **'Las colecciones se crean al guardar un libro'**
  String get collectionNone;

  /// Título del diálogo de eliminar colección
  ///
  /// In es, this message translates to:
  /// **'Eliminar colección'**
  String get collectionDeleteTitle;

  /// Confirmación de eliminar colección
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String collectionDeleteConfirm(String name);

  /// Título de la pantalla de ajustes
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// Sección de apariencia en ajustes
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsSectionAppearance;

  /// Etiqueta del selector de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// Opción de idioma: sistema
  ///
  /// In es, this message translates to:
  /// **'Sistema (automático)'**
  String get settingsLanguageSystem;

  /// Etiqueta de selector de modo de tema
  ///
  /// In es, this message translates to:
  /// **'Modo de tema'**
  String get settingsThemeMode;

  /// Opción de tema claro
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// Opción de tema según sistema
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsThemeSystem;

  /// Opción de tema oscuro
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeDark;

  /// Etiqueta del selector de color de acento
  ///
  /// In es, this message translates to:
  /// **'Color de acento'**
  String get settingsAccentColor;

  /// Pista del selector de color de acento
  ///
  /// In es, this message translates to:
  /// **'Toca un color para aplicarlo'**
  String get settingsAccentColorHint;

  /// Sección de almacenamiento en ajustes
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento'**
  String get settingsSectionStorage;

  /// Etiqueta de la carpeta de portadas
  ///
  /// In es, this message translates to:
  /// **'Carpeta de portadas'**
  String get settingsCoversFolder;

  /// Etiqueta de la base de datos
  ///
  /// In es, this message translates to:
  /// **'Base de datos'**
  String get settingsDatabase;

  /// Texto cuando se usa el directorio por defecto
  ///
  /// In es, this message translates to:
  /// **'Directorio por defecto'**
  String get settingsDefaultDir;

  /// Título del diálogo de mover base de datos
  ///
  /// In es, this message translates to:
  /// **'Mover base de datos'**
  String get settingsDbMoveTitle;

  /// Contenido del diálogo de mover base de datos
  ///
  /// In es, this message translates to:
  /// **'Mover la base de datos requiere reiniciar la app. Los datos se copiarán al nuevo directorio. ¿Continuar?'**
  String get settingsDbMoveContent;

  /// Confirmación de mover base de datos
  ///
  /// In es, this message translates to:
  /// **'Mover y reiniciar'**
  String get settingsDbMoveConfirm;

  /// Sección de búsqueda en ajustes
  ///
  /// In es, this message translates to:
  /// **'Búsqueda de libros'**
  String get settingsSectionSearch;

  /// Etiqueta del selector de servidor de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Servidor'**
  String get settingsSearchServer;

  /// Pista del selector de servidor de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Se usará para buscar libros por ISBN o título'**
  String get settingsSearchServerHint;

  /// Título de la tarjeta de API key de Google Books
  ///
  /// In es, this message translates to:
  /// **'Google Books API key'**
  String get settingsApiKeyTitle;

  /// Mensaje cuando la API key está configurada
  ///
  /// In es, this message translates to:
  /// **'Clave configurada. Google Books está disponible.'**
  String get settingsApiKeyConfigured;

  /// Mensaje cuando no hay API key configurada
  ///
  /// In es, this message translates to:
  /// **'Sin clave, Google Books usará Open Library como alternativa.'**
  String get settingsApiKeyMissing;

  /// Placeholder del campo de API key
  ///
  /// In es, this message translates to:
  /// **'AIza...'**
  String get settingsApiKeyHint;

  /// Tooltip del botón de mostrar API key
  ///
  /// In es, this message translates to:
  /// **'Mostrar'**
  String get settingsApiKeyShow;

  /// Tooltip del botón de ocultar API key
  ///
  /// In es, this message translates to:
  /// **'Ocultar'**
  String get settingsApiKeyHide;

  /// Botón de guardar API key
  ///
  /// In es, this message translates to:
  /// **'Guardar clave'**
  String get settingsApiKeySave;

  /// Snackbar de confirmación al guardar API key
  ///
  /// In es, this message translates to:
  /// **'Clave guardada'**
  String get settingsApiKeySaved;

  /// Tooltip del botón de borrar API key
  ///
  /// In es, this message translates to:
  /// **'Borrar clave'**
  String get settingsApiKeyClear;

  /// Botón de instrucciones de API key
  ///
  /// In es, this message translates to:
  /// **'Cómo obtenerla'**
  String get settingsApiKeyHowTo;

  /// Título del sheet de instrucciones de API key
  ///
  /// In es, this message translates to:
  /// **'Cómo obtener una clave de Google Books'**
  String get settingsApiKeyInstructionsTitle;

  /// Paso 1 de instrucciones de API key
  ///
  /// In es, this message translates to:
  /// **'Abre console.cloud.google.com e inicia sesión con tu cuenta de Google.'**
  String get settingsApiKeyStep1;

  /// Paso 2 de instrucciones de API key
  ///
  /// In es, this message translates to:
  /// **'Crea un proyecto nuevo (el nombre es indiferente).'**
  String get settingsApiKeyStep2;

  /// Paso 3 de instrucciones de API key
  ///
  /// In es, this message translates to:
  /// **'Ve a APIs y servicios → Biblioteca, busca \"Books API\" y actívala.'**
  String get settingsApiKeyStep3;

  /// Paso 4 de instrucciones de API key
  ///
  /// In es, this message translates to:
  /// **'Ve a APIs y servicios → Credenciales → Crear credenciales → Clave de API.'**
  String get settingsApiKeyStep4;

  /// Paso 5 de instrucciones de API key
  ///
  /// In es, this message translates to:
  /// **'Opcional pero recomendado: restringe la clave a la Books API únicamente.'**
  String get settingsApiKeyStep5;

  /// Paso 6 de instrucciones de API key
  ///
  /// In es, this message translates to:
  /// **'Copia la clave resultante (empieza por \"AIza...\") y pégala en el campo de arriba.'**
  String get settingsApiKeyStep6;

  /// Nota informativa sobre la API key
  ///
  /// In es, this message translates to:
  /// **'La clave es gratuita y permite hasta 1.000 búsquedas diarias. No se comparte con nadie: se guarda solo en este dispositivo.'**
  String get settingsApiKeyNote;

  /// Placeholder del campo de búsqueda de libros
  ///
  /// In es, this message translates to:
  /// **'Título, autor o ISBN…'**
  String get bookSearchHint;

  /// Mensaje inicial de la pantalla de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Busca por título, autor o ISBN'**
  String get bookSearchPrompt;

  /// Mensaje de sin resultados en búsqueda
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para \"{query}\"'**
  String bookSearchNoResults(String query);

  /// Aviso de fallback en búsqueda
  ///
  /// In es, this message translates to:
  /// **'Sin resultados en el proveedor principal. Mostrando resultados de {provider}.'**
  String bookSearchFallbackNotice(String provider);

  /// Error: falta API key de Google Books
  ///
  /// In es, this message translates to:
  /// **'Google Books requiere una clave de API.\nConfigúrala en Ajustes → Búsqueda de libros.'**
  String get bookSearchErrorNoApiKey;

  /// Error: rate limit de Google Books
  ///
  /// In es, this message translates to:
  /// **'Google Books ha limitado las peticiones.\nEspera un momento e inténtalo de nuevo.'**
  String get bookSearchErrorRateLimit;

  /// Error de red en búsqueda
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar con ningún servidor.\nComprueba tu conexión e inténtalo de nuevo.'**
  String get bookSearchErrorNetwork;

  /// Título del sheet de búsqueda de portadas
  ///
  /// In es, this message translates to:
  /// **'Portadas'**
  String get coverPickerTitle;

  /// Subtítulo del sheet con ISBN
  ///
  /// In es, this message translates to:
  /// **'ISBN {isbn}'**
  String coverPickerIsbnLabel(String isbn);

  /// Sin portadas encontradas
  ///
  /// In es, this message translates to:
  /// **'No se encontraron portadas para este libro.'**
  String get coverPickerNoResults;

  /// Error de red en búsqueda de portadas
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar. Comprueba tu conexión.'**
  String get coverPickerNetworkError;

  /// Progreso de carga de portadas
  ///
  /// In es, this message translates to:
  /// **'{loaded} / {total}'**
  String coverPickerProgress(int loaded, int total);

  /// Título de la pantalla de estadísticas
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statsTitle;

  /// Placeholder de estadísticas
  ///
  /// In es, this message translates to:
  /// **'Tus estadísticas aparecerán aquí'**
  String get statsPlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
