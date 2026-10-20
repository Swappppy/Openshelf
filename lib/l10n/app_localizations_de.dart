// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Openshelf';

  @override
  String errorPrefix(String message) {
    return 'Fehler: $message';
  }

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String criticalStartError(String error) {
    return 'Fehler beim Starten der Anwendung: $error';
  }

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navShelves => 'Regale';

  @override
  String get navStats => 'Statistiken';

  @override
  String get libraryTitle => 'Bibliothek';

  @override
  String get libraryEmpty => 'Deine Bibliothek ist leer';

  @override
  String get libraryEmptyHint => 'Was wird dein erstes Buch sein?';

  @override
  String get libraryAddFirstBook => 'Erstes Buch hinzufügen';

  @override
  String get libraryNoResults => 'Keine Ergebnisse';

  @override
  String get libraryNoResultsHint => 'Versuche es mit anderen Filtern';

  @override
  String get addBook => 'Buch hinzufügen';

  @override
  String get displaySettings => 'In Bibliothek anzeigen';

  @override
  String get displaySettingsDragHint => 'Zum Neuordnen ziehen';

  @override
  String get settingsButton => 'Einstellungen';

  @override
  String get fieldAuthor => 'Autor';

  @override
  String get fieldPublisher => 'Verlag';

  @override
  String get fieldYear => 'Erscheinungsjahr';

  @override
  String get fieldRating => 'Bewertung';

  @override
  String get fieldTags => 'Kategorien';

  @override
  String get fieldReadingProgress => 'Lesefortschritt';

  @override
  String get fieldStatusChip => 'Status-Chip';

  @override
  String get searchHint => 'Nach Titel suchen...';

  @override
  String get filterAuthor => 'Autor';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Verlag';

  @override
  String get filterCollection => 'Sammlung';

  @override
  String get filterImprintLabel => 'Verlagsmarke';

  @override
  String imprintBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher',
      one: '1 Buch',
    );
    return '$_temp0';
  }

  @override
  String get filterTagsLabel => 'Kategorien';

  @override
  String get done => 'Fertig';

  @override
  String get loading => 'Laden...';

  @override
  String get loadingImport => 'Bücher werden importiert, bitte warten...';

  @override
  String get loadingExport => 'Bücher werden exportiert, bitte warten...';

  @override
  String get exportProgressData => 'Daten werden exportiert...';

  @override
  String get exportProgressMedia => 'Mediendateien werden zusammengestellt...';

  @override
  String get exportProgressCompress => 'Sicherung wird komprimiert...';

  @override
  String get exportProgressFinalize => 'Teilen-Menü wird geöffnet...';

  @override
  String exportSaveSuccess(String path) {
    return 'Sicherung gespeichert unter $path';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get create => 'Erstellen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get duplicate => 'Duplizieren';

  @override
  String get photo => 'Foto';

  @override
  String get url => 'URL';

  @override
  String get download => 'Herunterladen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get share => 'Teilen';

  @override
  String get saveToDevice => 'Auf Gerät speichern';

  @override
  String get addBookModalTitle => 'Buch hinzufügen';

  @override
  String get addBookModalSubtitle =>
      'Wähle, wie du dein Buch hinzufügen möchtest';

  @override
  String get addManually => 'Manuell hinzufügen';

  @override
  String get addManuallySubtitle => 'Trage die Daten selbst ein';

  @override
  String get searchBook => 'Buch suchen';

  @override
  String get searchBookSubtitle => 'Nach Titel, Autor oder ISBN';

  @override
  String get scanBarcode => 'Barcode scannen';

  @override
  String get scanBarcodeSubtitle => 'Kamera auf die ISBN richten';

  @override
  String get scanIsbnText => 'ISBN-Nummer scannen';

  @override
  String get scanIsbnTextSubtitle => 'Auf die gedruckte Nummer richten';

  @override
  String get scanIsbnSelect => 'Tippe auf eine ISBN, um sie auszuwählen';

  @override
  String get scanOcrHoldMessage =>
      'Halte das Bild für ein paar Sekunden ruhig...';

  @override
  String get scanBarcodePermission =>
      'Kamerazugriff zum Scannen von Barcodes erforderlich';

  @override
  String get scanBatch => 'Stapel-Scan';

  @override
  String get scanBatchSubtitle => 'Mehrere Bücher nacheinander scannen';

  @override
  String get scanModeBarcode => 'Barcode';

  @override
  String get scanModeIsbn => 'ISBN-Nummer';

  @override
  String get bookFormNewTitle => 'Neues Buch';

  @override
  String get bookFormEditTitle => 'Buch bearbeiten';

  @override
  String get tabMain => 'Hauptseite';

  @override
  String get tabDetails => 'Details';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldSubtitle => 'Untertitel';

  @override
  String get fieldDescription => 'Beschreibung';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Sprache';

  @override
  String get fieldIsTranslation => 'Ist eine Übersetzung?';

  @override
  String get fieldOriginalTitle => 'Originaltitel';

  @override
  String get fieldOriginalLanguage => 'Originalsprache';

  @override
  String get fieldTranslator => 'Übersetzer';

  @override
  String get fieldReads => 'Lesungen';

  @override
  String get fieldCopies => 'Exemplare';

  @override
  String get fieldTotalPages => 'Seiten insgesamt';

  @override
  String get fieldTotalBooks => 'Bücher insgesamt';

  @override
  String get fieldCurrentPage => 'Aktuelle Seite';

  @override
  String get fieldNotes => 'Notizen';

  @override
  String get fieldCollection => 'Sammlung / Reihe';

  @override
  String get fieldCollectionNumber => 'Nummer in der Sammlung';

  @override
  String get sectionBasicInfo => 'Grundlegende Informationen';

  @override
  String get sectionCategories => 'Kategorien';

  @override
  String get sectionReadingStatus => 'Lesestatus';

  @override
  String get sectionFormat => 'Format';

  @override
  String get sectionRating => 'Bewertung';

  @override
  String get sectionImprint => 'Verlagsmarke';

  @override
  String get coverPickPhoto => 'Foto';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Suchen';

  @override
  String get coverUrlDialogTitle => 'Cover-URL';

  @override
  String get coverUrlHint => 'https://beispiel.de/cover.jpg';

  @override
  String get coverDownloadError => 'Bild konnte nicht heruntergeladen werden';

  @override
  String get imageProcessError => 'Bild konnte nicht verarbeitet werden';

  @override
  String get imageProcessing => 'Bild wird verarbeitet...';

  @override
  String get imagePreparing => 'Bild wird vorbereitet...';

  @override
  String get imageOptimizing => 'Bild wird optimiert...';

  @override
  String get cropCoverTitle => 'Cover zuschneiden';

  @override
  String get cropImprintTitle => 'Verlagsmarke zuschneiden';

  @override
  String get tagSearchOrCreate => 'Kategorie suchen oder erstellen';

  @override
  String get tagCreateHint =>
      'Tippen und Eingabe drücken zum Hinzufügen oder Erstellen';

  @override
  String get tagNoCategories => 'Noch keine Kategorien erstellt';

  @override
  String get imprintSearch => 'Verlagsmarke suchen';

  @override
  String get requiredField => 'Pflichtfeld';

  @override
  String get statusWantToRead => 'Möchte ich lesen';

  @override
  String get statusReading => 'Lese ich gerade';

  @override
  String get statusRead => 'Gelesen';

  @override
  String get statusAbandoned => 'Abgebrochen';

  @override
  String get statusPaused => 'Pausiert';

  @override
  String get ownershipStatusBought => 'Gekauft';

  @override
  String get ownershipStatusGifted => 'Geschenkt';

  @override
  String get ownershipStatusBorrowed => 'Ausgeliehen';

  @override
  String get ownershipStatusReturned => 'Zurückgegeben';

  @override
  String get ownershipStatusSold => 'Verkauft';

  @override
  String get ownershipStatusOther => 'Sonstiges';

  @override
  String get formatPaperback => 'Taschenbuch (Paperback)';

  @override
  String get formatHardcover => 'Gebundenes Buch (Hardcover)';

  @override
  String get formatLeatherbound => 'Ledereinband';

  @override
  String get formatRustic => 'Broschiert';

  @override
  String get formatDigital => 'Digital / E-Book';

  @override
  String get formatOther => 'Sonstiges';

  @override
  String get bookDetailNotFound => 'Buch nicht gefunden';

  @override
  String get bookDetailPagePickerTitle => 'Aktuelle Seite';

  @override
  String get bookDetailNotesTitle => 'Notizen';

  @override
  String get bookDetailNotesHint => 'Notizen zu diesem Buch hinzufügen...';

  @override
  String get bookDetailNotesEmpty => 'Keine Notizen vorhanden';

  @override
  String get bookDetailDeleteTitle => 'Buch löschen';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Möchtest du \"$title\" wirklich aus deiner Bibliothek löschen?';
  }

  @override
  String get bookDetailDuplicateTitle => 'Buch duplizieren';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return 'Möchtest du eine Kopie dieses Buches erstellen?';
  }

  @override
  String get bookDetailNewReadingWholeBook => 'Ganzes Buch';

  @override
  String get bookDetailNewReadingWholeBookDescription =>
      'Das gesamte Buch lesen';

  @override
  String get bookDetailNewReadingSections => 'Bestimmte Abschnitte';

  @override
  String bookDetailNewReadingSectionsCount(int count) {
    return '$count Abschnitte ausgewählt';
  }

  @override
  String bookDetailNewReadingReadCount(Object count) {
    return 'Lesung #$count';
  }

  @override
  String get bookDetailNewReadingSelectSections => 'Abschnitte auswählen';

  @override
  String get bookDetailStartNewReadingPrompt =>
      'Möchtest du eine neue Lesung für dieses Buch starten?';

  @override
  String get bookDetailStartNewReadingTitle => 'Neue Lesung starten';

  @override
  String get bookDetailStartNewReadingButton => 'Neue Lesung starten';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get bookDetailDeleteReadPrompt => 'Möchtest du diese Lesung löschen?';

  @override
  String get bookDetailReadHistoryTitle => 'Leseverlauf';

  @override
  String get bookDetailReadOngoing => 'Laufende Lesung';

  @override
  String bookDetailReadNumber(int number) {
    return 'Lesung #$number';
  }

  @override
  String bookDetailReadEditDialogTitle(Object number) {
    return 'Lesung bearbeiten';
  }

  @override
  String get bookDetailReadDeleteConfirm =>
      'Möchtest du diese Lesung wirklich löschen?';

  @override
  String get bookDetailReadNumberLabel => 'Lesung';

  @override
  String get bookDetailFieldPages => 'Seiten';

  @override
  String get bookDetailFieldCategories => 'Kategorien';

  @override
  String get bookDetailFieldFormat => 'Format';

  @override
  String get bookDetailFieldRating => 'Bewertung';

  @override
  String get bookDetailFieldImprintSection => 'Verlagsmarke';

  @override
  String get bookDetailFieldPersonalNotes => 'Persönliche Notizen';

  @override
  String get bookDetailFieldAdded => 'Hinzugefügt am';

  @override
  String get bookDetailFieldStarted => 'Begonnen am';

  @override
  String get bookDetailFieldFinished => 'Beendet am';

  @override
  String get fieldOwnershipStatus => 'Besitzstatus';

  @override
  String get ownershipHistoryTitle => 'Besitzverlauf';

  @override
  String get ownershipLogEmpty => 'Kein Besitzverlauf aufgezeichnet';

  @override
  String get ownershipEventPerson => 'Person';

  @override
  String get ownershipEventDate => 'Datum';

  @override
  String get ownershipEventNotes => 'Notizen';

  @override
  String pageProgress(String current, String total, String percent) {
    return 'Seite $current von $total';
  }

  @override
  String pageProgressShort(String current, String total) {
    return '$current / $total S.';
  }

  @override
  String pageSuffix(int count) {
    return 'S.';
  }

  @override
  String get pagesLabel => 'Seiten';

  @override
  String get shelvesTitle => 'Regale';

  @override
  String get shelvesSectionByStatus => 'Nach Status';

  @override
  String get shelvesSectionMine => 'Meine Regale';

  @override
  String get shelvesSectionManagement => 'Verwaltung';

  @override
  String get shelfAllBooks => 'Alle Bücher';

  @override
  String get shelfReading => 'Lese ich gerade';

  @override
  String get shelfRead => 'Gelesen';

  @override
  String booksReadProgress(int readCount, int totalCount) {
    return '$readCount von $totalCount Büchern gelesen';
  }

  @override
  String get shelfWantToRead => 'Möchte ich lesen';

  @override
  String get shelfAbandoned => 'Abgebrochen';

  @override
  String get shelfPaused => 'Pausiert';

  @override
  String get shelfNewTooltip => 'Neues Regal erstellen';

  @override
  String get shelfEmpty => 'Regal ist leer';

  @override
  String get shelfEmptySubtitle => 'Füge Bücher zu diesem Regal hinzu';

  @override
  String get shelvesAddFirstShelf => 'Erstes Regal hinzufügen';

  @override
  String get shelfBooksEmpty => 'Keine Bücher in diesem Regal';

  @override
  String get shelfBooksEmptyHint =>
      'Bücher, die den Kriterien entsprechen, werden hier angezeigt.';

  @override
  String get shelfStatusBooksEmpty => 'Keine Bücher in diesem Status';

  @override
  String get shelfFormNew => 'Neues Regal';

  @override
  String get shelfFormEdit => 'Regal bearbeiten';

  @override
  String get shelfFormNameLabel => 'Name des Regals';

  @override
  String get collectionNameLabel => 'Name der Sammlung';

  @override
  String get shelfFormSectionStatus => 'Nach Lesestatus filtern';

  @override
  String get shelfFormSectionTitle => 'Titel';

  @override
  String get shelfFormSectionAuthor => 'Nach Autor filtern';

  @override
  String get shelfFormSectionPublisher => 'Nach Verlag filtern';

  @override
  String get shelfFormSectionIsbn => 'Nach ISBN filtern';

  @override
  String get shelfFormSectionCollection => 'Nach Sammlung filtern';

  @override
  String get shelfFormSectionCategories => 'Nach Kategorien filtern';

  @override
  String get shelfFormSectionImprint => 'Nach Verlagsmarke filtern';

  @override
  String get shelfFormHintTitle => 'Suchen nach Titel...';

  @override
  String get shelfFormHintAuthor => 'Namen eingeben...';

  @override
  String get shelfFormHintPublisher => 'Verlagsnamen eingeben...';

  @override
  String get shelfFormHintIsbn => 'ISBN eingeben...';

  @override
  String get shelfFormHintCollection => 'Suchen nach Sammlung...';

  @override
  String get shelfFormStatusAny => 'Beliebiger Status';

  @override
  String get shelfOptionEdit => 'Bearbeiten';

  @override
  String get shelfOptionDelete => 'Löschen';

  @override
  String get shelfStatusLabelReading => 'Regal: Liest gerade';

  @override
  String get shelfStatusLabelRead => 'Regal: Gelesen';

  @override
  String get shelfStatusLabelWantToRead => 'Regal: Möchte lesen';

  @override
  String get shelfStatusLabelAbandoned => 'Regal: Abgebrochen';

  @override
  String get shelfStatusLabelPaused => 'Regal: Pausiert';

  @override
  String get managementCategories => 'Kategorien';

  @override
  String get managementCategoryCount => 'Anzahl der Bücher';

  @override
  String get managementImprints => 'Verlagsmarken';

  @override
  String get managementCollections => 'Sammlungen';

  @override
  String get managementCategoryCloudCurve => 'Kategorie-Verteilung';

  @override
  String get tagNone => 'Keine Kategorie';

  @override
  String get tagNoneSubtitle => 'Keine Kategorie zugewiesen';

  @override
  String get categoriesAddFirst => 'Erste Kategorie hinzufügen';

  @override
  String get tagNew => 'Neue Kategorie';

  @override
  String get tagNewDialogTitle => 'Neue Kategorie';

  @override
  String get tagNameLabel => 'Name';

  @override
  String get tagColorLabel => 'Kategorie-Farbe';

  @override
  String get tagDeleteTitle => 'Kategorie löschen';

  @override
  String tagDeleteConfirm(String name) {
    return 'Möchtest du die Kategorie \"$name\" wirklich löschen?';
  }

  @override
  String get imprintNone => 'Ohne Verlagsmarke';

  @override
  String get imprintNoneSubtitle => 'Keine Verlagsmarke zugewiesen';

  @override
  String get imprintsAddFirst => 'Erste Verlagsmarke hinzufügen';

  @override
  String get imprintNew => 'Neue Verlagsmarke';

  @override
  String get imprintNewDialogTitle => 'Neue Verlagsmarke';

  @override
  String get imprintEditDialogTitle => 'Verlagsmarke bearbeiten';

  @override
  String get imprintNameLabel => 'Name';

  @override
  String get imprintAddImageHint => 'Tippen zum Hinzufügen eines Bildes';

  @override
  String get imprintChangeImageHint => 'Tippen zum Ändern des Bildes';

  @override
  String get imprintUrlDialogTitle => 'Verlagsmarken-URL';

  @override
  String get imprintUrlHint => 'https://beispiel.de';

  @override
  String get imprintDeleteTitle => 'Verlagsmarke löschen';

  @override
  String imprintDeleteConfirm(String name) {
    return 'Möchtest du die Verlagsmarke \"$name\" wirklich löschen?';
  }

  @override
  String get imprintNoImprints => 'Noch keine Verlagsmarken erstellt';

  @override
  String get collectionNone => 'Ohne Sammlung';

  @override
  String get collectionNoneSubtitle => 'Keine Sammlung zugewiesen';

  @override
  String get collectionsAddFirst => 'Erste Sammlung hinzufügen';

  @override
  String get collectionDeleteTitle => 'Sammlung löschen';

  @override
  String collectionDeleteConfirm(String name) {
    return 'Möchtest du die Sammlung \"$name\" wirklich löschen?';
  }

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei Openshelf';

  @override
  String get onboardingWelcomeSub =>
      'Katalogisiere und verwalte deine persönliche Bibliothek';

  @override
  String get onboardingOrganizeTitle => 'Organisiere deine Sammlung';

  @override
  String get onboardingOrganizeSub =>
      'Erstelle eigene Regale, Kategorien und Sammlungen';

  @override
  String get onboardingProgressTitle => 'Verfolge dein Lesen';

  @override
  String get onboardingProgressSub =>
      'Verfolge deine Fortschritte und Lesestatistiken';

  @override
  String get onboardingAddTitle => 'Füge deine Bücher hinzu';

  @override
  String get onboardingAddSub => 'Scanne Barcodes oder suche online';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingStart => 'Starten';

  @override
  String get settingsApplyIcon => 'Symbol anwenden';

  @override
  String get settingsDynamicIcon => 'Dynamisches Symbol';

  @override
  String get settingsDynamicIconSub =>
      'App-Symbol basierend auf dem Systemdesign anpassen';

  @override
  String get settingsLibraryColumns => 'Spalten in der Bibliothek';

  @override
  String get settingsLibraryColumnsSub =>
      'Anzahl der Spalten in der Rasteransicht festlegen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionAppearance => 'Erscheinungsbild';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'System (automatisch)';

  @override
  String get settingsLanguageSpanish => 'Spanisch';

  @override
  String get settingsLanguageEnglish => 'Englisch';

  @override
  String get settingsLanguageFrench => 'Französisch';

  @override
  String get settingsLanguageItalian => 'Italienisch';

  @override
  String get settingsLanguageCatalan => 'Katalanisch';

  @override
  String get settingsLanguagePortuguese => 'Portugiesisch (Portugal)';

  @override
  String get settingsLanguagePortugueseBR => 'Portugiesisch (Brasilien)';

  @override
  String get settingsLanguageRussian => 'Russisch';

  @override
  String get settingsThemeMode => 'Design-Modus';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsAccentColor => 'Akzentfarbe';

  @override
  String get settingsAccentColorHint => 'Tippen, um die Akzentfarbe zu ändern';

  @override
  String get settingsSectionStorage => 'Speicher';

  @override
  String get settingsCoversFolder => 'Cover-Ordner';

  @override
  String get settingsDatabase => 'Datenbank';

  @override
  String get settingsDefaultDir => 'Standardverzeichnis';

  @override
  String get settingsDbMoveTitle => 'Datenbank verschieben';

  @override
  String get settingsDbMoveContent =>
      'Möchtest du die Datenbank an den neuen Ort verschieben?';

  @override
  String get settingsDbMoveConfirm => 'Verschieben';

  @override
  String get settingsSectionSearch => 'Buchsuche';

  @override
  String get settingsSearchServer => 'Suchanbieter';

  @override
  String get settingsSearchServerHint =>
      'Wähle die bevorzugten Anbieter für die Buchsuche';

  @override
  String get settingsSectionData => 'Daten & Sicherungen';

  @override
  String get dataManagementOpenShelf => 'Openshelf Backup';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => 'Daten importieren';

  @override
  String get dataManagementExport => 'Daten exportieren';

  @override
  String dataManagementImportHint(String source) {
    return 'Importiere deine Daten aus anderen Anwendungen';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return 'Anderes JSON-Sicherungsformat';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Exportiere deine Daten in verschiedenen Formaten';
  }

  @override
  String dataManagementExportHintJson(Object source) {
    return 'Anderes JSON-Exportformat';
  }

  @override
  String get dataManagementRestoreBackup => 'Sicherung wiederherstellen';

  @override
  String get dataManagementRestoreBackupHint =>
      'Sicherung aus einer Datei wiederherstellen';

  @override
  String get dataManagementCreateBackup => 'Sicherung erstellen';

  @override
  String get dataManagementCreateBackupHint =>
      'Sichere deine Bibliothek in einer Datei';

  @override
  String get settingsImportBookshelf => 'Aus Bookshelf importieren';

  @override
  String get settingsImportBookshelfHint =>
      'Daten aus der Bookshelf-App importieren';

  @override
  String get settingsExportCsv => 'CSV exportieren';

  @override
  String get settingsExportCsvHint => 'Daten im CSV-Format exportieren';

  @override
  String get settingsFullBackup => 'Vollständiges Backup';

  @override
  String get settingsFullBackupHint => 'Daten und Cover sichern';

  @override
  String get settingsAllFilesAccess => 'Zugriff auf alle Dateien';

  @override
  String get settingsAllFilesAccessSub =>
      'Erforderlich zum Verschieben der Datenbank in externe Ordner (Android 11+)';

  @override
  String get settingsAllFilesAccessInfo =>
      'Diese Berechtigung ermöglicht es Openshelf, Dateien außerhalb seines privaten Verzeichnisses zu verwalten. Sie ist erforderlich, um die Datenbank in einen benutzerdefinierten Ordner zu verschieben. Hinweis: Die App schließt sich möglicherweise automatisch beim Erteilen dieser Berechtigung.';

  @override
  String get settingsAutoNoCoverTitle => 'Regal für Bücher ohne Cover';

  @override
  String get settingsAutoNoCoverSub =>
      'Automatisch ein Regal erstellen, wenn Cover fehlen';

  @override
  String get noCoverShelfTitle => 'Bücher ohne Cover';

  @override
  String get settingsCompressImagesTitle => 'Cover automatisch komprimieren';

  @override
  String get settingsCompressImagesSub =>
      'Reduziert die Bildgröße beim Speichern oder Importieren';

  @override
  String get settingsBatchCompressTitle => 'Bibliothek jetzt optimieren';

  @override
  String get settingsBatchCompressSub =>
      'Komprimiert alle vorhandenen Cover, die noch nicht optimiert sind';

  @override
  String settingsBatchCompressSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Cover optimiert.',
      one: '1 Cover optimiert.',
    );
    return '$_temp0';
  }

  @override
  String get exportTitle => 'Bibliothek exportieren';

  @override
  String get exportCoversPrompt =>
      'Möchtest du die Cover-Bilder in die Sicherung einbinden? (Es wird eine ZIP-Datei neben der CSV-Datei erstellt)';

  @override
  String get importRestoreCoversTitle => 'Cover wiederherstellen';

  @override
  String get importRestoreCoversPrompt =>
      'Hast du auch eine ZIP-Datei mit den Cover-Bildern zum Wiederherstellen?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get devDeleteAllBooks => 'ALLE BÜCHER LÖSCHEN (DEV)';

  @override
  String get settingsDevClearDbSub => 'Entwicklerwerkzeug: Datenbank leeren';

  @override
  String get settingsDevDbCleared => 'Datenbank geleert';

  @override
  String get settingsImportSelectBackup => 'Openshelf-Sicherung auswählen';

  @override
  String get settingsImportSelectCovers => 'Openshelf-Cover-ZIP auswählen';

  @override
  String get devDeleteConfirmTitle => 'Bibliothek leeren?';

  @override
  String get devDeleteConfirmContent =>
      'Dies löscht dauerhaft ALLE Bücher und Kategorien. Nur zu Testzwecken. Fortfahren?';

  @override
  String importSuccess(int count) {
    return 'Import abgeschlossen: $count Bücher hinzugefügt.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Teilweiser Import: $added hinzugefügt, $skipped übersprungen.';
  }

  @override
  String get settingsApiKeyTitle => 'Google Books API-Schlüssel';

  @override
  String get settingsApiKeyConfigured =>
      'Schlüssel konfiguriert. Google Books ist verfügbar.';

  @override
  String get settingsApiKeyMissing =>
      'Ohne Schlüssel verwendet Google Books Open Library als Ausweichoption.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Anzeigen';

  @override
  String get settingsApiKeyHide => 'Ausblenden';

  @override
  String get settingsApiKeySave => 'Schlüssel speichern';

  @override
  String get settingsApiKeySaved => 'Schlüssel gespeichert';

  @override
  String get settingsApiKeyClear => 'Schlüssel löschen';

  @override
  String get settingsApiKeyHowTo => 'Anleitung zum Abrufen';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'So erhältst du einen Google Books API-Schlüssel';

  @override
  String get settingsApiKeyStep1 =>
      'Öffne console.cloud.google.com und melde dich mit deinem Google-Konto an.';

  @override
  String get settingsApiKeyStep2 =>
      'Erstelle ein neues Projekt (der Name ist beliebig).';

  @override
  String get settingsApiKeyStep3 =>
      'Gehe zu APIs & Dienste → Bibliothek, suche nach \"Books API\" und aktiviere sie.';

  @override
  String get settingsApiKeyStep4 =>
      'Gehe zu APIs & Dienste → Anmeldedaten → Anmeldedaten erstellen → API-Schlüssel.';

  @override
  String get settingsApiKeyStep5 =>
      'Optional, aber empfohlen: Beschränke den Schlüssel ausschließlich auf die Books API.';

  @override
  String get settingsApiKeyStep6 =>
      'Kopiere den erzeugten Schlüssel (beginnt mit \"AIza…\") und füge ihn oben ein.';

  @override
  String get settingsApiKeyNote =>
      'Der Schlüssel ist kostenlos und erlaubt bis zu 1.000 Suchanfragen pro Tag. Er wird mit niemandem geteilt und nur auf diesem Gerät gespeichert.';

  @override
  String get bookSearchHint => 'Titel, Autor oder ISBN...';

  @override
  String get bookSearchPrompt => 'Suche nach Titel, Autor oder ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Keine Ergebnisse für \"$query\"';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return 'Ergebnisse von: $providers.';
  }

  @override
  String get bookSearchRecommended => 'VON OPENSHELF EMPFOHLEN';

  @override
  String get bookSearchRecommendedSource => 'Empfohlen von Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Open Library';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get bookSearchServerAnnasArchive => 'Anna\'s Archive';

  @override
  String get searchTabStatus => 'Status';

  @override
  String get searchTabImprint => 'Verlagsmarke';

  @override
  String get searchTabCategory => 'Kategorie';

  @override
  String get searchTabCollection => 'Sammlung';

  @override
  String searchFilterStatus(String value) {
    return 'Status: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Verlagsmarke: $value';
  }

  @override
  String searchFilterCategory(String value) {
    return 'Kat.: $value';
  }

  @override
  String searchFilterCollection(String value) {
    return 'Smlg.: $value';
  }

  @override
  String searchActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktive Filter',
      one: '1 aktiver Filter',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => 'Als Regal speichern';

  @override
  String get shelfShowInLibrary => 'In Bibliothek anzeigen';

  @override
  String get searchClearAll => 'Alle löschen';

  @override
  String get addedToLibrary => 'Zur Bibliothek hinzugefügt';

  @override
  String get errorDuplicateIsbn => 'Bereits in der Bibliothek';

  @override
  String get bookDuplicateTitle => 'Doppeltes Buch';

  @override
  String bookDuplicateContent(String isbn) {
    return 'Du hast bereits ein Buch mit der ISBN $isbn in deiner Bibliothek.';
  }

  @override
  String get bookSearchErrorNoApiKey =>
      'Google Books erfordert einen API-Schlüssel.\nKonfiguriere ihn in Einstellungen → Buchsuche.';

  @override
  String get bookSearchErrorRateLimit =>
      'Google Books hat Anfragen begrenzt.\nWarte einen Moment und versuche es erneut.';

  @override
  String get bookSearchErrorNetwork =>
      'Verbindung zu keinem Server möglich.\nÜberprüfe deine Verbindung und versuche es erneut.';

  @override
  String get coverPickerTitle => 'Cover';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults => 'Keine Cover für dieses Buch gefunden.';

  @override
  String get coverPickerNetworkError =>
      'Verbindung nicht möglich. Überprüfe deine Verbindung.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Statistiken';

  @override
  String get statsPlaceholder => 'Deine Statistiken erscheinen hier';

  @override
  String get statsEmptySubtitle =>
      'Füge Widgets hinzu, um deine Lesegewohnheiten, Ziele und persönlichen Rekorde zu sehen.';

  @override
  String get statsAddFirstWidget => 'Erstes Widget hinzufügen';

  @override
  String get statsAddWidgetTitle => 'Widget hinzufügen';

  @override
  String get statsGoalTargetShelf => 'Zielregal';

  @override
  String searchFilterIsbnLabel(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String searchFilterLanguageLabel(String language) {
    return 'Sprache: $language';
  }

  @override
  String searchFilterAuthorLabel(String author) {
    return 'Autor: $author';
  }

  @override
  String searchFilterSubtitleLabel(String subtitle) {
    return 'Untertitel: $subtitle';
  }

  @override
  String searchFilterTranslatorLabel(String translator) {
    return 'Übersetzer: $translator';
  }

  @override
  String searchFilterPublisherLabel(String publisher) {
    return 'Verlag: $publisher';
  }

  @override
  String get statsGoalTitle => 'ZIEL';

  @override
  String get statsGoalFullTitle => 'LESEZIEL';

  @override
  String get statsGoalUnitBooks => 'Bücher';

  @override
  String get statsGoalUnitPages => 'Seiten';

  @override
  String statsGoalRemaining(int count) {
    return 'Noch $count';
  }

  @override
  String get statsGoalCompleted => 'Fertig!';

  @override
  String get statsGoalNew => 'Neues Ziel';

  @override
  String get statsGoalEdit => 'Ziel bearbeiten';

  @override
  String get statsGoalDelete => 'Löschen';

  @override
  String get statsGoalNameLabel => 'Name (z.B. Lese-Challenge 2026)';

  @override
  String get statsGoalTypeLabel => 'Typ';

  @override
  String get statsGoalTypeBooks => 'Gelesene Bücher';

  @override
  String get statsGoalTypePages => 'Gelesene Seiten';

  @override
  String get statsGoalTargetLabel => 'Numerisches Ziel';

  @override
  String get statsGoalFromLabel => 'Von';

  @override
  String get statsGoalToLabel => 'Bis';

  @override
  String get statsPagesTitle => 'SEITEN';

  @override
  String get statsPagesSub => 'Gelesene Seiten';

  @override
  String get statsStreakTitle => 'STRÄHNE';

  @override
  String get statsStreakSub => 'Tage in Folge';

  @override
  String get statsStatusTitle => 'STATUS';

  @override
  String get statsAddedTitle => 'HINZUGEFÜGTE BÜCHER';

  @override
  String get statsAddedNoData => 'Keine Daten';

  @override
  String get statsCategoriesTitle => 'KATEGORIEN';

  @override
  String get statsYearsTitle => 'ERSCHEINUNGSJAHRE';

  @override
  String get statsReadingTitle => 'LESEN';

  @override
  String get statsReadingNowTitle => 'LIEST GERADE';

  @override
  String get statsReadingNone => 'Nichts in Lektüre';

  @override
  String get statsReadByYearTitle => 'GELESENE BÜCHER PRO JAHR';

  @override
  String get statsCollectionsTitle => 'SAMMLUNGEN';

  @override
  String get statsLastAddedTitle => 'ZULEZT HINZUGEFÜGT';

  @override
  String get statsDailyReadingTitle => 'TÄGLICHES LESEN';

  @override
  String get statsAvgPagesTitle => 'DURCHSCHNITTLICHE SEITEN';

  @override
  String get statsAvgPagesSub => 'Seiten pro Buch';

  @override
  String get statsOptPagesTitle => 'Seiten insgesamt';

  @override
  String get statsOptPagesSub => 'Gesamtzahl gelesener Seiten';

  @override
  String get statsOptStreakTitle => 'Lesesträhne';

  @override
  String get statsOptStreakSub => 'Aufeinanderfolgende Lesetage';

  @override
  String get statsOptGoalTitle => 'Leseziel';

  @override
  String get statsOptGoalSub => 'Bücher, Regale oder Sammlungen';

  @override
  String get statsOptStatusTitle => 'Lesestatus';

  @override
  String get statsOptStatusSub => 'Bücher nach Status';

  @override
  String get statsOptCurrentTitle => 'Aktuelles Buch';

  @override
  String get statsOptCurrentSub => 'Aktueller Lesefortschritt';

  @override
  String get statsOptAddedTimeTitle => 'Hinzugefügte Bücher';

  @override
  String get statsOptAddedTimeSub => 'Zeitverlauf der Neuzugänge';

  @override
  String get statsOptCategoriesTitle => 'Kategorien';

  @override
  String get statsOptCategoriesSub => 'Verteilung nach Genrem';

  @override
  String get statsOptYearsTitle => 'Erscheinungsjahr';

  @override
  String get statsOptYearsSub => 'Historisches Histogramm';

  @override
  String get statsOptReadYearTitle => 'Gelesen pro Jahr';

  @override
  String get statsOptReadYearSub => 'Jährliches Lesediagramm';

  @override
  String get statsOptCollectionsTitle => 'Sammlungen';

  @override
  String get statsOptCollectionsSub => 'Bücher pro Sammlung';

  @override
  String get statsOptLastAddedTitle => 'Zuletzt hinzugefügt';

  @override
  String get statsOptLastAddedSub => 'Neuzugänge';

  @override
  String get statsOptAvgPagesTitle => 'Durchschnittliche Länge';

  @override
  String get statsOptAvgPagesSub => 'Durchschnittliche Seitenanzahl pro Buch';

  @override
  String get statsOptReadListTitle => 'Liste der Gelesenen';

  @override
  String get statsOptReadListSub =>
      'Bücher, die in einem Zeitraum gelesen wurden';

  @override
  String get statsOptAvgCompletionTitle => 'Lesezeit';

  @override
  String get statsOptAvgCompletionSub =>
      'Durchschnittliche Zeit zum Beenden eines Buches';

  @override
  String get statsOptDailyReadingTitle => 'Tägliches Lesen';

  @override
  String get statsOptDailyReadingSub => 'Gelesene Seiten pro Tag';

  @override
  String statsAvgCompletionValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get statsPeriodThisMonth => 'Diesen Monat gelesen';

  @override
  String get statsPeriodLast3Months => 'Letzte 3 Monate';

  @override
  String get statsPeriodThisYear => 'Dieses Jahr gelesen';

  @override
  String get statsPeriodLast3Years => 'Letzte 3 Jahre';

  @override
  String get tabMore => 'mehr';

  @override
  String get sortTitle => 'Sortieren';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get permissionRequired => 'Berechtigung erforderlich';

  @override
  String get paginationMarkersAndIndices => 'Abschnitte & Lesezeichen';

  @override
  String get paginationSaveProgress => 'Fortschritt speichern';

  @override
  String get paginationAllPagesAssigned =>
      'Alle Seiten wurden bereits zugewiesen.';

  @override
  String get paginationChooseColor => 'Farbe wählen';

  @override
  String paginationSegmentRequired(Object index) {
    return 'Segment $index: Alle Seitenfelder sind Pflichtfelder.';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return 'Segment $index: Start kann nicht größer als Ende sein.';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return 'Segment $index: Werte übersteigen die Gesamtseitenzahl ($total).';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return 'Segment $index1 überschneidet sich mit Segment $index2';
  }

  @override
  String get paginationAdvancedConfig => 'Erweiterte Konfiguration';

  @override
  String get paginationBlocksSegments => 'BLÖCKE / SEGMENTE';

  @override
  String get paginationNoSegmentsDefined =>
      'Keine Segmente definiert. Standardmäßig wird der Bereich 1-N verwendet.';

  @override
  String get paginationAddBlock => 'Block hinzufügen';

  @override
  String get paginationAllPagesAssignedNote =>
      'Hinweis: Du hast bereits alle verfügbaren Seiten zugewiesen.';

  @override
  String paginationPagesRemainingWarning(int count) {
    return 'Warnung: $count physische Seiten bleiben unzugewiesen.';
  }

  @override
  String get paginationPhysicalTotalNote =>
      'Hinweis: Die Gesamtzahl der Seiten bezieht sich auf die physischen Seiten des Buches (Blätter insgesamt).';

  @override
  String get paginationCorrectErrors =>
      'BITTE KORRIGIERE DIE FOLGENDEN FEHLER:';

  @override
  String get paginationMarkersLabels => 'LESEZEICHEN / ETIKETTEN';

  @override
  String get paginationMarkerDefaultName => 'Lesezeichen';

  @override
  String get paginationSegmentsDefaultName => 'Block';

  @override
  String get paginationAddMarker => 'Lesezeichen hinzufügen';

  @override
  String get paginationLabelOptional => 'Etikett (optional)';

  @override
  String get paginationType => 'Typ:';

  @override
  String get paginationArabic => 'Arabisch';

  @override
  String get paginationRoman => 'Römisch';

  @override
  String get paginationOffset => 'Offset';

  @override
  String get paginationMarkerLabel => 'Lesezeichen-Etikett';

  @override
  String get paginationVisualPage => 'Visuelle Seite';

  @override
  String get paginationVisualPageHint => 'z.B. xiv oder 501';

  @override
  String paginationPhysicalLabel(Object page) {
    return 'Physisch: $page';
  }

  @override
  String get paginationAdjustsAutomatically => 'Passt sich automatisch an';

  @override
  String get paginationVisualMode => 'Visueller Modus';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return 'Entspricht physisch: $start - $end';
  }

  @override
  String paginationSectionLabel(int index) {
    return 'Abschnitt $index';
  }

  @override
  String paginationProgress(String current, String total) {
    return '$current / $total';
  }

  @override
  String get searchModeBasic => 'Einfach';

  @override
  String get searchModeAdvanced => 'Erweitert';

  @override
  String get searchModeBoolean => 'Boolesch';

  @override
  String get searchAddCondition => 'Bedingung hinzufügen';

  @override
  String get searchPreview => 'Vorschau';

  @override
  String get searchFieldTitle => 'Titel';

  @override
  String get searchFieldAuthor => 'Autor';

  @override
  String get searchFieldPublisher => 'Verlag';

  @override
  String get searchFieldIsbn => 'ISBN';

  @override
  String get searchFieldLanguage => 'Sprache';

  @override
  String get searchFieldOriginalTitle => 'Originaltitel';

  @override
  String get searchFieldOriginalLanguage => 'Originalsprache';

  @override
  String get searchFieldYear => 'Jahr';

  @override
  String get searchFieldPages => 'Seiten';

  @override
  String get searchFieldStatus => 'Status';

  @override
  String get searchFieldCategory => 'Kategorie';

  @override
  String get searchFieldImprint => 'Verlagsmarke';

  @override
  String get searchFieldCollection => 'Sammlung';

  @override
  String get searchFieldNoCover => 'Ohne Cover';

  @override
  String get searchFieldNotes => 'Notizen';

  @override
  String get searchFieldHasNotes => 'Hat Notizen';

  @override
  String get searchOpContains => 'enthält';

  @override
  String get searchOpExactly => 'ist exakt';

  @override
  String get searchOpStartsWith => 'beginnt mit';

  @override
  String get searchOpIncludes => 'enthält';

  @override
  String get searchOpNotIncludes => 'enthält nicht';

  @override
  String get searchOpIncludesAll => 'enthält alle';

  @override
  String get searchOpEquals => '=';

  @override
  String get searchOpNotEquals => '≠';

  @override
  String get searchOpGreaterThan => '>';

  @override
  String get searchOpLessThan => '<';

  @override
  String get searchOpBetween => 'zwischen';

  @override
  String get searchOpIs => 'ist';

  @override
  String get searchOpIsNot => 'ist nicht';

  @override
  String get paginationCurrentPageShort => 'S.';

  @override
  String get paginationStartPhysical => 'Start (Physisch)';

  @override
  String get paginationEndPhysical => 'Ende (Physisch)';

  @override
  String get paginationStartVisual => 'Start (Visuell)';

  @override
  String get paginationEndVisual => 'Ende (Visuell)';

  @override
  String get paginationAdvancedButton => 'Erweitert';

  @override
  String get unknownAuthor => 'Unbekannt';

  @override
  String get storagePermissionExplanation =>
      'Um ein Cover auszuwählen, musst du den Speicherzugriff gewähren. Du kannst dies in den Anwendungseinstellungen tun.';

  @override
  String get cameraPermissionExplanation =>
      'Um ein Foto aufzunehmen, musst du den Kamerazugriff gewähren. Du kannst dies in den Anwendungseinstellungen tun.';

  @override
  String get settingsAutoPruneTagsTitle => 'Verwaiste Kategorien bereinigen';

  @override
  String get settingsAutoPruneTagsSub =>
      'Kategorien, die von keinem Buch verwendet werden, automatisch löschen';

  @override
  String get settingsExcludedPruneTagsTitle => 'Ausgeschlossene Kategorien';

  @override
  String settingsExcludedPruneTagsSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kategorien geschützt',
      one: '1 Kategorie geschützt',
      zero: 'Keine Kategorien ausgeschlossen',
    );
    return '$_temp0';
  }

  @override
  String get settingsPruneWarningTitle => 'Verwaiste Kategorien erkannt';

  @override
  String get settingsPruneWarningContent =>
      'Das Aktivieren dieser Option löscht die folgenden Kategorien, da sie von keinem Buch verwendet werden. Fortfahren?';

  @override
  String get settingsAutomationTitle => 'Automatisierung';

  @override
  String get removeFromCollection => 'Aus Sammlung entfernen';

  @override
  String get removeFromImprint => 'Aus Verlagsmarke entfernen';

  @override
  String get removeFromCategory => 'Aus Kategorie entfernen';

  @override
  String get workEditionsEmpty =>
      'Zusätzliche Ausgaben konnten nicht geladen werden.';

  @override
  String get workEditionsUseGeneral => 'Allgemeine Metadaten verwenden';

  @override
  String workEditionsCount(int count) {
    return '$count Ausg.';
  }

  @override
  String get settingsLanguageGerman => 'Deutsch';
}
