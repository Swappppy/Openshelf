// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Openshelf';

  @override
  String errorPrefix(String message) {
    return 'Erreur: $message';
  }

  @override
  String errorGeneric(String error) {
    return 'Erreur: $error';
  }

  @override
  String criticalStartError(String error) {
    return 'Erreur lors du démarrage de l\'application: $error';
  }

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navShelves => 'Étagères';

  @override
  String get navStats => 'Statistiques';

  @override
  String get libraryTitle => 'Bibliothèque';

  @override
  String get libraryEmpty => 'Votre bibliothèque est vide';

  @override
  String get libraryEmptyHint => 'Quel sera votre premier livre?';

  @override
  String get libraryAddFirstBook => 'Ajouter un premier livre';

  @override
  String get libraryNoResults => 'Aucun résultat';

  @override
  String get libraryNoResultsHint => 'Essayez d\'autres filtres';

  @override
  String get addBook => 'Ajouter un livre';

  @override
  String get displaySettings => 'Montrer dans la bibliothèque';

  @override
  String get displaySettingsDragHint => 'Faites glisser pour réorganiser';

  @override
  String get settingsButton => 'Paramètres';

  @override
  String get fieldAuthor => 'Auteur';

  @override
  String get fieldPublisher => 'Éditeur';

  @override
  String get fieldYear => 'Année de publication';

  @override
  String get fieldRating => 'Note';

  @override
  String get fieldTags => 'Étiquettes';

  @override
  String get fieldReadingProgress => 'Progrès de lecture';

  @override
  String get fieldStatusChip => 'Badge d\'état';

  @override
  String get searchHint => 'Recherche par titre...';

  @override
  String get filterAuthor => 'Auteur';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Éditeur';

  @override
  String get filterCollection => 'Collection';

  @override
  String get filterImprintLabel => 'Maison d\'édition';

  @override
  String imprintBookCount(int count) {
    return '$count livres';
  }

  @override
  String get filterTagsLabel => 'Catégories';

  @override
  String get done => 'OK';

  @override
  String get loading => 'Chargement...';

  @override
  String get loadingImport => 'Import de livres, veuillez patienter...';

  @override
  String get loadingExport => 'Export de livres, veuillez patienter...';

  @override
  String get exportProgressData => 'Export de données...';

  @override
  String get exportProgressMedia => 'Archivage des médias...';

  @override
  String get exportProgressCompress => 'Compression de la sauvegarde...';

  @override
  String get exportProgressFinalize => 'Ouverture du menu de partage...';

  @override
  String exportSaveSuccess(String path) {
    return 'Sauvegarde enregistrée dans $path';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Sauvegarder';

  @override
  String get delete => 'Supprimer';

  @override
  String get create => 'Créer';

  @override
  String get edit => 'Éditer';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get photo => 'Photo';

  @override
  String get url => 'URL';

  @override
  String get download => 'Télécharger';

  @override
  String get retry => 'Réessayer';

  @override
  String get share => 'Partager';

  @override
  String get saveToDevice => 'Enregistrer sur l\'appareil';

  @override
  String get addBookModalTitle => 'Ajouter un livre';

  @override
  String get addBookModalSubtitle =>
      'Choisissez comment vous souhaitez ajouter votre livre';

  @override
  String get addManually => 'Ajouter manuellement';

  @override
  String get addManuallySubtitle => 'Remplissez les données vous-même';

  @override
  String get searchBook => 'Rechercher un livre';

  @override
  String get searchBookSubtitle => 'Par titre, auteur ou ISBN';

  @override
  String get scanBarcode => 'Scanner un code-barres';

  @override
  String get scanBarcodeSubtitle => 'Pointez l\'appareil photo vers l\'ISBN';

  @override
  String get scanIsbnText => 'Scanner le numéro ISBN';

  @override
  String get scanIsbnTextSubtitle => 'Pointez vers le numéro imprimé';

  @override
  String get scanIsbnSelect => 'Appuyez sur un ISBN pour le sélectionner';

  @override
  String get scanOcrHoldMessage => 'Maintenez l\'image quelques secondes...';

  @override
  String get scanBarcodePermission =>
      'L\'autorisation de l\'appareil photo est requise pour scanner des codes';

  @override
  String get scanBatch => 'Scanner par lot';

  @override
  String get scanBatchSubtitle => 'Scannez plusieurs livres à la suite';

  @override
  String get scanModeBarcode => 'Code-barres';

  @override
  String get scanModeIsbn => 'Numéro ISBN';

  @override
  String get bookFormNewTitle => 'Nouveau livre';

  @override
  String get bookFormEditTitle => 'Modifier le livre';

  @override
  String get tabMain => 'Principal';

  @override
  String get tabDetails => 'Détails';

  @override
  String get fieldTitle => 'Titre';

  @override
  String get fieldSubtitle => 'Sous-titre';

  @override
  String get fieldDescription => 'Synopsis';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Langue';

  @override
  String get fieldIsTranslation => 'Est-ce une traduction?';

  @override
  String get fieldOriginalTitle => 'Titre original';

  @override
  String get fieldOriginalLanguage => 'Langue originale';

  @override
  String get fieldTranslator => 'Traducteur';

  @override
  String get fieldReads => 'Lectures';

  @override
  String get fieldCopies => 'Exemplaires';

  @override
  String get fieldTotalPages => 'Nombre total de pages';

  @override
  String get fieldTotalBooks => 'Nombre total de livres';

  @override
  String get fieldCurrentPage => 'Page actuelle';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldCollection => 'Collection / Série';

  @override
  String get fieldCollectionNumber => 'Numéro dans la collection';

  @override
  String get sectionBasicInfo => 'Informations de base';

  @override
  String get sectionCategories => 'Catégories';

  @override
  String get sectionReadingStatus => 'État de lecture';

  @override
  String get sectionFormat => 'Format';

  @override
  String get sectionRating => 'Note';

  @override
  String get sectionImprint => 'Maison d\'édition';

  @override
  String get coverPickPhoto => 'Photo';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Rechercher';

  @override
  String get coverUrlDialogTitle => 'URL de la couverture';

  @override
  String get coverUrlHint => 'https://exemple.com/couverture.jpg';

  @override
  String get coverDownloadError => 'Impossible de télécharger l\'image';

  @override
  String get imageProcessError => 'Impossible de traiter l\'image';

  @override
  String get cropCoverTitle => 'Recadrer la couverture';

  @override
  String get cropImprintTitle => 'Recadrer le logo';

  @override
  String get tagSearchOrCreate => 'Rechercher ou créer une catégorie';

  @override
  String get tagCreateHint =>
      'Écrivez et appuyez sur Entrée pour ajouter ou créer';

  @override
  String get tagNoCategories => 'Aucune catégorie créée pour le moment';

  @override
  String get imprintSearch => 'Rechercher une maison d\'édition';

  @override
  String get requiredField => 'Champ obligatoire';

  @override
  String get statusWantToRead => 'À lire';

  @override
  String get statusReading => 'En cours de lecture';

  @override
  String get statusRead => 'Lu';

  @override
  String get statusAbandoned => 'Abandonné';

  @override
  String get statusPaused => 'En pause';

  @override
  String get ownershipStatusBought => 'Acheté';

  @override
  String get ownershipStatusGifted => 'Offert';

  @override
  String get ownershipStatusBorrowed => 'Emprunté';

  @override
  String get ownershipStatusReturned => 'Rendu';

  @override
  String get ownershipStatusSold => 'Vendu';

  @override
  String get ownershipStatusOther => 'Autre';

  @override
  String get formatPaperback => 'Poche';

  @override
  String get formatHardcover => 'Relié';

  @override
  String get formatLeatherbound => 'Cuir';

  @override
  String get formatRustic => 'Broché';

  @override
  String get formatDigital => 'Numérique';

  @override
  String get formatOther => 'Autre';

  @override
  String get bookDetailNotFound => 'Livre non trouvé';

  @override
  String get bookDetailPagePickerTitle => 'Page actuelle';

  @override
  String get bookDetailNotesTitle => 'Notes personnelles';

  @override
  String get bookDetailNotesHint => 'Écrivez vos notes ici...';

  @override
  String get bookDetailNotesEmpty => 'Appuyez pour ajouter des notes...';

  @override
  String get bookDetailDeleteTitle => 'Supprimer le livre';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Supprimer \"$title\"? Cette action est irréversible.';
  }

  @override
  String get bookDetailDuplicateTitle => 'Dupliquer le livre';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return 'Voulez-vous créer une copie exacte de \"$title\"?';
  }

  @override
  String get bookDetailNewReadingWholeBook => 'Tout le livre';

  @override
  String get bookDetailNewReadingWholeBookDescription =>
      'Une relecture complète sera enregistrée à partir d\'aujourd\'hui.';

  @override
  String get bookDetailNewReadingSections => 'Sections';

  @override
  String bookDetailNewReadingSectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sections',
      one: '1 section',
    );
    return '$_temp0';
  }

  @override
  String bookDetailNewReadingReadCount(Object count) {
    return 'Lu ${count}x';
  }

  @override
  String get bookDetailNewReadingSelectSections =>
      'Sélectionner les sections à relire';

  @override
  String get bookDetailStartNewReadingPrompt =>
      'Voulez-vous commencer une nouvelle lecture?';

  @override
  String get bookDetailStartNewReadingTitle => 'Nouvelle lecture';

  @override
  String get bookDetailStartNewReadingButton =>
      'Commencer une nouvelle lecture';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get bookDetailDeleteReadPrompt =>
      'Supprimer la dernière lecture en cours? Les dates de cette session seront perdues.';

  @override
  String get bookDetailReadHistoryTitle => 'HISTORIQUE DES LECTURES';

  @override
  String get bookDetailReadOngoing => 'en cours';

  @override
  String bookDetailReadNumber(int number) {
    return 'Lecture $number';
  }

  @override
  String bookDetailReadEditDialogTitle(Object number) {
    return 'Modifier la lecture $number';
  }

  @override
  String get bookDetailReadDeleteConfirm =>
      'Supprimer cette entrée de l\'historique?';

  @override
  String get bookDetailReadNumberLabel => 'Numéro de lecture';

  @override
  String get bookDetailFieldPages => 'PAGES';

  @override
  String get bookDetailFieldCategories => 'CATÉGORIES';

  @override
  String get bookDetailFieldFormat => 'Format';

  @override
  String get bookDetailFieldRating => 'NOTE';

  @override
  String get bookDetailFieldImprintSection => 'MAISON D\'ÉDITION';

  @override
  String get bookDetailFieldPersonalNotes => 'NOTES PERSONNELLES';

  @override
  String get bookDetailFieldAdded => 'Ajouté';

  @override
  String get bookDetailFieldStarted => 'Début de lecture';

  @override
  String get bookDetailFieldFinished => 'Fin de lecture';

  @override
  String get fieldOwnershipStatus => 'État de propriété';

  @override
  String get ownershipHistoryTitle => 'HISTORIQUE DE PROPRIÉTÉ';

  @override
  String get ownershipLogEmpty => 'Aucun événement de propriété enregistré.';

  @override
  String get ownershipEventPerson => 'Personne / Qui';

  @override
  String get ownershipEventDate => 'Date';

  @override
  String get ownershipEventNotes => 'Notes';

  @override
  String pageProgress(String current, String total, String percent) {
    return '$current / $total p. · $percent%';
  }

  @override
  String pageProgressShort(String current, String total) {
    return '$current / $total';
  }

  @override
  String pageSuffix(int count) {
    return '$count p.';
  }

  @override
  String get pagesLabel => 'pages';

  @override
  String get shelvesTitle => 'Étagères';

  @override
  String get shelvesSectionByStatus => 'Par état';

  @override
  String get shelvesSectionMine => 'Étagères';

  @override
  String get shelvesSectionManagement => 'Gestion';

  @override
  String get shelfAllBooks => 'Tous les livres';

  @override
  String get shelfReading => 'En cours de lecture';

  @override
  String get shelfRead => 'Lus';

  @override
  String booksReadProgress(int readCount, int totalCount) {
    return '$readCount / $totalCount livres lus';
  }

  @override
  String get shelfWantToRead => 'À lire';

  @override
  String get shelfAbandoned => 'Abandonnés';

  @override
  String get shelfPaused => 'En pause';

  @override
  String get shelfNewTooltip => 'Nouvelle étagère';

  @override
  String get shelfEmpty => 'Vous n\'avez pas d\'étagères personnalisées';

  @override
  String get shelfEmptySubtitle =>
      'Organisez vos lectures comme vous le souhaitez';

  @override
  String get shelvesAddFirstShelf => 'Créer une étagère';

  @override
  String get shelfBooksEmpty => 'Aucun livre dans cette étagère';

  @override
  String get shelfStatusBooksEmpty => 'Il n\'y a pas de livres ici';

  @override
  String get shelfFormNew => 'Nouvelle étagère';

  @override
  String get shelfFormEdit => 'Modifier l\'étagère';

  @override
  String get shelfFormNameLabel => 'Nom de l\'étagère';

  @override
  String get collectionNameLabel => 'Nom de la collection';

  @override
  String get shelfFormSectionStatus => 'État de lecture';

  @override
  String get shelfFormSectionTitle => 'Titre';

  @override
  String get shelfFormSectionAuthor => 'Auteur';

  @override
  String get shelfFormSectionPublisher => 'Éditeur';

  @override
  String get shelfFormSectionIsbn => 'ISBN';

  @override
  String get shelfFormSectionCollection => 'Collection';

  @override
  String get shelfFormSectionCategories => 'Catégories';

  @override
  String get shelfFormSectionImprint => 'Maison d\'édition';

  @override
  String get shelfFormHintTitle => 'Rechercher dans le titre';

  @override
  String get shelfFormHintAuthor => 'Nom de l\'auteur';

  @override
  String get shelfFormHintPublisher => 'Nom de l\'éditeur';

  @override
  String get shelfFormHintIsbn => 'ISBN';

  @override
  String get shelfFormHintCollection => 'Nom de la collection';

  @override
  String get shelfFormStatusAny => 'N\'importe lequel';

  @override
  String get shelfOptionEdit => 'Modifier l\'étagère';

  @override
  String get shelfOptionDelete => 'Supprimer';

  @override
  String get shelfStatusLabelReading => 'En cours de lecture';

  @override
  String get shelfStatusLabelRead => 'Lus';

  @override
  String get shelfStatusLabelWantToRead => 'À lire';

  @override
  String get shelfStatusLabelAbandoned => 'Abandonnés';

  @override
  String get shelfStatusLabelPaused => 'En pause';

  @override
  String get managementCategories => 'Catégories';

  @override
  String get managementCategoryCount => 'Nb de livres';

  @override
  String get managementImprints => 'Maisons d\'édition';

  @override
  String get managementCollections => 'Collections';

  @override
  String get managementCategoryCloudCurve => 'Courbe algorithmique (Livres)';

  @override
  String get tagNone => 'Aucune catégorie pour le moment';

  @override
  String get tagNoneSubtitle =>
      'Les catégories vous aident à trouver des livres et à construire une carte mentale de votre bibliothèque';

  @override
  String get categoriesAddFirst => 'Nouvelle catégorie';

  @override
  String get tagNew => 'Nouvelle catégorie';

  @override
  String get tagNewDialogTitle => 'Nouvelle catégorie';

  @override
  String get tagNameLabel => 'Nom';

  @override
  String get tagColorLabel => 'Couleur';

  @override
  String get tagDeleteTitle => 'Supprimer la catégorie';

  @override
  String tagDeleteConfirm(String name) {
    return 'Supprimer \"$name\"?';
  }

  @override
  String get imprintNone => 'Aucune maison d\'édition pour le moment';

  @override
  String get imprintNoneSubtitle =>
      'Regroupez vos livres par éditeurs ou leurs marques';

  @override
  String get imprintsAddFirst => 'Ajouter une maison d\'édition';

  @override
  String get imprintNew => 'Nouvelle maison d\'édition';

  @override
  String get imprintNewDialogTitle => 'Nouvelle maison d\'édition';

  @override
  String get imprintEditDialogTitle => 'Modifier la maison d\'édition';

  @override
  String get imprintNameLabel => 'Nom de la maison d\'édition';

  @override
  String get imprintAddImageHint => 'Appuyez pour ajouter une image';

  @override
  String get imprintChangeImageHint => 'Appuyez pour changer l\'image';

  @override
  String get imprintUrlDialogTitle => 'URL de l\'image';

  @override
  String get imprintUrlHint => 'https://exemple.com/image.jpg';

  @override
  String get imprintDeleteTitle => 'Supprimer la maison d\'édition';

  @override
  String imprintDeleteConfirm(String name) {
    return 'Supprimer \"$name\"?';
  }

  @override
  String get imprintNoImprints => 'Aucune maison d\'édition créée';

  @override
  String get collectionNone => 'Aucune collection pour le moment';

  @override
  String get collectionNoneSubtitle =>
      'Créez des collections et organisez vos livres';

  @override
  String get collectionsAddFirst => 'Nouvelle collection';

  @override
  String get collectionDeleteTitle => 'Supprimer la collection';

  @override
  String collectionDeleteConfirm(String name) {
    return 'Supprimer \"$name\"?';
  }

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur Openshelf';

  @override
  String get onboardingWelcomeSub =>
      'Votre bibliothèque personnelle, réimaginée';

  @override
  String get onboardingOrganizeTitle => 'Organisez votre monde';

  @override
  String get onboardingOrganizeSub =>
      'Créez des étagères intelligentes et des collections thématiques';

  @override
  String get onboardingProgressTitle => 'Suivez vos progrès';

  @override
  String get onboardingProgressSub =>
      'Objectifs de lecture et statistiques détaillées';

  @override
  String get onboardingAddTitle => 'Ajoutez instantanément';

  @override
  String get onboardingAddSub =>
      'Scannez des codes-barres ou recherchez dans le cloud';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer maintenant';

  @override
  String get settingsApplyIcon => 'Appliquer le changement d\'icône';

  @override
  String get settingsDynamicIcon => 'Icône d\'application dynamique';

  @override
  String get settingsDynamicIconSub =>
      'Changez l\'icône de l\'écran d\'accueil pour qu\'elle corresponde à la couleur choisie (L\'application redémarrera)';

  @override
  String get settingsLibraryColumns => 'Colonnes de la bibliothèque';

  @override
  String get settingsLibraryColumnsSub =>
      'Ajustez le nombre de livres par ligne dans la vue en grille';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Système (automatique)';

  @override
  String get settingsLanguageSpanish => 'Espagnol';

  @override
  String get settingsLanguageEnglish => 'Anglais';

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
  String get settingsThemeMode => 'Mode du thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsAccentColor => 'Couleur d\'accentuation';

  @override
  String get settingsAccentColorHint =>
      'Appuyez sur une couleur pour l\'appliquer';

  @override
  String get settingsSectionStorage => 'Stockage';

  @override
  String get settingsCoversFolder => 'Dossier des couvertures';

  @override
  String get settingsDatabase => 'Base de données';

  @override
  String get settingsDefaultDir => 'Répertoire par défaut';

  @override
  String get settingsDbMoveTitle => 'Déplacer la base de données';

  @override
  String get settingsDbMoveContent =>
      'Le déplacement de la base de données nécessite un redémarrage de l\'application. Les données seront copiées dans le nouveau répertoire. Continuer?';

  @override
  String get settingsDbMoveConfirm => 'Déplacer et redémarrer';

  @override
  String get settingsSectionSearch => 'Recherche de livres';

  @override
  String get settingsSearchServer => 'Serveur';

  @override
  String get settingsSearchServerHint =>
      'Sera utilisé pour rechercher des livres par ISBN ou titre';

  @override
  String get settingsSectionData => 'Gestion des données';

  @override
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => 'Importer des livres';

  @override
  String get dataManagementExport => 'Exporter des livres';

  @override
  String dataManagementImportHint(String source) {
    return 'Importer depuis un CSV de $source';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return 'Importer depuis un JSON de $source';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Exporter vers un CSV de $source';
  }

  @override
  String dataManagementExportHintJson(Object source) {
    return 'Exporter vers un JSON de $source';
  }

  @override
  String get dataManagementRestoreBackup => 'Restaurer une sauvegarde';

  @override
  String get dataManagementRestoreBackupHint =>
      'Restaurer depuis un CSV/ZIP d\'OpenShelf';

  @override
  String get dataManagementCreateBackup => 'Créer une sauvegarde';

  @override
  String get dataManagementCreateBackupHint => 'Full export with covers option';

  @override
  String get settingsImportBookshelf => 'Importer depuis Bookshelf';

  @override
  String get settingsImportBookshelfHint =>
      'Importer des livres desde un fichier CSV';

  @override
  String get settingsExportCsv => 'Exporter la bibliothèque';

  @override
  String get settingsExportCsvHint =>
      'Exporter tous les livres vers un fichier CSV';

  @override
  String get settingsFullBackup => 'Restaurer la bibliothèque';

  @override
  String get settingsFullBackupHint =>
      'Restaurer les livres depuis une sauvegarde CSV';

  @override
  String get settingsAutoNoCoverTitle => 'Étagère sans couvertures';

  @override
  String get settingsAutoNoCoverSub =>
      'Crée automatiquement une étagère si des couvertures sont manquantes';

  @override
  String get noCoverShelfTitle => 'Livres sans couverture';

  @override
  String get settingsCompressImagesTitle =>
      'Compresser automatiquement les couvertures';

  @override
  String get settingsCompressImagesSub =>
      'Réduit le poids des images lors de l\'enregistrement ou de l\'importation';

  @override
  String get settingsBatchCompressTitle =>
      'Optimiser la bibliothèque maintenant';

  @override
  String get settingsBatchCompressSub =>
      'Compresse toutes les couvertures existantes qui ne sont pas optimisées';

  @override
  String settingsBatchCompressSuccess(int count) {
    return '$count couvertures ont été optimisées.';
  }

  @override
  String get exportTitle => 'Exporter la bibliothèque';

  @override
  String get exportCoversPrompt =>
      'Voulez-vous inclure les images des couvertures dans la sauvegarde? (Un fichier ZIP sera créé avec le CSV)';

  @override
  String get importRestoreCoversTitle => 'Restaurer les couvertures';

  @override
  String get importRestoreCoversPrompt =>
      'Avez-vous également un fichier ZIP avec les couvertures à restaurer?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get devDeleteAllBooks => 'SUPPRIMER TOUS LES LIVRES (DEV)';

  @override
  String get settingsDevClearDbSub =>
      'Outil de développement: nettoyer la base de données';

  @override
  String get settingsDevDbCleared => 'Base de données nettoyée';

  @override
  String get settingsImportSelectBackup =>
      'Sélectionner la sauvegarde Openshelf';

  @override
  String get settingsImportSelectCovers =>
      'Sélectionner le ZIP des couvertures Openshelf';

  @override
  String get devDeleteConfirmTitle => 'Vider la bibliothèque?';

  @override
  String get devDeleteConfirmContent =>
      'Cela supprimera définitivement TOUS les livres et catégories. Uniquement pour les tests. Continuer?';

  @override
  String importSuccess(int count) {
    return 'Importation terminée: $count livres ajoutés.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Importation partielle: $added ajoutés, $skipped ignorés.';
  }

  @override
  String get settingsApiKeyTitle => 'Clé API Google Books';

  @override
  String get settingsApiKeyConfigured =>
      'Clé configurée. Google Books está disponible.';

  @override
  String get settingsApiKeyMissing =>
      'Sans clé, Google Books utilisera Open Library comme alternative.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Afficher';

  @override
  String get settingsApiKeyHide => 'Masquer';

  @override
  String get settingsApiKeySave => 'Enregistrer la clé';

  @override
  String get settingsApiKeySaved => 'Clé enregistrée';

  @override
  String get settingsApiKeyClear => 'Effacer la clé';

  @override
  String get settingsApiKeyHowTo => 'Comment l\'obtenir';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'Comment obtenir une clé Google Books';

  @override
  String get settingsApiKeyStep1 =>
      'Ouvrez console.cloud.google.com et connectez-vous avec votre compte Google.';

  @override
  String get settingsApiKeyStep2 =>
      'Créez un nouveau projet (le nom n\'a pas d\'importance).';

  @override
  String get settingsApiKeyStep3 =>
      'Allez dans API et services → Bibliothèque, recherchez \"Books API\" et activez-la.';

  @override
  String get settingsApiKeyStep4 =>
      'Allez dans API et services → Identifiants → Créer des identifiants → API Key.';

  @override
  String get settingsApiKeyStep5 =>
      'Optionnel mais recommandé: restreignez la clé à la Books API uniquement.';

  @override
  String get settingsApiKeyStep6 =>
      'Copiez la clé résultante (commence par \"AIza…\") et collez-la dans le champ ci-dessus.';

  @override
  String get settingsApiKeyNote =>
      'La clé est gratuite et permet jusqu\'à 1 000 recherches quotidiennes. Elle n\'est partagée avec personne: elle est enregistrée uniquement sur cet appareil.';

  @override
  String get bookSearchHint => 'Titre, auteur ou ISBN...';

  @override
  String get bookSearchPrompt => 'Recherchez par titre, auteur ou ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return 'Résultats de: $providers.';
  }

  @override
  String get bookSearchRecommended => 'RECOMMANDÉ PAR OPENSHELF';

  @override
  String get bookSearchRecommendedSource => 'Recommandé par Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Open Library';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get searchTabStatus => 'État';

  @override
  String get searchTabImprint => 'Maison d\'édition';

  @override
  String get searchTabCategory => 'Catégorie';

  @override
  String get searchTabCollection => 'Collection';

  @override
  String searchFilterStatus(String value) {
    return 'État: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Maison d\'éd.: $value';
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
      other: '$count filtres actifs',
      one: '1 filtre actif',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => 'Enregistrer comme étagère';

  @override
  String get shelfShowInLibrary => 'Afficher dans la bibliothèque';

  @override
  String get searchClearAll => 'Tout effacer';

  @override
  String get addedToLibrary => 'Ajouté à la bibliothèque';

  @override
  String get errorDuplicateIsbn => 'Déjà dans la bibliothèque';

  @override
  String get bookDuplicateTitle => 'Livre en double';

  @override
  String bookDuplicateContent(String isbn) {
    return 'Vous avez déjà un livre avec l\'ISBN $isbn dans votre bibliothèque.';
  }

  @override
  String get bookSearchErrorNoApiKey =>
      'Google Books nécessite une clé API.\nConfigurez-la dans Paramètres → Recherche de livres.';

  @override
  String get bookSearchErrorRateLimit =>
      'Google Books a limité les requêtes.\nAttendez un moment et réessayez.';

  @override
  String get bookSearchErrorNetwork =>
      'Impossible de se connecter à un serveur.\nVérifiez votre connexion et réessayez.';

  @override
  String get coverPickerTitle => 'Couvertures';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults => 'Aucune couverture trouvée pour ce livre.';

  @override
  String get coverPickerNetworkError =>
      'Impossible de se connecter. Vérifiez votre connexion.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsPlaceholder => 'Vos statistiques apparaîtront ici';

  @override
  String get statsEmptySubtitle =>
      'Ajoutez des widgets pour voir vos habitudes de lecture, vos objectifs et vos records personnels.';

  @override
  String get statsAddFirstWidget => 'Ajouter un premier widget';

  @override
  String get statsAddWidgetTitle => 'Ajouter un widget';

  @override
  String get statsGoalTargetShelf => 'Étagère cible';

  @override
  String searchFilterIsbnLabel(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String searchFilterLanguageLabel(String language) {
    return 'Langue: $language';
  }

  @override
  String searchFilterAuthorLabel(String author) {
    return 'Auteur: $author';
  }

  @override
  String searchFilterPublisherLabel(String publisher) {
    return 'Éditeur: $publisher';
  }

  @override
  String get statsGoalTitle => 'OBJECTIF';

  @override
  String get statsGoalFullTitle => 'OBJECTIF DE LECTURE';

  @override
  String get statsGoalUnitBooks => 'livres';

  @override
  String get statsGoalUnitPages => 'p.';

  @override
  String statsGoalRemaining(int count) {
    return '$count restant(s)';
  }

  @override
  String get statsGoalCompleted => 'Terminé!';

  @override
  String get statsGoalNew => 'Nouvel objectif';

  @override
  String get statsGoalEdit => 'Modifier l\'objectif';

  @override
  String get statsGoalDelete => 'Supprimer';

  @override
  String get statsGoalNameLabel => 'Nom (ex: Défi 2026)';

  @override
  String get statsGoalTypeLabel => 'Type';

  @override
  String get statsGoalTypeBooks => 'Livres lus';

  @override
  String get statsGoalTypePages => 'Pages lues';

  @override
  String get statsGoalTargetLabel => 'Objectif numérique';

  @override
  String get statsGoalFromLabel => 'Du';

  @override
  String get statsGoalToLabel => 'Au';

  @override
  String get statsPagesTitle => 'PAGES';

  @override
  String get statsPagesSub => 'pages lues';

  @override
  String get statsStreakTitle => 'SÉRIE';

  @override
  String get statsStreakSub => 'jours consécutifs';

  @override
  String get statsStatusTitle => 'ÉTATS';

  @override
  String get statsAddedTitle => 'LIVRES AJOUTÉS';

  @override
  String get statsAddedNoData => 'Aucune donnée';

  @override
  String get statsCategoriesTitle => 'CATÉGORIES';

  @override
  String get statsYearsTitle => 'ANNÉES DE PUBLICATION';

  @override
  String get statsReadingTitle => 'LECTURE';

  @override
  String get statsReadingNowTitle => 'LECTURE EN COURS';

  @override
  String get statsReadingNone => 'Rien en cours';

  @override
  String get statsReadByYearTitle => 'LIVRES LUS PAR AN';

  @override
  String get statsCollectionsTitle => 'COLLECTIONS';

  @override
  String get statsLastAddedTitle => 'DERNIERS AJOUTS';

  @override
  String get statsDailyReadingTitle => 'LECTURE QUOTIDIENNE';

  @override
  String get statsAvgPagesTitle => 'MOYENNE DE PAGES';

  @override
  String get statsAvgPagesSub => 'pages par livre';

  @override
  String get statsOptPagesTitle => 'Total de pages';

  @override
  String get statsOptPagesSub => 'Total de pages lues';

  @override
  String get statsOptStreakTitle => 'Série';

  @override
  String get statsOptStreakSub => 'Jours consécutifs de lecture';

  @override
  String get statsOptGoalTitle => 'Objectif de lecture';

  @override
  String get statsOptGoalSub => 'Livres, étagères ou collections';

  @override
  String get statsOptStatusTitle => 'États de lecture';

  @override
  String get statsOptStatusSub => 'Livres par état';

  @override
  String get statsOptCurrentTitle => 'Livre actuel';

  @override
  String get statsOptCurrentSub => 'Progrès de la lecture en cours';

  @override
  String get statsOptAddedTimeTitle => 'Livres ajoutés';

  @override
  String get statsOptAddedTimeSub => 'Graphique temporel des acquisitions';

  @override
  String get statsOptCategoriesTitle => 'Catégories';

  @override
  String get statsOptCategoriesSub => 'Répartition par genres';

  @override
  String get statsOptYearsTitle => 'Année de publication';

  @override
  String get statsOptYearsSub => 'Histogramme historique';

  @override
  String get statsOptReadYearTitle => 'Lus par an';

  @override
  String get statsOptReadYearSub => 'Graphique de lecture annuelle';

  @override
  String get statsOptCollectionsTitle => 'Collections';

  @override
  String get statsOptCollectionsSub => 'Livres par collection';

  @override
  String get statsOptLastAddedTitle => 'Derniers ajouts';

  @override
  String get statsOptLastAddedSub => 'Nouveautés';

  @override
  String get statsOptAvgPagesTitle => 'Longueur moyenne';

  @override
  String get statsOptAvgPagesSub => 'Nombre moyen de pages par livre';

  @override
  String get statsOptReadListTitle => 'Liste des lus';

  @override
  String get statsOptReadListSub => 'Livres lus sur une période';

  @override
  String get statsOptAvgCompletionTitle => 'Temps de lecture';

  @override
  String get statsOptAvgCompletionSub => 'Temps moyen pour terminer un livre';

  @override
  String get statsOptDailyReadingTitle => 'Lecture quotidienne';

  @override
  String get statsOptDailyReadingSub => 'Pages lues par jour';

  @override
  String statsAvgCompletionValue(String days) {
    return '$days jours';
  }

  @override
  String get statsPeriodThisMonth => 'Lus ce mois-ci';

  @override
  String get statsPeriodLast3Months => 'Derniers 3 mois';

  @override
  String get statsPeriodThisYear => 'Lus cette année';

  @override
  String get statsPeriodLast3Years => 'Derniers 3 ans';

  @override
  String get tabMore => 'plus';

  @override
  String get sortTitle => 'Trier';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get permissionRequired => 'Autorisation nécessaire';

  @override
  String get paginationMarkersAndIndices => 'Sections et marqueurs';

  @override
  String get paginationSaveProgress => 'Enregistrer le progrès';

  @override
  String get paginationAllPagesAssigned =>
      'Toutes les pages ont déjà été assignées.';

  @override
  String get paginationChooseColor => 'Choisir une couleur';

  @override
  String paginationSegmentRequired(Object index) {
    return 'Segment $index: Tous les campos de page sont obligatoires.';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return 'Segment $index: Le début ne peut pas être supérieur à la fin.';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return 'Segment $index: Les valeurs dépassent le total de pages ($total).';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return 'Le segment $index1 chevauche le segment $index2';
  }

  @override
  String get paginationAdvancedConfig => 'Configuration avancée';

  @override
  String get paginationBlocksSegments => 'BLOCS / SEGMENTS';

  @override
  String get paginationNoSegmentsDefined =>
      'Aucun segment défini. La plage 1-N est utilisée par défaut.';

  @override
  String get paginationAddBlock => 'Ajouter un bloc';

  @override
  String get paginationAllPagesAssignedNote =>
      'Note: Vous avez déjà assigné toutes les pages disponibles.';

  @override
  String paginationPagesRemainingWarning(int count) {
    return 'Avertissement: Il reste $count pages physiques non assignées.';
  }

  @override
  String get paginationPhysicalTotalNote =>
      'Note: Le total de pages fait référence aux pages physiques du livre (nombre total de feuilles).';

  @override
  String get paginationCorrectErrors => 'CORRIGEZ LES ERREURS SUIVANTES:';

  @override
  String get paginationMarkersLabels => 'MARQUEURS / ÉTIQUETTES';

  @override
  String get paginationMarkerDefaultName => 'Marqueur';

  @override
  String get paginationSegmentsDefaultName => 'Bloc';

  @override
  String get paginationAddMarker => 'Ajouter un marqueur';

  @override
  String get paginationLabelOptional => 'Étiquette (optionnel)';

  @override
  String get paginationType => 'Type:';

  @override
  String get paginationArabic => 'Arabe';

  @override
  String get paginationRoman => 'Romain';

  @override
  String get paginationOffset => 'Décalage';

  @override
  String get paginationMarkerLabel => 'Étiquette du marqueur';

  @override
  String get paginationVisualPage => 'Page visuelle';

  @override
  String get paginationVisualPageHint => 'Ex: xiv ou 501';

  @override
  String paginationPhysicalLabel(Object page) {
    return 'Physique: $page';
  }

  @override
  String get paginationAdjustsAutomatically => 'S\'ajuste automatiquement';

  @override
  String get paginationVisualMode => 'Mode visuel';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return 'Équivaut aux pages physiques: $start - $end';
  }

  @override
  String paginationSectionLabel(int index) {
    return 'Section $index';
  }

  @override
  String paginationProgress(String current, String total) {
    return '$current / $total';
  }

  @override
  String get paginationCurrentPageShort => 'P.';

  @override
  String get paginationStartPhysical => 'Début (Physique)';

  @override
  String get paginationEndPhysical => 'Fin (Physique)';

  @override
  String get paginationStartVisual => 'Début (Visuel)';

  @override
  String get paginationEndVisual => 'Fin (Visuel)';

  @override
  String get paginationAdvancedButton => 'Avancé';

  @override
  String get unknownAuthor => 'Inconnu';

  @override
  String get storagePermissionExplanation =>
      'Pour sélectionner une couverture, vous devez accorder l\'accès au stockage. Vous pouvez le faire dans les paramètres de l\'application.';

  @override
  String get cameraPermissionExplanation =>
      'Pour prendre une photo, vous devez accorder l\'accès à l\'appareil photo. Vous pouvez le faire dans les paramètres de l\'application.';
}
