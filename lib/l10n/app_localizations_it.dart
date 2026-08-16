// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Openshelf';

  @override
  String errorPrefix(String message) {
    return 'Errore: $message';
  }

  @override
  String errorGeneric(String error) {
    return 'Errore: $error';
  }

  @override
  String criticalStartError(String error) {
    return 'Errore durante l\'avvio dell\'applicazione: $error';
  }

  @override
  String get navLibrary => 'Libreria';

  @override
  String get navShelves => 'Scaffali';

  @override
  String get navStats => 'Statistiche';

  @override
  String get libraryTitle => 'Libreria';

  @override
  String get libraryEmpty => 'La tua libreria è vuota';

  @override
  String get libraryEmptyHint => 'Quale sarà il tuo primo libro?';

  @override
  String get libraryAddFirstBook => 'Aggiungi il primo libro';

  @override
  String get libraryNoResults => 'Nessun risultato';

  @override
  String get libraryNoResultsHint => 'Prova con altri filtri';

  @override
  String get addBook => 'Aggiungi libro';

  @override
  String get displaySettings => 'Mostra nella libreria';

  @override
  String get displaySettingsDragHint => 'Trascina per riordinare';

  @override
  String get settingsButton => 'Impostazioni';

  @override
  String get fieldAuthor => 'Autore';

  @override
  String get fieldPublisher => 'Editore';

  @override
  String get fieldYear => 'Anno di pubblicazione';

  @override
  String get fieldRating => 'Valutazione';

  @override
  String get fieldTags => 'Etichette';

  @override
  String get fieldReadingProgress => 'Progresso di lettura';

  @override
  String get fieldStatusChip => 'Chip di stato';

  @override
  String get searchHint => 'Cerca per titolo...';

  @override
  String get filterAuthor => 'Autore';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Editore';

  @override
  String get filterCollection => 'Collezione';

  @override
  String get filterImprintLabel => 'Marchio editoriale';

  @override
  String imprintBookCount(int count) {
    return '$count libri';
  }

  @override
  String get filterTagsLabel => 'Categorie';

  @override
  String get done => 'Fatto';

  @override
  String get loading => 'Caricamento...';

  @override
  String get loadingImport => 'Importazione libri in corso, attendere...';

  @override
  String get loadingExport => 'Esportazione libri in corso, attendere...';

  @override
  String get exportProgressData => 'Esportazione dati...';

  @override
  String get exportProgressMedia => 'Preparazione file multimediali...';

  @override
  String get exportProgressCompress => 'Compressione backup...';

  @override
  String get exportProgressFinalize => 'Apertura menu di condivisione...';

  @override
  String exportSaveSuccess(String path) {
    return 'Backup salvato in $path';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get create => 'Crea';

  @override
  String get edit => 'Modifica';

  @override
  String get duplicate => 'Duplica';

  @override
  String get photo => 'Foto';

  @override
  String get url => 'URL';

  @override
  String get download => 'Scarica';

  @override
  String get retry => 'Riprova';

  @override
  String get share => 'Condividi';

  @override
  String get saveToDevice => 'Salva sul dispositivo';

  @override
  String get addBookModalTitle => 'Aggiungi libro';

  @override
  String get addBookModalSubtitle => 'Scegli come aggiungere il tuo libro';

  @override
  String get addManually => 'Aggiungi manualmente';

  @override
  String get addManuallySubtitle => 'Compila i dati manualmente';

  @override
  String get searchBook => 'Cerca libro';

  @override
  String get searchBookSubtitle => 'Per titolo, autore o ISBN';

  @override
  String get scanBarcode => 'Scansiona codice a barre';

  @override
  String get scanBarcodeSubtitle => 'Punta la fotocamera sull\'ISBN';

  @override
  String get scanIsbnText => 'Scansiona numero ISBN';

  @override
  String get scanIsbnTextSubtitle => 'Punta al numero stampato';

  @override
  String get scanIsbnSelect => 'Tocca un ISBN per selezionarlo';

  @override
  String get scanOcrHoldMessage =>
      'Mantieni l\'immagine ferma per qualche secondo...';

  @override
  String get scanBarcodePermission =>
      'È richiesto il permesso della fotocamera per scansionare i codici';

  @override
  String get scanBatch => 'Scansione a lotti';

  @override
  String get scanBatchSubtitle => 'Scansiona più libri in sequenza';

  @override
  String get scanModeBarcode => 'Codice a barre';

  @override
  String get scanModeIsbn => 'Numero ISBN';

  @override
  String get bookFormNewTitle => 'Nuovo libro';

  @override
  String get bookFormEditTitle => 'Modifica libro';

  @override
  String get tabMain => 'Principale';

  @override
  String get tabDetails => 'Dettagli';

  @override
  String get fieldTitle => 'Titolo';

  @override
  String get fieldSubtitle => 'Sottotitolo';

  @override
  String get fieldDescription => 'Sinossi';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Lingua';

  @override
  String get fieldIsTranslation => 'È una traduzione?';

  @override
  String get fieldOriginalTitle => 'Titolo originale';

  @override
  String get fieldOriginalLanguage => 'Lingua originale';

  @override
  String get fieldTranslator => 'Traduttore';

  @override
  String get fieldReads => 'Letture';

  @override
  String get fieldCopies => 'Copie';

  @override
  String get fieldTotalPages => 'Pagine totali';

  @override
  String get fieldTotalBooks => 'Libri totali';

  @override
  String get fieldCurrentPage => 'Pagina attuale';

  @override
  String get fieldNotes => 'Note';

  @override
  String get fieldCollection => 'Collezione / Serie';

  @override
  String get fieldCollectionNumber => 'Numero nella collezione';

  @override
  String get sectionBasicInfo => 'Informazioni di base';

  @override
  String get sectionCategories => 'Categorie';

  @override
  String get sectionReadingStatus => 'Stato di lettura';

  @override
  String get sectionFormat => 'Formato';

  @override
  String get sectionRating => 'Valutazione';

  @override
  String get sectionImprint => 'Marchio editoriale';

  @override
  String get coverPickPhoto => 'Foto';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Cerca';

  @override
  String get coverUrlDialogTitle => 'URL della copertina';

  @override
  String get coverUrlHint => 'https://esempio.com/copertina.jpg';

  @override
  String get coverDownloadError => 'Impossibile scaricare l\'immagine';

  @override
  String get imageProcessError => 'Impossibile elaborare l\'immagine';

  @override
  String get cropCoverTitle => 'Ritaglia copertina';

  @override
  String get cropImprintTitle => 'Ritaglia marchio';

  @override
  String get tagSearchOrCreate => 'Cerca o crea categoria';

  @override
  String get tagCreateHint => 'Scrivi e premi Invio per aggiungere o creare';

  @override
  String get tagNoCategories => 'Non sono ancora state create categorie';

  @override
  String get imprintSearch => 'Cerca marchio editoriale';

  @override
  String get requiredField => 'Campo obbligatorio';

  @override
  String get statusWantToRead => 'Da leggere';

  @override
  String get statusReading => 'In lettura';

  @override
  String get statusRead => 'Letto';

  @override
  String get statusAbandoned => 'Abbandonato';

  @override
  String get statusPaused => 'In pausa';

  @override
  String get ownershipStatusBought => 'Acquistato';

  @override
  String get ownershipStatusGifted => 'Regalato';

  @override
  String get ownershipStatusBorrowed => 'In prestito';

  @override
  String get ownershipStatusReturned => 'Restituito';

  @override
  String get ownershipStatusSold => 'Venduto';

  @override
  String get ownershipStatusOther => 'Altro';

  @override
  String get formatPaperback => 'Copertina flessibile';

  @override
  String get formatHardcover => 'Copertina rigida';

  @override
  String get formatLeatherbound => 'Pelle';

  @override
  String get formatRustic => 'Rilegatura rustica';

  @override
  String get formatDigital => 'Digitale';

  @override
  String get formatOther => 'Altro';

  @override
  String get bookDetailNotFound => 'Libro non trovato';

  @override
  String get bookDetailPagePickerTitle => 'Pagina attuale';

  @override
  String get bookDetailNotesTitle => 'Note personali';

  @override
  String get bookDetailNotesHint => 'Scrivi le tue note qui...';

  @override
  String get bookDetailNotesEmpty => 'Tocca per aggiungere note...';

  @override
  String get bookDetailDeleteTitle => 'Elimina libro';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Eliminare \"$title\"? Questa azione non può essere annullata.';
  }

  @override
  String get bookDetailDuplicateTitle => 'Duplica libro';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return 'Vuoi creare una copia esatta di \"$title\"?';
  }

  @override
  String get bookDetailNewReadingWholeBook => 'Tutto il libro';

  @override
  String get bookDetailNewReadingWholeBookDescription =>
      'Verrà registrata una rilettura completa a partire da oggi.';

  @override
  String get bookDetailNewReadingSections => 'Sezioni';

  @override
  String bookDetailNewReadingSectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sezioni',
      one: '1 sezione',
    );
    return '$_temp0';
  }

  @override
  String bookDetailNewReadingReadCount(Object count) {
    return 'Letto $count volte';
  }

  @override
  String get bookDetailNewReadingSelectSections =>
      'Seleziona sezioni da rileggere';

  @override
  String get bookDetailStartNewReadingPrompt =>
      'Vuoi iniziare una nuova lettura?';

  @override
  String get bookDetailStartNewReadingTitle => 'Nuova lettura';

  @override
  String get bookDetailStartNewReadingButton => 'Inizia nuova lettura';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get bookDetailDeleteReadPrompt =>
      'Eliminare l\'ultima lettura in corso? Le date di questa sessione andranno perse.';

  @override
  String get bookDetailReadHistoryTitle => 'CRONOLOGIA DI LETTURA';

  @override
  String get bookDetailReadOngoing => 'in corso';

  @override
  String bookDetailReadNumber(int number) {
    return 'Lettura $number';
  }

  @override
  String bookDetailReadEditDialogTitle(Object number) {
    return 'Modifica lettura $number';
  }

  @override
  String get bookDetailReadDeleteConfirm =>
      'Eliminare questa voce dalla cronologia?';

  @override
  String get bookDetailReadNumberLabel => 'Numero di lettura';

  @override
  String get bookDetailFieldPages => 'PAGINE';

  @override
  String get bookDetailFieldCategories => 'CATEGORIE';

  @override
  String get bookDetailFieldFormat => 'Formato';

  @override
  String get bookDetailFieldRating => 'VALUTAZIONE';

  @override
  String get bookDetailFieldImprintSection => 'MARCHIO EDITORIALE';

  @override
  String get bookDetailFieldPersonalNotes => 'NOTE PERSONALI';

  @override
  String get bookDetailFieldAdded => 'Aggiunto';

  @override
  String get bookDetailFieldStarted => 'Inizio lettura';

  @override
  String get bookDetailFieldFinished => 'Fine lettura';

  @override
  String get fieldOwnershipStatus => 'Stato di proprietà';

  @override
  String get ownershipHistoryTitle => 'CRONOLOGIA DI PROPRIETÀ';

  @override
  String get ownershipLogEmpty => 'Nessun evento di proprietà registrato.';

  @override
  String get ownershipEventPerson => 'Persona / Chi';

  @override
  String get ownershipEventDate => 'Data';

  @override
  String get ownershipEventNotes => 'Note';

  @override
  String pageProgress(String current, String total, String percent) {
    return '$current / $total pag. · $percent%';
  }

  @override
  String pageProgressShort(String current, String total) {
    return '$current / $total';
  }

  @override
  String pageSuffix(int count) {
    return '$count pag.';
  }

  @override
  String get pagesLabel => 'pagine';

  @override
  String get shelvesTitle => 'Scaffali';

  @override
  String get shelvesSectionByStatus => 'Per stato';

  @override
  String get shelvesSectionMine => 'Scaffali';

  @override
  String get shelvesSectionManagement => 'Gestione';

  @override
  String get shelfAllBooks => 'Tutti i libri';

  @override
  String get shelfReading => 'In lettura';

  @override
  String get shelfRead => 'Letti';

  @override
  String get shelfWantToRead => 'Da leggere';

  @override
  String get shelfAbandoned => 'Abbandonati';

  @override
  String get shelfPaused => 'In pausa';

  @override
  String get shelfNewTooltip => 'Nuovo scaffale';

  @override
  String get shelfEmpty => 'Non hai scaffali personalizzati';

  @override
  String get shelfEmptySubtitle => 'Organizza le tue letture come preferisci';

  @override
  String get shelvesAddFirstShelf => 'Crea scaffale';

  @override
  String get shelfBooksEmpty => 'Nessun libro in questo scaffale';

  @override
  String get shelfStatusBooksEmpty => 'Non ci sono libri qui';

  @override
  String get shelfFormNew => 'Nuovo scaffale';

  @override
  String get shelfFormEdit => 'Modifica scaffale';

  @override
  String get shelfFormNameLabel => 'Nome dello scaffale';

  @override
  String get collectionNameLabel => 'Nome della collezione';

  @override
  String get shelfFormSectionStatus => 'Stato di lettura';

  @override
  String get shelfFormSectionTitle => 'Titolo';

  @override
  String get shelfFormSectionAuthor => 'Autore';

  @override
  String get shelfFormSectionPublisher => 'Editore';

  @override
  String get shelfFormSectionIsbn => 'ISBN';

  @override
  String get shelfFormSectionCollection => 'Collezione';

  @override
  String get shelfFormSectionCategories => 'Categorie';

  @override
  String get shelfFormSectionImprint => 'Marchio editoriale';

  @override
  String get shelfFormHintTitle => 'Cerca nel titolo';

  @override
  String get shelfFormHintAuthor => 'Nome dell\'autore';

  @override
  String get shelfFormHintPublisher => 'Nome dell\'editore';

  @override
  String get shelfFormHintIsbn => 'ISBN';

  @override
  String get shelfFormHintCollection => 'Nome della collezione';

  @override
  String get shelfFormStatusAny => 'Qualsiasi';

  @override
  String get shelfOptionEdit => 'Modifica scaffale';

  @override
  String get shelfOptionDelete => 'Elimina';

  @override
  String get shelfStatusLabelReading => 'In lettura';

  @override
  String get shelfStatusLabelRead => 'Letti';

  @override
  String get shelfStatusLabelWantToRead => 'Da leggere';

  @override
  String get shelfStatusLabelAbandoned => 'Abbandonati';

  @override
  String get shelfStatusLabelPaused => 'In pausa';

  @override
  String get managementCategories => 'Categorie';

  @override
  String get managementCategoryCount => 'N. di libri';

  @override
  String get managementImprints => 'Marchi';

  @override
  String get managementCollections => 'Collezioni';

  @override
  String get managementCategoryCloudCurve => 'Curva algoritmica (Libri)';

  @override
  String get tagNone => 'Non ci sono ancora categorie';

  @override
  String get tagNoneSubtitle =>
      'Le categorie ti aiutano a trovare i libri e a costruire una mappa mentale della tua libreria';

  @override
  String get categoriesAddFirst => 'Nuova categoria';

  @override
  String get tagNew => 'Nuova categoria';

  @override
  String get tagNewDialogTitle => 'Nuova categoria';

  @override
  String get tagNameLabel => 'Nome';

  @override
  String get tagColorLabel => 'Colore';

  @override
  String get tagDeleteTitle => 'Elimina categoria';

  @override
  String tagDeleteConfirm(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get imprintNone => 'Non ci sono ancora marchi';

  @override
  String get imprintNoneSubtitle =>
      'Raggruppa i tuoi libri per editori o i loro marchi';

  @override
  String get imprintsAddFirst => 'Aggiungi marchio';

  @override
  String get imprintNew => 'Nuovo marchio';

  @override
  String get imprintNewDialogTitle => 'Nuovo marchio editoriale';

  @override
  String get imprintEditDialogTitle => 'Modifica marchio';

  @override
  String get imprintNameLabel => 'Nome del marchio';

  @override
  String get imprintAddImageHint => 'Tocca per aggiungere un\'immagine';

  @override
  String get imprintChangeImageHint => 'Tocca per cambiare l\'immagine';

  @override
  String get imprintUrlDialogTitle => 'URL dell\'immagine';

  @override
  String get imprintUrlHint => 'https://esempio.com/marchio.jpg';

  @override
  String get imprintDeleteTitle => 'Elimina marchio';

  @override
  String imprintDeleteConfirm(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get imprintNoImprints => 'Nessun marchio creato';

  @override
  String get collectionNone => 'Non ci sono ancora collezioni';

  @override
  String get collectionNoneSubtitle =>
      'Crea collezioni e organizza i tuoi libri';

  @override
  String get collectionsAddFirst => 'Nuova collezione';

  @override
  String get collectionDeleteTitle => 'Elimina collezione';

  @override
  String collectionDeleteConfirm(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get onboardingWelcomeTitle => 'Benvenuto su Openshelf';

  @override
  String get onboardingWelcomeSub => 'La tua libreria personale, reinventata';

  @override
  String get onboardingOrganizeTitle => 'Organizza il tuo mondo';

  @override
  String get onboardingOrganizeSub =>
      'Crea scaffali intelligenti e collezioni tematiche';

  @override
  String get onboardingProgressTitle => 'Segui i tuoi progressi';

  @override
  String get onboardingProgressSub =>
      'Obiettivi di lectura e statistiche dettagliate';

  @override
  String get onboardingAddTitle => 'Aggiungi istantaneamente';

  @override
  String get onboardingAddSub => 'Scansiona codici a barre o cerca nel cloud';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingStart => 'Inizia ora';

  @override
  String get settingsApplyIcon => 'Applica cambio icona';

  @override
  String get settingsDynamicIcon => 'Icona dell\'app dinamica';

  @override
  String get settingsDynamicIconSub =>
      'Cambia l\'icona della schermata home per abbinarla al colore scelto (L\'app si riavvierà)';

  @override
  String get settingsLibraryColumns => 'Colonne nella libreria';

  @override
  String get settingsLibraryColumnsSub =>
      'Regola il numero di libri per riga nella vista a griglia';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsSectionAppearance => 'Aspetto';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSystem => 'Sistema (automatico)';

  @override
  String get settingsLanguageSpanish => 'Spagnolo';

  @override
  String get settingsLanguageEnglish => 'Inglese';

  @override
  String get settingsLanguageFrench => 'Francese';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsLanguageCatalan => 'Catalano';

  @override
  String get settingsLanguagePortuguese => 'Portoghese (Portogallo)';

  @override
  String get settingsLanguagePortugueseBR => 'Portoghese (Brasile)';

  @override
  String get settingsThemeMode => 'Modalità tema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsAccentColor => 'Colore accento';

  @override
  String get settingsAccentColorHint => 'Tocca un colore per applicarlo';

  @override
  String get settingsSectionStorage => 'Archiviazione';

  @override
  String get settingsCoversFolder => 'Cartella copertine';

  @override
  String get settingsDatabase => 'Database';

  @override
  String get settingsDefaultDir => 'Directory predefinita';

  @override
  String get settingsDbMoveTitle => 'Sposta database';

  @override
  String get settingsDbMoveContent =>
      'Lo spostamento del database richiede il riavvio dell\'app. I dati verranno copiati nella nuova directory. Continuare?';

  @override
  String get settingsDbMoveConfirm => 'Sposta e riavvia';

  @override
  String get settingsSectionSearch => 'Ricerca libri';

  @override
  String get settingsSearchServer => 'Server';

  @override
  String get settingsSearchServerHint =>
      'Verrà utilizzato per cercare libri per ISBN o titolo';

  @override
  String get settingsSectionData => 'Gestione dati';

  @override
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => 'Importa libri';

  @override
  String get dataManagementExport => 'Esporta libri';

  @override
  String dataManagementImportHint(String source) {
    return 'Importa da CSV di $source';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return 'Importa da JSON di $source';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Esporta in CSV di $source';
  }

  @override
  String dataManagementExportHintJson(Object source) {
    return 'Esporta in JSON di $source';
  }

  @override
  String get dataManagementRestoreBackup => 'Ripristina backup';

  @override
  String get dataManagementRestoreBackupHint =>
      'Ripristina da CSV/ZIP di OpenShelf';

  @override
  String get dataManagementCreateBackup => 'Crea backup';

  @override
  String get dataManagementCreateBackupHint =>
      'Esportazione completa con opzione copertine';

  @override
  String get settingsImportBookshelf => 'Importa da Bookshelf';

  @override
  String get settingsImportBookshelfHint => 'Importa libri da un file CSV';

  @override
  String get settingsExportCsv => 'Esporta libreria';

  @override
  String get settingsExportCsvHint => 'Esporta tutti i libri in un file CSV';

  @override
  String get settingsFullBackup => 'Ripristina libreria';

  @override
  String get settingsFullBackupHint => 'Ripristina libri da un backup CSV';

  @override
  String get settingsAutoNoCoverTitle => 'Scaffale senza copertine';

  @override
  String get settingsAutoNoCoverSub =>
      'Crea automaticamente uno scaffale se mancano le copertine';

  @override
  String get noCoverShelfTitle => 'Libri senza copertina';

  @override
  String get settingsCompressImagesTitle =>
      'Comprimi copertine automaticamente';

  @override
  String get settingsCompressImagesSub =>
      'Riduce il peso delle immagini durante il salvataggio o l\'importazione';

  @override
  String get settingsBatchCompressTitle => 'Ottimizza libreria ora';

  @override
  String get settingsBatchCompressSub =>
      'Comprime tutte le copertine esistenti non ottimizzate';

  @override
  String settingsBatchCompressSuccess(int count) {
    return 'Sono state ottimizzate $count copertine.';
  }

  @override
  String get exportTitle => 'Esporta libreria';

  @override
  String get exportCoversPrompt =>
      'Vuoi includere le immagini delle copertine nel backup? (Verrà creato un file ZIP insieme al CSV)';

  @override
  String get importRestoreCoversTitle => 'Ripristina copertine';

  @override
  String get importRestoreCoversPrompt =>
      'Hai anche un file ZIP con le copertine da ripristinare?';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get devDeleteAllBooks => 'CANCELLA TUTTI I LIBRI (DEV)';

  @override
  String get settingsDevClearDbSub =>
      'Strumento sviluppatore: pulisci database';

  @override
  String get settingsDevDbCleared => 'Database pulito';

  @override
  String get settingsImportSelectBackup => 'Seleziona backup di Openshelf';

  @override
  String get settingsImportSelectCovers =>
      'Seleziona ZIP copertine di Openshelf';

  @override
  String get devDeleteConfirmTitle => 'Svuotare la Libreria?';

  @override
  String get devDeleteConfirmContent =>
      'Questo eliminerà permanentemente TUTTI i libri e le categorie. Solo per test. Continuare?';

  @override
  String importSuccess(int count) {
    return 'Importazione completata: $count libri aggiunti.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Importazione parziale: $added aggiunti, $skipped saltati.';
  }

  @override
  String get settingsApiKeyTitle => 'Chiave API Google Books';

  @override
  String get settingsApiKeyConfigured =>
      'Chiave configurata. Google Books è disponibile.';

  @override
  String get settingsApiKeyMissing =>
      'Senza chiave, Google Books userà Open Library come alternativa.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Mostra';

  @override
  String get settingsApiKeyHide => 'Nascondi';

  @override
  String get settingsApiKeySave => 'Salva chiave';

  @override
  String get settingsApiKeySaved => 'Chiave salvata';

  @override
  String get settingsApiKeyClear => 'Cancella chiave';

  @override
  String get settingsApiKeyHowTo => 'Come ottenerla';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'Come ottenere una chiave Google Books';

  @override
  String get settingsApiKeyStep1 =>
      'Apri console.cloud.google.com e accedi con il tuo account Google.';

  @override
  String get settingsApiKeyStep2 =>
      'Crea un nuovo progetto (il nome è indifferente).';

  @override
  String get settingsApiKeyStep3 =>
      'Vai su API e servizi → Libreria, cerca \"Books API\" e attivala.';

  @override
  String get settingsApiKeyStep4 =>
      'Vai su API e servizi → Credenziali → Crea credenziali → Chiave API.';

  @override
  String get settingsApiKeyStep5 =>
      'Opzionale ma consigliato: limita la chiave solo alla Books API.';

  @override
  String get settingsApiKeyStep6 =>
      'Copia la chiave risultante (inizia con \"AIza…\") e incollala nel campo sopra.';

  @override
  String get settingsApiKeyNote =>
      'La chiave è gratuita e consente fino a 1.000 ricerche al giorno. Non viene condivisa con nessuno: viene salvata solo su questo dispositivo.';

  @override
  String get bookSearchHint => 'Titolo, autore o ISBN...';

  @override
  String get bookSearchPrompt => 'Cerca per titolo, autore o ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return 'Risultati da: $providers.';
  }

  @override
  String get bookSearchRecommended => 'CONSIGLIATO DA OPENSHELF';

  @override
  String get bookSearchRecommendedSource => 'Consigliato da Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Open Library';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get searchTabStatus => 'Stato';

  @override
  String get searchTabImprint => 'Marchio';

  @override
  String get searchTabCategory => 'Categoria';

  @override
  String get searchTabCollection => 'Collezione';

  @override
  String searchFilterStatus(String value) {
    return 'Stato: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Marchio: $value';
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
      other: '$count filtri attivi',
      one: '1 filtro attivo',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => 'Salva come scaffale';

  @override
  String get shelfShowInLibrary => 'Mostra nella libreria';

  @override
  String get searchClearAll => 'Cancella tutto';

  @override
  String get addedToLibrary => 'Aggiunto alla libreria';

  @override
  String get errorDuplicateIsbn => 'Già presente nella libreria';

  @override
  String get bookDuplicateTitle => 'Libro duplicato';

  @override
  String bookDuplicateContent(String isbn) {
    return 'Hai già un libro con l\'ISBN $isbn nella tua libreria.';
  }

  @override
  String get bookSearchErrorNoApiKey =>
      'Google Books richiede una chiave API.\nConfigurala in Impostazioni → Ricerca libri.';

  @override
  String get bookSearchErrorRateLimit =>
      'Google Books ha limitato le richieste.\nAttendi un momento e riprova.';

  @override
  String get bookSearchErrorNetwork =>
      'Impossibile connettersi a nessun server.\nControlla la tua connessione e riprova.';

  @override
  String get coverPickerTitle => 'Copertine';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults =>
      'Nessuna copertina trovata per questo libro.';

  @override
  String get coverPickerNetworkError =>
      'Impossibile connettersi. Controlla la tua connessione.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Statistiche';

  @override
  String get statsPlaceholder => 'Le tue statistiche appariranno qui';

  @override
  String get statsEmptySubtitle =>
      'Aggiungi widget per vedere le tue abitudini di lettura, obiettivi e record personali.';

  @override
  String get statsAddFirstWidget => 'Aggiungi il primo widget';

  @override
  String get statsAddWidgetTitle => 'Aggiungi widget';

  @override
  String get statsGoalTargetShelf => 'Scaffale obiettivo';

  @override
  String searchFilterIsbnLabel(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String searchFilterLanguageLabel(String language) {
    return 'Lingua: $language';
  }

  @override
  String searchFilterAuthorLabel(String author) {
    return 'Autore: $author';
  }

  @override
  String searchFilterPublisherLabel(String publisher) {
    return 'Editore: $publisher';
  }

  @override
  String get statsGoalTitle => 'OBIETTIVO';

  @override
  String get statsGoalFullTitle => 'OBIETTIVO DI LETTURA';

  @override
  String get statsGoalUnitBooks => 'libri';

  @override
  String get statsGoalUnitPages => 'pag.';

  @override
  String statsGoalRemaining(int count) {
    return 'Mancano $count';
  }

  @override
  String get statsGoalCompleted => 'Fatto!';

  @override
  String get statsGoalNew => 'Nuovo obiettivo';

  @override
  String get statsGoalEdit => 'Modifica obiettivo';

  @override
  String get statsGoalDelete => 'Elimina';

  @override
  String get statsGoalNameLabel => 'Nome (es: Sfida 2026)';

  @override
  String get statsGoalTypeLabel => 'Tipo';

  @override
  String get statsGoalTypeBooks => 'Libri letti';

  @override
  String get statsGoalTypePages => 'Pagine lette';

  @override
  String get statsGoalTargetLabel => 'Obiettivo numerico';

  @override
  String get statsGoalFromLabel => 'Da';

  @override
  String get statsGoalToLabel => 'A';

  @override
  String get statsPagesTitle => 'PAGINE';

  @override
  String get statsPagesSub => 'pagine lette';

  @override
  String get statsStreakTitle => 'SERIE';

  @override
  String get statsStreakSub => 'giorni consecutivi';

  @override
  String get statsStatusTitle => 'STATI';

  @override
  String get statsAddedTitle => 'LIBRI AGGIUNTI';

  @override
  String get statsAddedNoData => 'Nessun dato';

  @override
  String get statsCategoriesTitle => 'CATEGORIE';

  @override
  String get statsYearsTitle => 'ANNI DI PUBBLICAZIONE';

  @override
  String get statsReadingTitle => 'LETTURA';

  @override
  String get statsReadingNowTitle => 'IN LETTURA ORA';

  @override
  String get statsReadingNone => 'Niente in lettura';

  @override
  String get statsReadByYearTitle => 'LIBRI LETTI PER ANNO';

  @override
  String get statsCollectionsTitle => 'COLLEZIONI';

  @override
  String get statsLastAddedTitle => 'ULTIMI AGGIUNTI';

  @override
  String get statsDailyReadingTitle => 'LETTURA QUOTIDIANA';

  @override
  String get statsAvgPagesTitle => 'PAGINE MEDIE';

  @override
  String get statsAvgPagesSub => 'pagine per libro';

  @override
  String get statsOptPagesTitle => 'Pagine totali';

  @override
  String get statsOptPagesSub => 'Totale pagine lette';

  @override
  String get statsOptStreakTitle => 'Serie';

  @override
  String get statsOptStreakSub => 'Giorni consecutivi di lettura';

  @override
  String get statsOptGoalTitle => 'Obiettivo di lettura';

  @override
  String get statsOptGoalSub => 'Libri, scaffali o collezioni';

  @override
  String get statsOptStatusTitle => 'Stati di lettura';

  @override
  String get statsOptStatusSub => 'Libri per stato';

  @override
  String get statsOptCurrentTitle => 'Libro attuale';

  @override
  String get statsOptCurrentSub => 'Progresso di lettura in corso';

  @override
  String get statsOptAddedTimeTitle => 'Libri aggiunti';

  @override
  String get statsOptAddedTimeSub => 'Grafico temporale delle acquisizioni';

  @override
  String get statsOptCategoriesTitle => 'Categorie';

  @override
  String get statsOptCategoriesSub => 'Distribuzione per genere';

  @override
  String get statsOptYearsTitle => 'Anno di pubblicazione';

  @override
  String get statsOptYearsSub => 'Istogramma storico';

  @override
  String get statsOptReadYearTitle => 'Letti per anno';

  @override
  String get statsOptReadYearSub => 'Grafico di lettura annuale';

  @override
  String get statsOptCollectionsTitle => 'Collezioni';

  @override
  String get statsOptCollectionsSub => 'Libri per collezione';

  @override
  String get statsOptLastAddedTitle => 'Ultimi aggiunti';

  @override
  String get statsOptLastAddedSub => 'Ultimi arrivi';

  @override
  String get statsOptAvgPagesTitle => 'Lunghezza media';

  @override
  String get statsOptAvgPagesSub => 'Pagine medie per libro';

  @override
  String get statsOptReadListTitle => 'Elenco letti';

  @override
  String get statsOptReadListSub => 'Libri letti in un periodo';

  @override
  String get statsOptAvgCompletionTitle => 'Tempo di lettura';

  @override
  String get statsOptAvgCompletionSub => 'Tempo medio per finire un libro';

  @override
  String get statsOptDailyReadingTitle => 'Lettura quotidiana';

  @override
  String get statsOptDailyReadingSub => 'Pagine lette al giorno';

  @override
  String statsAvgCompletionValue(String days) {
    return '$days giorni';
  }

  @override
  String get statsPeriodThisMonth => 'Letti questo mese';

  @override
  String get statsPeriodLast3Months => 'Ultimi 3 mesi';

  @override
  String get statsPeriodThisYear => 'Letti quest\'anno';

  @override
  String get statsPeriodLast3Years => 'Ultimi 3 anni';

  @override
  String get tabMore => 'altro';

  @override
  String get sortTitle => 'Ordina';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get permissionRequired => 'Permesso richiesto';

  @override
  String get paginationMarkersAndIndices => 'Sezioni e segnalibri';

  @override
  String get paginationSaveProgress => 'Salva progresso';

  @override
  String get paginationAllPagesAssigned =>
      'Tutte le pagine sono già state assegnate.';

  @override
  String get paginationChooseColor => 'Scegli colore';

  @override
  String paginationSegmentRequired(Object index) {
    return 'Segmento $index: Tutti i campi pagina sono obbligatori.';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return 'Segmento $index: L\'inizio non può essere superiore alla fine.';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return 'Segmento $index: I valori superano il totale delle pagine ($total).';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return 'Il segmento $index1 si sovrappone al segmento $index2';
  }

  @override
  String get paginationAdvancedConfig => 'Configurazione avanzata';

  @override
  String get paginationBlocksSegments => 'BLOCCHI / SEGMENTI';

  @override
  String get paginationNoSegmentsDefined =>
      'Nessun segmento definito. Viene utilizzato l\'intervallo predefinito 1-N.';

  @override
  String get paginationAddBlock => 'Aggiungi blocco';

  @override
  String get paginationAllPagesAssignedNote =>
      'Nota: Hai già assegnato tutte le pagine disponibili.';

  @override
  String paginationPagesRemainingWarning(int count) {
    return 'Avviso: Rimangono $count pagine fisiche non assegnate.';
  }

  @override
  String get paginationPhysicalTotalNote =>
      'Nota: Il totale delle pagine si riferisce alle pagine fisiche del libro (fogli totali).';

  @override
  String get paginationCorrectErrors => 'CORREGGI I SEGUENTI ERRORI:';

  @override
  String get paginationMarkersLabels => 'SEGNALIBRI / ETICHETTE';

  @override
  String get paginationMarkerDefaultName => 'Segnalibro';

  @override
  String get paginationSegmentsDefaultName => 'Blocco';

  @override
  String get paginationAddMarker => 'Aggiungi segnalibro';

  @override
  String get paginationLabelOptional => 'Etichetta (opzionale)';

  @override
  String get paginationType => 'Tipo:';

  @override
  String get paginationArabic => 'Arabico';

  @override
  String get paginationRoman => 'Romano';

  @override
  String get paginationOffset => 'Offset';

  @override
  String get paginationMarkerLabel => 'Etichetta del segnalibro';

  @override
  String get paginationVisualPage => 'Pagina visuale';

  @override
  String get paginationVisualPageHint => 'Es: xiv o 501';

  @override
  String paginationPhysicalLabel(Object page) {
    return 'Fisica: $page';
  }

  @override
  String get paginationAdjustsAutomatically => 'Si regola automaticamente';

  @override
  String get paginationVisualMode => 'Modalità visuale';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return 'Equivale a fisiche: $start - $end';
  }

  @override
  String paginationSectionLabel(int index) {
    return 'Sezione $index';
  }

  @override
  String paginationProgress(String current, String total) {
    return '$current / $total';
  }

  @override
  String get paginationCurrentPageShort => 'Pag.';

  @override
  String get paginationStartPhysical => 'Inizio (Fisico)';

  @override
  String get paginationEndPhysical => 'Fine (Fisico)';

  @override
  String get paginationStartVisual => 'Inizio (Visuale)';

  @override
  String get paginationEndVisual => 'Fine (Visuale)';

  @override
  String get paginationAdvancedButton => 'Avanzata';

  @override
  String get unknownAuthor => 'Sconosciuto';

  @override
  String get storagePermissionExplanation =>
      'Per selezionare una copertina, devi concedere l\'accesso alla memoria. Puoi farlo dalle impostazioni dell\'applicazione.';

  @override
  String get cameraPermissionExplanation =>
      'Per scattare una foto, devi concedere l\'accesso alla fotocamera. Puoi farlo dalle impostazioni dell\'applicazione.';
}
