// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

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
    return 'Error en iniciar l\'aplicació: $error';
  }

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navShelves => 'Prestatgeries';

  @override
  String get navStats => 'Estadístiques';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmpty => 'La teva biblioteca està buida';

  @override
  String get libraryEmptyHint => 'Quin serà el teu primer llibre?';

  @override
  String get libraryAddFirstBook => 'Afegir primer llibre';

  @override
  String get libraryNoResults => 'Sense resultats';

  @override
  String get libraryNoResultsHint => 'Prova amb altres filtres';

  @override
  String get addBook => 'Afegir llibre';

  @override
  String get displaySettings => 'Mostra a la biblioteca';

  @override
  String get displaySettingsDragHint => 'Arrossega per reordenar';

  @override
  String get settingsButton => 'Ajusts';

  @override
  String get fieldAuthor => 'Autor';

  @override
  String get fieldPublisher => 'Editorial';

  @override
  String get fieldYear => 'Any de publicació';

  @override
  String get fieldRating => 'Valoració';

  @override
  String get fieldTags => 'Etiquetes';

  @override
  String get fieldReadingProgress => 'Progrés de lectura';

  @override
  String get fieldStatusChip => 'Xip d\'estat';

  @override
  String get searchHint => 'Cerca per títol...';

  @override
  String get filterAuthor => 'Autor';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Editorial';

  @override
  String get filterCollection => 'Col·lecció';

  @override
  String get filterImprintLabel => 'Segell editorial';

  @override
  String imprintBookCount(int count) {
    return '$count llibres';
  }

  @override
  String get filterTagsLabel => 'Categories';

  @override
  String get done => 'Fet';

  @override
  String get loading => 'S\'està carregant...';

  @override
  String get loadingImport =>
      'S\'estan important els llibres, espera un moment...';

  @override
  String get loadingExport =>
      'S\'estan exportant els llibres, espera un moment...';

  @override
  String get exportProgressData => 'S\'estan exportant les dades...';

  @override
  String get exportProgressMedia =>
      'S\'estan preparant els fitxers multimèdia...';

  @override
  String get exportProgressCompress =>
      'S\'està comprimint la còpia de seguretat...';

  @override
  String get exportProgressFinalize => 'S\'està obrint el menú de compartir...';

  @override
  String exportSaveSuccess(String path) {
    return 'Còpia de seguretat desada a $path';
  }

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get save => 'Desar';

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
  String get download => 'Descarregar';

  @override
  String get retry => 'Reintentar';

  @override
  String get share => 'Compartir';

  @override
  String get saveToDevice => 'Desar al dispositiu';

  @override
  String get addBookModalTitle => 'Afegir llibre';

  @override
  String get addBookModalSubtitle => 'Tria com vols afegir el teu llibre';

  @override
  String get addManually => 'Afegir manualment';

  @override
  String get addManuallySubtitle => 'Omple les dades tu mateix';

  @override
  String get searchBook => 'Cercar llibre';

  @override
  String get searchBookSubtitle => 'Per títol, autor o ISBN';

  @override
  String get scanBarcode => 'Escanejar codi de barres';

  @override
  String get scanBarcodeSubtitle => 'Apunta la càmera a l\'ISBN';

  @override
  String get scanIsbnText => 'Escanejar número ISBN';

  @override
  String get scanIsbnTextSubtitle => 'Apunta al número imprès';

  @override
  String get scanIsbnSelect => 'Toca un ISBN per seleccionar-lo';

  @override
  String get scanOcrHoldMessage => 'Manté la imatge uns segons...';

  @override
  String get scanBarcodePermission =>
      'Es requereix permís de càmera per escanejar codis';

  @override
  String get scanBatch => 'Escanejar en lot';

  @override
  String get scanBatchSubtitle => 'Escaneja diversos llibres seguits';

  @override
  String get scanModeBarcode => 'Codi de barres';

  @override
  String get scanModeIsbn => 'Número ISBN';

  @override
  String get bookFormNewTitle => 'Nou llibre';

  @override
  String get bookFormEditTitle => 'Editar llibre';

  @override
  String get tabMain => 'Principal';

  @override
  String get tabDetails => 'Detalls';

  @override
  String get fieldTitle => 'Títol';

  @override
  String get fieldSubtitle => 'Subtítol';

  @override
  String get fieldDescription => 'Sinopsi';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Idioma';

  @override
  String get fieldIsTranslation => 'És una traducció?';

  @override
  String get fieldOriginalTitle => 'Títol original';

  @override
  String get fieldOriginalLanguage => 'Idioma original';

  @override
  String get fieldTranslator => 'Traductor';

  @override
  String get fieldReads => 'Lectures';

  @override
  String get fieldCopies => 'Còpies';

  @override
  String get fieldTotalPages => 'Pàgines totals';

  @override
  String get fieldTotalBooks => 'Llibres totals';

  @override
  String get fieldCurrentPage => 'Pàgina actual';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldCollection => 'Col·lecció / Sèrie';

  @override
  String get fieldCollectionNumber => 'Número a la col·lecció';

  @override
  String get sectionBasicInfo => 'Informació bàsica';

  @override
  String get sectionCategories => 'Categories';

  @override
  String get sectionReadingStatus => 'Estat de lectura';

  @override
  String get sectionFormat => 'Format';

  @override
  String get sectionRating => 'Valoració';

  @override
  String get sectionImprint => 'Segell editorial';

  @override
  String get coverPickPhoto => 'Foto';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Cercar';

  @override
  String get coverUrlDialogTitle => 'URL de la portada';

  @override
  String get coverUrlHint => 'https://exemple.com/portada.jpg';

  @override
  String get coverDownloadError => 'No s\'ha pogut descarregar la imatge';

  @override
  String get imageProcessError => 'No s\'ha pogut processar la imatge';

  @override
  String get cropCoverTitle => 'Retallar portada';

  @override
  String get cropImprintTitle => 'Retallar segell';

  @override
  String get tagSearchOrCreate => 'Cercar o crear categoria';

  @override
  String get tagCreateHint => 'Escriu i prem Retorn per afegir o crear';

  @override
  String get tagNoCategories => 'Encara no hi ha cap categoria creada';

  @override
  String get imprintSearch => 'Cercar segell editorial';

  @override
  String get requiredField => 'Camp obligatori';

  @override
  String get statusWantToRead => 'Per llegir';

  @override
  String get statusReading => 'Llegint';

  @override
  String get statusRead => 'Llegit';

  @override
  String get statusAbandoned => 'Abandonat';

  @override
  String get statusPaused => 'En pausa';

  @override
  String get ownershipStatusBought => 'Comprat';

  @override
  String get ownershipStatusGifted => 'Regalat';

  @override
  String get ownershipStatusBorrowed => 'Deixat';

  @override
  String get ownershipStatusReturned => 'Retornat';

  @override
  String get ownershipStatusSold => 'Venut';

  @override
  String get ownershipStatusOther => 'Altre';

  @override
  String get formatPaperback => 'Tapa blana';

  @override
  String get formatHardcover => 'Tapa dura';

  @override
  String get formatLeatherbound => 'Pell';

  @override
  String get formatRustic => 'Rústica';

  @override
  String get formatDigital => 'Digital';

  @override
  String get formatOther => 'Altre';

  @override
  String get bookDetailNotFound => 'Llibre no trobat';

  @override
  String get bookDetailPagePickerTitle => 'Pàgina actual';

  @override
  String get bookDetailNotesTitle => 'Notes personals';

  @override
  String get bookDetailNotesHint => 'Escriu les teves notes aquí...';

  @override
  String get bookDetailNotesEmpty => 'Toca per afegir notes...';

  @override
  String get bookDetailDeleteTitle => 'Eliminar llibre';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Vols eliminar \"$title\"? Aquesta acció no es pot desfer.';
  }

  @override
  String get bookDetailDuplicateTitle => 'Duplicar llibre';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return 'Vols crear una còpia exacta de \"$title\"?';
  }

  @override
  String get bookDetailNewReadingWholeBook => 'Tot el llibre';

  @override
  String get bookDetailNewReadingWholeBookDescription =>
      'Es registrarà una relectura completa a partir d\'avui.';

  @override
  String get bookDetailNewReadingSections => 'Seccions';

  @override
  String bookDetailNewReadingSectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seccions',
      one: '1 secció',
    );
    return '$_temp0';
  }

  @override
  String bookDetailNewReadingReadCount(Object count) {
    return 'Llegida ${count}x';
  }

  @override
  String get bookDetailNewReadingSelectSections =>
      'Seleccionar seccions per rellegir';

  @override
  String get bookDetailStartNewReadingPrompt =>
      'Vols començar una nova lectura?';

  @override
  String get bookDetailStartNewReadingTitle => 'Nova lectura';

  @override
  String get bookDetailStartNewReadingButton => 'Començar nova lectura';

  @override
  String get selectAll => 'Seleccionar-ho tot';

  @override
  String get bookDetailDeleteReadPrompt =>
      'Vols eliminar l\'última lectura en curs? Es perdran les dates d\'aquesta sessió.';

  @override
  String get bookDetailReadHistoryTitle => 'HISTORIAL DE LECTURES';

  @override
  String get bookDetailReadOngoing => 'en curs';

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
      'Vols eliminar aquesta entrada de l\'historial?';

  @override
  String get bookDetailReadNumberLabel => 'Número de lectura';

  @override
  String get bookDetailFieldPages => 'PÀGINES';

  @override
  String get bookDetailFieldCategories => 'CATEGORIES';

  @override
  String get bookDetailFieldFormat => 'Format';

  @override
  String get bookDetailFieldRating => 'VALORACIÓ';

  @override
  String get bookDetailFieldImprintSection => 'SEGELL EDITORIAL';

  @override
  String get bookDetailFieldPersonalNotes => 'NOTES PERSONALS';

  @override
  String get bookDetailFieldAdded => 'Afegit';

  @override
  String get bookDetailFieldStarted => 'Inici lectura';

  @override
  String get bookDetailFieldFinished => 'Fi lectura';

  @override
  String get fieldOwnershipStatus => 'Estat de propietat';

  @override
  String get ownershipHistoryTitle => 'HISTORIAL DE PROPIETAT';

  @override
  String get ownershipLogEmpty =>
      'No hi ha cap esdeveniment de propietat registrat.';

  @override
  String get ownershipEventPerson => 'Persona / Qui';

  @override
  String get ownershipEventDate => 'Data';

  @override
  String get ownershipEventNotes => 'Notes';

  @override
  String pageProgress(String current, String total, String percent) {
    return '$current / $total pàgs. · $percent%';
  }

  @override
  String pageProgressShort(String current, String total) {
    return '$current / $total';
  }

  @override
  String pageSuffix(int count) {
    return '$count pàgs.';
  }

  @override
  String get pagesLabel => 'pàgines';

  @override
  String get shelvesTitle => 'Prestatgeries';

  @override
  String get shelvesSectionByStatus => 'Per estat';

  @override
  String get shelvesSectionMine => 'Prestatgeries';

  @override
  String get shelvesSectionManagement => 'Gestió';

  @override
  String get shelfAllBooks => 'Tots els llibres';

  @override
  String get shelfReading => 'Llegint';

  @override
  String get shelfRead => 'Llegits';

  @override
  String booksReadProgress(int readCount, int totalCount) {
    return '$readCount / $totalCount llibres llegits';
  }

  @override
  String get shelfWantToRead => 'Per llegir';

  @override
  String get shelfAbandoned => 'Abandonats';

  @override
  String get shelfPaused => 'En pausa';

  @override
  String get shelfNewTooltip => 'Nova prestatgeria';

  @override
  String get shelfEmpty => 'No tens cap prestatgeria personalitzada';

  @override
  String get shelfEmptySubtitle => 'Organitza les teves lectures com vulguis';

  @override
  String get shelvesAddFirstShelf => 'Crear prestatgeria';

  @override
  String get shelfBooksEmpty => 'Sense llibres en aquesta prestatgeria';

  @override
  String get shelfStatusBooksEmpty => 'No hi ha cap llibre aquí';

  @override
  String get shelfFormNew => 'Nova prestatgeria';

  @override
  String get shelfFormEdit => 'Editar prestatgeria';

  @override
  String get shelfFormNameLabel => 'Nom de la prestatgeria';

  @override
  String get collectionNameLabel => 'Nom de la col·lecció';

  @override
  String get shelfFormSectionStatus => 'Estat de lectura';

  @override
  String get shelfFormSectionTitle => 'Títol';

  @override
  String get shelfFormSectionAuthor => 'Autor';

  @override
  String get shelfFormSectionPublisher => 'Editorial';

  @override
  String get shelfFormSectionIsbn => 'ISBN';

  @override
  String get shelfFormSectionCollection => 'Col·lecció';

  @override
  String get shelfFormSectionCategories => 'Categories';

  @override
  String get shelfFormSectionImprint => 'Segell editorial';

  @override
  String get shelfFormHintTitle => 'Cerca al títol';

  @override
  String get shelfFormHintAuthor => 'Nom de l\'autor';

  @override
  String get shelfFormHintPublisher => 'Nom de l\'editorial';

  @override
  String get shelfFormHintIsbn => 'ISBN';

  @override
  String get shelfFormHintCollection => 'Nom de la col·lecció';

  @override
  String get shelfFormStatusAny => 'Qualsevol';

  @override
  String get shelfOptionEdit => 'Editar prestatgeria';

  @override
  String get shelfOptionDelete => 'Eliminar';

  @override
  String get shelfStatusLabelReading => 'Llegint';

  @override
  String get shelfStatusLabelRead => 'Llegits';

  @override
  String get shelfStatusLabelWantToRead => 'Per llegir';

  @override
  String get shelfStatusLabelAbandoned => 'Abandonats';

  @override
  String get shelfStatusLabelPaused => 'En pausa';

  @override
  String get managementCategories => 'Categories';

  @override
  String get managementCategoryCount => 'Núm. de llibres';

  @override
  String get managementImprints => 'Segells';

  @override
  String get managementCollections => 'Col·leccions';

  @override
  String get managementCategoryCloudCurve => 'Corba algorítmica (Llibres)';

  @override
  String get tagNone => 'Encara no hi ha cap categoria';

  @override
  String get tagNoneSubtitle =>
      'Les categories t\'ajuden a trobar llibres i a construir un mapa mental de la teva biblioteca';

  @override
  String get categoriesAddFirst => 'Nova categoria';

  @override
  String get tagNew => 'Nova categoria';

  @override
  String get tagNewDialogTitle => 'Nova categoria';

  @override
  String get tagNameLabel => 'Nom';

  @override
  String get tagColorLabel => 'Color';

  @override
  String get tagDeleteTitle => 'Eliminar categoria';

  @override
  String tagDeleteConfirm(String name) {
    return 'Vols eliminar \"$name\"?';
  }

  @override
  String get imprintNone => 'Encara no hi ha cap segell';

  @override
  String get imprintNoneSubtitle =>
      'Agrupa els teus llibres per editorials o els seus segells';

  @override
  String get imprintsAddFirst => 'Afegir segell';

  @override
  String get imprintNew => 'Nou segell';

  @override
  String get imprintNewDialogTitle => 'Nou segell editorial';

  @override
  String get imprintEditDialogTitle => 'Editar segell';

  @override
  String get imprintNameLabel => 'Nom del segell';

  @override
  String get imprintAddImageHint => 'Prem per afegir una imatge';

  @override
  String get imprintChangeImageHint => 'Prem per canviar la imatge';

  @override
  String get imprintUrlDialogTitle => 'URL de la imatge';

  @override
  String get imprintUrlHint => 'https://exemple.com/segell.jpg';

  @override
  String get imprintDeleteTitle => 'Eliminar segell';

  @override
  String imprintDeleteConfirm(String name) {
    return 'Vols eliminar \"$name\"?';
  }

  @override
  String get imprintNoImprints => 'No hi ha cap segell creat';

  @override
  String get collectionNone => 'Encara no hi ha cap col·lecció';

  @override
  String get collectionNoneSubtitle =>
      'Crea col·leccions i organitza els teus llibres';

  @override
  String get collectionsAddFirst => 'Nova col·lecció';

  @override
  String get collectionDeleteTitle => 'Eliminar col·lecció';

  @override
  String collectionDeleteConfirm(String name) {
    return 'Vols eliminar \"$name\"?';
  }

  @override
  String get onboardingWelcomeTitle => 'Benvingut a Openshelf';

  @override
  String get onboardingWelcomeSub => 'La teva biblioteca personal, reimaginada';

  @override
  String get onboardingOrganizeTitle => 'Organitza el teu món';

  @override
  String get onboardingOrganizeSub =>
      'Crea prestatgeries intel·ligents i col·leccions temàtiques';

  @override
  String get onboardingProgressTitle => 'Segueix el teu progrés';

  @override
  String get onboardingProgressSub =>
      'Objectius de lectura i estadístiques detallades';

  @override
  String get onboardingAddTitle => 'Afegeix a l\'instant';

  @override
  String get onboardingAddSub => 'Escaneja codis de barres o cerca al núvol';

  @override
  String get onboardingNext => 'Següent';

  @override
  String get onboardingStart => 'Comença ara';

  @override
  String get settingsApplyIcon => 'Aplicar canvi d\'icona';

  @override
  String get settingsDynamicIcon => 'Icona de l\'aplicació dinàmica';

  @override
  String get settingsDynamicIconSub =>
      'Canvia l\'icona de la pantalla d\'inici perquè coincideixi amb el color triat (L\'aplicació es reiniciarà)';

  @override
  String get settingsLibraryColumns => 'Columnes a la biblioteca';

  @override
  String get settingsLibraryColumnsSub =>
      'Ajusta el nombre de llibres per fila a la vista de quadrícula';

  @override
  String get settingsTitle => 'Ajusts';

  @override
  String get settingsSectionAppearance => 'Aparença';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema (automàtic)';

  @override
  String get settingsLanguageSpanish => 'Espanyol';

  @override
  String get settingsLanguageEnglish => 'Anglès';

  @override
  String get settingsLanguageFrench => 'Francès';

  @override
  String get settingsLanguageItalian => 'Italià';

  @override
  String get settingsLanguageCatalan => 'Català';

  @override
  String get settingsLanguagePortuguese => 'Portuguès (Portugal)';

  @override
  String get settingsLanguagePortugueseBR => 'Portuguès (Brasil)';

  @override
  String get settingsThemeMode => 'Mode de tema';

  @override
  String get settingsThemeLight => 'Clar';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeDark => 'Fosc';

  @override
  String get settingsAccentColor => 'Color d\'accent';

  @override
  String get settingsAccentColorHint => 'Toca un color per aplicar-lo';

  @override
  String get settingsSectionStorage => 'Emmagatzematge';

  @override
  String get settingsCoversFolder => 'Carpeta de portades';

  @override
  String get settingsDatabase => 'Base de dades';

  @override
  String get settingsDefaultDir => 'Directori per defecte';

  @override
  String get settingsDbMoveTitle => 'Moure la base de dades';

  @override
  String get settingsDbMoveContent =>
      'Moure la base de dades requereix reiniciar l\'aplicació. Les dades es copiaran al nou directori. Vols continuar?';

  @override
  String get settingsDbMoveConfirm => 'Moure i reiniciar';

  @override
  String get settingsSectionSearch => 'Cerca de llibres';

  @override
  String get settingsSearchServer => 'Servidor';

  @override
  String get settingsSearchServerHint =>
      'S\'utilitzarà per cercar llibres per ISBN o títol';

  @override
  String get settingsSectionData => 'Gestió de dades';

  @override
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => 'Importar llibres';

  @override
  String get dataManagementExport => 'Exportar llibres';

  @override
  String dataManagementImportHint(String source) {
    return 'Importar des de CSV de $source';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return 'Importar des de JSON de $source';
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
  String get dataManagementRestoreBackup => 'Restaurar còpia de seguretat';

  @override
  String get dataManagementRestoreBackupHint =>
      'Restaurar des de CSV/ZIP de OpenShelf';

  @override
  String get dataManagementCreateBackup => 'Crear còpia de seguretat';

  @override
  String get dataManagementCreateBackupHint => 'Full export with covers option';

  @override
  String get settingsImportBookshelf => 'Importar des de Bookshelf';

  @override
  String get settingsImportBookshelfHint =>
      'Importar llibres des d\'un fitxer CSV';

  @override
  String get settingsExportCsv => 'Exportar biblioteca';

  @override
  String get settingsExportCsvHint =>
      'Exportar tots els llibres a un fitxer CSV';

  @override
  String get settingsFullBackup => 'Restaurar biblioteca';

  @override
  String get settingsFullBackupHint =>
      'Restaurar llibres des d\'una còpia de seguretat CSV';

  @override
  String get settingsAllFilesAccess => 'Accés a tots els fitxers';

  @override
  String get settingsAllFilesAccessSub =>
      'Necessari per moure la base de dades a carpetes externes (Android 11+)';

  @override
  String get settingsAllFilesAccessInfo =>
      'Aquest permís permet a Openshelf gestionar fitxers fora del seu directori privat. És necessari per moure la base de dades a una carpeta personalitzada.';

  @override
  String get settingsAutoNoCoverTitle => 'Prestatgeria sense portades';

  @override
  String get settingsAutoNoCoverSub =>
      'Crea automàticament una prestatgeria si falten portades';

  @override
  String get noCoverShelfTitle => 'Llibres sense portada';

  @override
  String get settingsCompressImagesTitle => 'Comprimir portades automàticament';

  @override
  String get settingsCompressImagesSub =>
      'Redueix el pes de les imatges en desar-les o importar-les';

  @override
  String get settingsBatchCompressTitle => 'Optimitzar la biblioteca ara';

  @override
  String get settingsBatchCompressSub =>
      'Comprimeix totes les portades existents que no estiguin optimitzades';

  @override
  String settingsBatchCompressSuccess(int count) {
    return 'S\'han optimitzat $count portades.';
  }

  @override
  String get exportTitle => 'Exportar biblioteca';

  @override
  String get exportCoversPrompt =>
      'Vols incloure les imatges de les portades a la còpia de seguretat? (Es crearà un fitxer ZIP juntament amb el CSV)';

  @override
  String get importRestoreCoversTitle => 'Restaurar portades';

  @override
  String get importRestoreCoversPrompt =>
      'Tens també un fitxer ZIP amb les portades per restaurar?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get devDeleteAllBooks => 'ESBORRAR TOTS ELS LLIBRES (DEV)';

  @override
  String get settingsDevClearDbSub =>
      'Eina de desenvolupador: netejar base de dades';

  @override
  String get settingsDevDbCleared => 'Base de dades netejada';

  @override
  String get settingsImportSelectBackup =>
      'Seleccionar còpia de seguretat d\'Openshelf';

  @override
  String get settingsImportSelectCovers =>
      'Seleccionar ZIP de portades d\'Openshelf';

  @override
  String get devDeleteConfirmTitle => 'Vols buidar la biblioteca?';

  @override
  String get devDeleteConfirmContent =>
      'Això eliminará permanentment TOTS els llibres i categories. Només per a proves. Vols continuar?';

  @override
  String importSuccess(int count) {
    return 'Importació completada: s\'han afegit $count llibres.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Importació parcial: $added afegits, $skipped omesos.';
  }

  @override
  String get settingsApiKeyTitle => 'Clau de l\'API de Google Books';

  @override
  String get settingsApiKeyConfigured =>
      'Clau configurada. Google Books està disponible.';

  @override
  String get settingsApiKeyMissing =>
      'Sense clau, Google Books utilitzarà Open Library com a alternativa.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Mostra';

  @override
  String get settingsApiKeyHide => 'Amaga';

  @override
  String get settingsApiKeySave => 'Desar la clau';

  @override
  String get settingsApiKeySaved => 'Clau desada';

  @override
  String get settingsApiKeyClear => 'Esborrar la clau';

  @override
  String get settingsApiKeyHowTo => 'Com obtenir-la';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'Com obtenir una clau de Google Books';

  @override
  String get settingsApiKeyStep1 =>
      'Obre console.cloud.google.com i inicia sessió amb el teu compte de Google.';

  @override
  String get settingsApiKeyStep2 =>
      'Crea un projecte nou (el nom és indiferent).';

  @override
  String get settingsApiKeyStep3 =>
      'Ves a API i serveis → Biblioteca, cerca \"Books API\" i activa-la.';

  @override
  String get settingsApiKeyStep4 =>
      'Ves a API i serveis → Credencials → Crear credencials → Clau d\'API.';

  @override
  String get settingsApiKeyStep5 =>
      'Opcional però recomanat: restringeix la clau només a la Books API.';

  @override
  String get settingsApiKeyStep6 =>
      'Copia la clau resultant (comença per \"AIza…\") i enganxa-la al camp de dalt.';

  @override
  String get settingsApiKeyNote =>
      'La clau és gratuïta i permet fins a 1.000 cerques diàries. No es comparteix amb ningú: es desa només en aquest dispositiu.';

  @override
  String get bookSearchHint => 'Títol, autor o ISBN...';

  @override
  String get bookSearchPrompt => 'Cerca per títol, autor o ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Sense resultats per a \"$query\"';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return 'Resultats de: $providers.';
  }

  @override
  String get bookSearchRecommended => 'RECOMANAT PER OPENSHELF';

  @override
  String get bookSearchRecommendedSource => 'Recomanat per Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Open Library';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get searchTabStatus => 'Estat';

  @override
  String get searchTabImprint => 'Segell';

  @override
  String get searchTabCategory => 'Categoria';

  @override
  String get searchTabCollection => 'Col·lecció';

  @override
  String searchFilterStatus(String value) {
    return 'Estat: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Segell: $value';
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
      other: '$count filtres actius',
      one: '1 filtre actiu',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => 'Desar com a prestatgeria';

  @override
  String get shelfShowInLibrary => 'Mostra a la biblioteca';

  @override
  String get searchClearAll => 'Neteja-ho tot';

  @override
  String get addedToLibrary => 'Afegit a la biblioteca';

  @override
  String get errorDuplicateIsbn => 'Ja és a la biblioteca';

  @override
  String get bookDuplicateTitle => 'Llibre duplicat';

  @override
  String bookDuplicateContent(String isbn) {
    return 'Ja tens un llibre amb l\'ISBN $isbn a la teva biblioteca.';
  }

  @override
  String get bookSearchErrorNoApiKey =>
      'Google Books requereix una clau d\'API.\nConfigura-la a Ajusts → Cerca de llibres.';

  @override
  String get bookSearchErrorRateLimit =>
      'Google Books ha limitat les peticions.\nEspera un moment i torna-ho a provar.';

  @override
  String get bookSearchErrorNetwork =>
      'No s\'ha pogut connectar amb cap servidor.\nComprova la teva connexió i torna-ho a provar.';

  @override
  String get coverPickerTitle => 'Portades';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults =>
      'No s\'han trobat portades per a aquest llibre.';

  @override
  String get coverPickerNetworkError =>
      'No s\'ha pogut connectar. Comprova la teva connexió.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Estadístiques';

  @override
  String get statsPlaceholder => 'Les teves estadístiques apareixeran aquí';

  @override
  String get statsEmptySubtitle =>
      'Afegeix ginys per veure els teus hàbits de lectura, objectius i rècords personals.';

  @override
  String get statsAddFirstWidget => 'Afegir primer giny';

  @override
  String get statsAddWidgetTitle => 'Afegir giny';

  @override
  String get statsGoalTargetShelf => 'Prestatgeria objectiu';

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
  String get statsGoalTitle => 'OBJECTIU';

  @override
  String get statsGoalFullTitle => 'OBJECTIU DE LECTURA';

  @override
  String get statsGoalUnitBooks => 'llibres';

  @override
  String get statsGoalUnitPages => 'pàgs.';

  @override
  String statsGoalRemaining(int count) {
    return 'En falten $count';
  }

  @override
  String get statsGoalCompleted => 'Fet!';

  @override
  String get statsGoalNew => 'Nou objectiu';

  @override
  String get statsGoalEdit => 'Editar objectiu';

  @override
  String get statsGoalDelete => 'Eliminar';

  @override
  String get statsGoalNameLabel => 'Nom (ex: Repte 2026)';

  @override
  String get statsGoalTypeLabel => 'Tipus';

  @override
  String get statsGoalTypeBooks => 'Llibres llegits';

  @override
  String get statsGoalTypePages => 'Pàgines llegides';

  @override
  String get statsGoalTargetLabel => 'Objectiu numèric';

  @override
  String get statsGoalFromLabel => 'Des de';

  @override
  String get statsGoalToLabel => 'Fins a';

  @override
  String get statsPagesTitle => 'PÀGINES';

  @override
  String get statsPagesSub => 'pàgines llegides';

  @override
  String get statsStreakTitle => 'RATXA';

  @override
  String get statsStreakSub => 'dies seguits';

  @override
  String get statsStatusTitle => 'ESTATS';

  @override
  String get statsAddedTitle => 'LLIBRES AFEGITS';

  @override
  String get statsAddedNoData => 'Sense dades';

  @override
  String get statsCategoriesTitle => 'CATEGORIES';

  @override
  String get statsYearsTitle => 'ANYS DE PUBLICACIÓ';

  @override
  String get statsReadingTitle => 'LECTURA';

  @override
  String get statsReadingNowTitle => 'LLEGINT ARA';

  @override
  String get statsReadingNone => 'Res en lectura';

  @override
  String get statsReadByYearTitle => 'LLIBRES LLEGITS PER ANY';

  @override
  String get statsCollectionsTitle => 'COL·LECCIONS';

  @override
  String get statsLastAddedTitle => 'ÚLTIMS AFEGITS';

  @override
  String get statsDailyReadingTitle => 'LECTURA DIÀRIA';

  @override
  String get statsAvgPagesTitle => 'MITJANA DE PÀGINES';

  @override
  String get statsAvgPagesSub => 'pàgines per llibre';

  @override
  String get statsOptPagesTitle => 'Total de pàgines';

  @override
  String get statsOptPagesSub => 'Total de pàgines llegides';

  @override
  String get statsOptStreakTitle => 'Ratxa';

  @override
  String get statsOptStreakSub => 'Dies consecutius llegint';

  @override
  String get statsOptGoalTitle => 'Objectiu de lectura';

  @override
  String get statsOptGoalSub => 'Llibres, prestatgeries o col·leccions';

  @override
  String get statsOptStatusTitle => 'Estats de lectura';

  @override
  String get statsOptStatusSub => 'Libros por estado';

  @override
  String get statsOptCurrentTitle => 'Llibre actual';

  @override
  String get statsOptCurrentSub => 'Progrés de lectura en curs';

  @override
  String get statsOptAddedTimeTitle => 'Llibres afegits';

  @override
  String get statsOptAddedTimeSub => 'Gràfic temporal d\'adquisicions';

  @override
  String get statsOptCategoriesTitle => 'Categories';

  @override
  String get statsOptCategoriesSub => 'Distribució per gèneres';

  @override
  String get statsOptYearsTitle => 'Any de publicació';

  @override
  String get statsOptYearsSub => 'Histograma històric';

  @override
  String get statsOptReadYearTitle => 'Llegits per any';

  @override
  String get statsOptReadYearSub => 'Gràfic de lectura anual';

  @override
  String get statsOptCollectionsTitle => 'Col·leccions';

  @override
  String get statsOptCollectionsSub => 'Libros por colección';

  @override
  String get statsOptLastAddedTitle => 'Últims afegits';

  @override
  String get statsOptLastAddedSub => 'Acabats d\'arribar';

  @override
  String get statsOptAvgPagesTitle => 'Extensió mitjana';

  @override
  String get statsOptAvgPagesSub => 'Average pages per book';

  @override
  String get statsOptReadListTitle => 'Llista de llegits';

  @override
  String get statsOptReadListSub => 'Llibres llegits en un període';

  @override
  String get statsOptAvgCompletionTitle => 'Temps de lectura';

  @override
  String get statsOptAvgCompletionSub => 'Average time to finish a book';

  @override
  String get statsOptDailyReadingTitle => 'Lectura diària';

  @override
  String get statsOptDailyReadingSub => 'Pages read per day';

  @override
  String statsAvgCompletionValue(String days) {
    return '$days dies';
  }

  @override
  String get statsPeriodThisMonth => 'Llegits aquest mes';

  @override
  String get statsPeriodLast3Months => 'Últims 3 mesos';

  @override
  String get statsPeriodThisYear => 'Llegits aquest any';

  @override
  String get statsPeriodLast3Years => 'Últims 3 anys';

  @override
  String get tabMore => 'més';

  @override
  String get sortTitle => 'Ordena';

  @override
  String get openSettings => 'Obre els ajusts';

  @override
  String get permissionRequired => 'Permís necessari';

  @override
  String get paginationMarkersAndIndices => 'Seccions i marcadors';

  @override
  String get paginationSaveProgress => 'Desar el progrés';

  @override
  String get paginationAllPagesAssigned =>
      'Totes les pàgines ja han estat assignades.';

  @override
  String get paginationChooseColor => 'Tria un color';

  @override
  String paginationSegmentRequired(Object index) {
    return 'Segment $index: Tots els camps de pàgina són obligatoris.';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return 'Segment $index: L\'inici no pot ser major que la fi.';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return 'Segment $index: Els valors excedeixen el total de pàgines ($total).';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return 'El segment $index1 se solapa amb el segment $index2';
  }

  @override
  String get paginationAdvancedConfig => 'Configuració avançada';

  @override
  String get paginationBlocksSegments => 'BLOCS / SEGMENTS';

  @override
  String get paginationNoSegmentsDefined =>
      'No hi ha cap segment definit. S\'utilitza el rang 1-N per defecte.';

  @override
  String get paginationAddBlock => 'Afegir bloc';

  @override
  String get paginationAllPagesAssignedNote =>
      'Nota: Ja has assignat totes les pàgines disponibles.';

  @override
  String paginationPagesRemainingWarning(int count) {
    return 'Avís: Qeden $count pàgines físiques sense assignar.';
  }

  @override
  String get paginationPhysicalTotalNote =>
      'Nota: Total pages refer to the physical pages of the book (total sheets).';

  @override
  String get paginationCorrectErrors => 'CORREGEIX ELS SEGÜENTS ERRORS:';

  @override
  String get paginationMarkersLabels => 'MARCADORS / ETIQUETES';

  @override
  String get paginationMarkerDefaultName => 'Marcador';

  @override
  String get paginationSegmentsDefaultName => 'Bloc';

  @override
  String get paginationAddMarker => 'Afegir marcador';

  @override
  String get paginationLabelOptional => 'Etiqueta (opcional)';

  @override
  String get paginationType => 'Tipus:';

  @override
  String get paginationArabic => 'Aràbic';

  @override
  String get paginationRoman => 'Romà';

  @override
  String get paginationOffset => 'Desplaçament (offset)';

  @override
  String get paginationMarkerLabel => 'Etiqueta del marcador';

  @override
  String get paginationVisualPage => 'Pàgina visual';

  @override
  String get paginationVisualPageHint => 'Ex: xiv o 501';

  @override
  String paginationPhysicalLabel(Object page) {
    return 'Física: $page';
  }

  @override
  String get paginationAdjustsAutomatically => 'S\'ajusta automàticament';

  @override
  String get paginationVisualMode => 'Mode visual';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return 'Equival a físiques: $start - $end';
  }

  @override
  String paginationSectionLabel(int index) {
    return 'Secció $index';
  }

  @override
  String paginationProgress(String current, String total) {
    return '$current / $total';
  }

  @override
  String get paginationCurrentPageShort => 'Pàg.';

  @override
  String get paginationStartPhysical => 'Inici (físic)';

  @override
  String get paginationEndPhysical => 'Fi (físic)';

  @override
  String get paginationStartVisual => 'Inici (visual)';

  @override
  String get paginationEndVisual => 'Fi (visual)';

  @override
  String get paginationAdvancedButton => 'Avançada';

  @override
  String get unknownAuthor => 'Desconegut';

  @override
  String get storagePermissionExplanation =>
      'Per seleccionar una portada cal que concedeixis accés a l\'emmagatzematge. Pots fer-ho des dels ajusts de l\'aplicació.';

  @override
  String get cameraPermissionExplanation =>
      'Per fer una foto cal que concedeixis accés a la càmera. Pots fer-ho des dels ajusts de l\'aplicació.';
}
