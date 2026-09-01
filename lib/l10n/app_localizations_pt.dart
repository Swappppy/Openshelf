// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Openshelf';

  @override
  String errorPrefix(String message) {
    return 'Erro: $message';
  }

  @override
  String errorGeneric(String error) {
    return 'Erro: $error';
  }

  @override
  String criticalStartError(String error) {
    return 'Erro ao iniciar a aplicação: $error';
  }

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navShelves => 'Estantes';

  @override
  String get navStats => 'Estatísticas';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmpty => 'A tua biblioteca está vazia';

  @override
  String get libraryEmptyHint => 'Qual será o teu primeiro livro?';

  @override
  String get libraryAddFirstBook => 'Adicionar o primeiro livro';

  @override
  String get libraryNoResults => 'Sem resultados';

  @override
  String get libraryNoResultsHint => 'Tenta outros filtros';

  @override
  String get addBook => 'Adicionar livro';

  @override
  String get displaySettings => 'Mostrar na biblioteca';

  @override
  String get displaySettingsDragHint => 'Arrasta para reordenar';

  @override
  String get settingsButton => 'Definições';

  @override
  String get fieldAuthor => 'Autor';

  @override
  String get fieldPublisher => 'Editora';

  @override
  String get fieldYear => 'Ano de publicação';

  @override
  String get fieldRating => 'Avaliação';

  @override
  String get fieldTags => 'Etiquetas';

  @override
  String get fieldReadingProgress => 'Progresso de leitura';

  @override
  String get fieldStatusChip => 'Chip de estado';

  @override
  String get searchHint => 'Procurar por título...';

  @override
  String get filterAuthor => 'Autor';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Editora';

  @override
  String get filterCollection => 'Coleção';

  @override
  String get filterImprintLabel => 'Chancela';

  @override
  String imprintBookCount(int count) {
    return '$count livros';
  }

  @override
  String get filterTagsLabel => 'Categorias';

  @override
  String get done => 'Concluído';

  @override
  String get loading => 'A carregar...';

  @override
  String get loadingImport => 'A importar livros, por favor aguarda...';

  @override
  String get loadingExport => 'A exportar livros, por favor aguarda...';

  @override
  String get exportProgressData => 'A exportar dados...';

  @override
  String get exportProgressMedia => 'A preparar ficheiros multimédia...';

  @override
  String get exportProgressCompress => 'A comprimir cópia de segurança...';

  @override
  String get exportProgressFinalize => 'A abrir menu de partilha...';

  @override
  String exportSaveSuccess(String path) {
    return 'Cópia de segurança guardada em $path';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get create => 'Criar';

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
  String get retry => 'Tentar novamente';

  @override
  String get share => 'Partilhar';

  @override
  String get saveToDevice => 'Guardar no dispositivo';

  @override
  String get addBookModalTitle => 'Adicionar livro';

  @override
  String get addBookModalSubtitle =>
      'Escolhe como queres adicionar o teu livro';

  @override
  String get addManually => 'Adicionar manualmente';

  @override
  String get addManuallySubtitle => 'Preenche tu próprio os dados';

  @override
  String get searchBook => 'Procurar livro';

  @override
  String get searchBookSubtitle => 'Por título, autor ou ISBN';

  @override
  String get scanBarcode => 'Digitalizar código de barras';

  @override
  String get scanBarcodeSubtitle => 'Aponta a câmara para o ISBN';

  @override
  String get scanIsbnText => 'Digitalizar número ISBN';

  @override
  String get scanIsbnTextSubtitle => 'Aponta para o número impresso';

  @override
  String get scanIsbnSelect => 'Toca num ISBN para o selecionar';

  @override
  String get scanOcrHoldMessage => 'Mantém la imagem por alguns segundos...';

  @override
  String get scanBarcodePermission =>
      'É necessária permissão da câmara para digitalizar códigos';

  @override
  String get scanBatch => 'Digitalizar em lote';

  @override
  String get scanBatchSubtitle => 'Digitaliza vários livros seguidos';

  @override
  String get scanModeBarcode => 'Código de barras';

  @override
  String get scanModeIsbn => 'Número ISBN';

  @override
  String get bookFormNewTitle => 'Novo livro';

  @override
  String get bookFormEditTitle => 'Editar livro';

  @override
  String get tabMain => 'Principal';

  @override
  String get tabDetails => 'Detalhes';

  @override
  String get fieldTitle => 'Título';

  @override
  String get fieldSubtitle => 'Subtítulo';

  @override
  String get fieldDescription => 'Sinopse';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Idioma';

  @override
  String get fieldIsTranslation => 'É uma tradução?';

  @override
  String get fieldOriginalTitle => 'Título original';

  @override
  String get fieldOriginalLanguage => 'Idioma original';

  @override
  String get fieldTranslator => 'Tradutor';

  @override
  String get fieldReads => 'Leituras';

  @override
  String get fieldCopies => 'Cópias';

  @override
  String get fieldTotalPages => 'Total de páginas';

  @override
  String get fieldTotalBooks => 'Total de livros';

  @override
  String get fieldCurrentPage => 'Página atual';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldCollection => 'Coleção / Série';

  @override
  String get fieldCollectionNumber => 'Número na coleção';

  @override
  String get sectionBasicInfo => 'Informação básica';

  @override
  String get sectionCategories => 'Categorias';

  @override
  String get sectionReadingStatus => 'Estado de leitura';

  @override
  String get sectionFormat => 'Formato';

  @override
  String get sectionRating => 'Avaliação';

  @override
  String get sectionImprint => 'Chancela';

  @override
  String get coverPickPhoto => 'Foto';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Procurar';

  @override
  String get coverUrlDialogTitle => 'URL da capa';

  @override
  String get coverUrlHint => 'https://exemplo.com/capa.jpg';

  @override
  String get coverDownloadError => 'Não foi posible descarregar a imagem';

  @override
  String get imageProcessError => 'Não foi possível processar a imagem';

  @override
  String get cropCoverTitle => 'Recortar capa';

  @override
  String get cropImprintTitle => 'Recortar chancela';

  @override
  String get tagSearchOrCreate => 'Procurar ou criar categoria';

  @override
  String get tagCreateHint => 'Escreve e prime Enter para adicionar ou criar';

  @override
  String get tagNoCategories => 'Ainda não foram criadas categorias';

  @override
  String get imprintSearch => 'Procurar chancela';

  @override
  String get requiredField => 'Campo obrigatório';

  @override
  String get statusWantToRead => 'Para ler';

  @override
  String get statusReading => 'A ler';

  @override
  String get statusRead => 'Lido';

  @override
  String get statusAbandoned => 'Abandonado';

  @override
  String get statusPaused => 'Pausado';

  @override
  String get ownershipStatusBought => 'Comprado';

  @override
  String get ownershipStatusGifted => 'Oferecido';

  @override
  String get ownershipStatusBorrowed => 'Emprestado';

  @override
  String get ownershipStatusReturned => 'Devolvido';

  @override
  String get ownershipStatusSold => 'Vendido';

  @override
  String get ownershipStatusOther => 'Outro';

  @override
  String get formatPaperback => 'Capa mole';

  @override
  String get formatHardcover => 'Capa dura';

  @override
  String get formatLeatherbound => 'Pele';

  @override
  String get formatRustic => 'Rústica';

  @override
  String get formatDigital => 'Digital';

  @override
  String get formatOther => 'Outro';

  @override
  String get bookDetailNotFound => 'Livro não encontrado';

  @override
  String get bookDetailPagePickerTitle => 'Página atual';

  @override
  String get bookDetailNotesTitle => 'Notas pessoais';

  @override
  String get bookDetailNotesHint => 'Escreve as tuas notas aqui...';

  @override
  String get bookDetailNotesEmpty => 'Toca para adicionar notas...';

  @override
  String get bookDetailDeleteTitle => 'Eliminar livro';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Eliminar \"$title\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get bookDetailDuplicateTitle => 'Duplicar livro';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return 'Queres criar uma cópia exata de \"$title\"?';
  }

  @override
  String get bookDetailNewReadingWholeBook => 'Todo o livro';

  @override
  String get bookDetailNewReadingWholeBookDescription =>
      'Será registada uma releitura completa a partir de hoje.';

  @override
  String get bookDetailNewReadingSections => 'Secções';

  @override
  String bookDetailNewReadingSectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secções',
      one: '1 secção',
    );
    return '$_temp0';
  }

  @override
  String bookDetailNewReadingReadCount(Object count) {
    return 'Lida ${count}x';
  }

  @override
  String get bookDetailNewReadingSelectSections =>
      'Selecionar secções para reler';

  @override
  String get bookDetailStartNewReadingPrompt =>
      'Queres começar uma nova leitura?';

  @override
  String get bookDetailStartNewReadingTitle => 'Nova leitura';

  @override
  String get bookDetailStartNewReadingButton => 'Começar nova leitura';

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get bookDetailDeleteReadPrompt =>
      'Eliminar a última leitura en curso? As datas desta sessão serão perdidas.';

  @override
  String get bookDetailReadHistoryTitle => 'HISTÓRICO DE LEITURAS';

  @override
  String get bookDetailReadOngoing => 'em curso';

  @override
  String bookDetailReadNumber(int number) {
    return 'Leitura $number';
  }

  @override
  String bookDetailReadEditDialogTitle(Object number) {
    return 'Editar leitura $number';
  }

  @override
  String get bookDetailReadDeleteConfirm =>
      'Eliminar esta entrada do histórico?';

  @override
  String get bookDetailReadNumberLabel => 'Número da leitura';

  @override
  String get bookDetailFieldPages => 'PÁGINAS';

  @override
  String get bookDetailFieldCategories => 'CATEGORIAS';

  @override
  String get bookDetailFieldFormat => 'Formato';

  @override
  String get bookDetailFieldRating => 'AVALIAÇÃO';

  @override
  String get bookDetailFieldImprintSection => 'CHANCELA';

  @override
  String get bookDetailFieldPersonalNotes => 'NOTAS PESSOAIS';

  @override
  String get bookDetailFieldAdded => 'Adicionado';

  @override
  String get bookDetailFieldStarted => 'Início da leitura';

  @override
  String get bookDetailFieldFinished => 'Fim da leitura';

  @override
  String get fieldOwnershipStatus => 'Estado de propriedade';

  @override
  String get ownershipHistoryTitle => 'HISTÓRICO DE PROPRIEDADE';

  @override
  String get ownershipLogEmpty =>
      'Não existem eventos de propriedade registados.';

  @override
  String get ownershipEventPerson => 'Pessoa / Quem';

  @override
  String get ownershipEventDate => 'Data';

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
  String get shelvesTitle => 'Estantes';

  @override
  String get shelvesSectionByStatus => 'Por estado';

  @override
  String get shelvesSectionMine => 'Estantes';

  @override
  String get shelvesSectionManagement => 'Gestão';

  @override
  String get shelfAllBooks => 'Todos os livros';

  @override
  String get shelfReading => 'A ler';

  @override
  String get shelfRead => 'Lidos';

  @override
  String booksReadProgress(int readCount, int totalCount) {
    return '$readCount / $totalCount livros lidos';
  }

  @override
  String get shelfWantToRead => 'Para ler';

  @override
  String get shelfAbandoned => 'Abandonados';

  @override
  String get shelfPaused => 'Pausados';

  @override
  String get shelfNewTooltip => 'Nova estante';

  @override
  String get shelfEmpty => 'Não tens estantes personalizadas';

  @override
  String get shelfEmptySubtitle => 'Organiza as tuas leituras como quiseres';

  @override
  String get shelvesAddFirstShelf => 'Criar estante';

  @override
  String get shelfBooksEmpty => 'Esta estante está vazia';

  @override
  String get shelfBooksEmptyHint =>
      'Os livros que correspondem aos seus critérios aparecerão aqui.';

  @override
  String get shelfStatusBooksEmpty => 'Não há livros aqui';

  @override
  String get shelfFormNew => 'Nova estante';

  @override
  String get shelfFormEdit => 'Editar estante';

  @override
  String get shelfFormNameLabel => 'Nome da estante';

  @override
  String get collectionNameLabel => 'Nome da coleção';

  @override
  String get shelfFormSectionStatus => 'Estado de leitura';

  @override
  String get shelfFormSectionTitle => 'Título';

  @override
  String get shelfFormSectionAuthor => 'Autor';

  @override
  String get shelfFormSectionPublisher => 'Editora';

  @override
  String get shelfFormSectionIsbn => 'ISBN';

  @override
  String get shelfFormSectionCollection => 'Coleção';

  @override
  String get shelfFormSectionCategories => 'Categorias';

  @override
  String get shelfFormSectionImprint => 'Chancela';

  @override
  String get shelfFormHintTitle => 'Procurar no título';

  @override
  String get shelfFormHintAuthor => 'Nome do autor';

  @override
  String get shelfFormHintPublisher => 'Nome da editora';

  @override
  String get shelfFormHintIsbn => 'ISBN';

  @override
  String get shelfFormHintCollection => 'Nome da coleção';

  @override
  String get shelfFormStatusAny => 'Qualquer';

  @override
  String get shelfOptionEdit => 'Editar estante';

  @override
  String get shelfOptionDelete => 'Eliminar';

  @override
  String get shelfStatusLabelReading => 'A ler';

  @override
  String get shelfStatusLabelRead => 'Lidos';

  @override
  String get shelfStatusLabelWantToRead => 'Para ler';

  @override
  String get shelfStatusLabelAbandoned => 'Abandonados';

  @override
  String get shelfStatusLabelPaused => 'Pausados';

  @override
  String get managementCategories => 'Categorias';

  @override
  String get managementCategoryCount => 'Nº de livros';

  @override
  String get managementImprints => 'Chancelas';

  @override
  String get managementCollections => 'Coleções';

  @override
  String get managementCategoryCloudCurve => 'Curva algorítmica (Libros)';

  @override
  String get tagNone => 'Ainda não há categorias';

  @override
  String get tagNoneSubtitle =>
      'As categorias ajudam-te a encontrar livros e a construir um mapa mental da tua biblioteca';

  @override
  String get categoriesAddFirst => 'Nova categoria';

  @override
  String get tagNew => 'Nova categoria';

  @override
  String get tagNewDialogTitle => 'Nova categoria';

  @override
  String get tagNameLabel => 'Nome';

  @override
  String get tagColorLabel => 'Cor';

  @override
  String get tagDeleteTitle => 'Eliminar categoria';

  @override
  String tagDeleteConfirm(String name) {
    return 'Eliminar \"$name\"?';
  }

  @override
  String get imprintNone => 'Ainda não há chancelas';

  @override
  String get imprintNoneSubtitle =>
      'Agrupa os teus livros por editoras ou as suas chancelas';

  @override
  String get imprintsAddFirst => 'Adicionar chancela';

  @override
  String get imprintNew => 'Nova chancela';

  @override
  String get imprintNewDialogTitle => 'Nova chancela';

  @override
  String get imprintEditDialogTitle => 'Editar chancela';

  @override
  String get imprintNameLabel => 'Nome da chancela';

  @override
  String get imprintAddImageHint => 'Prime para adicionar imagem';

  @override
  String get imprintChangeImageHint => 'Prime para alterar imagem';

  @override
  String get imprintUrlDialogTitle => 'URL da imagem';

  @override
  String get imprintUrlHint => 'https://exemplo.com/chancela.jpg';

  @override
  String get imprintDeleteTitle => 'Eliminar chancela';

  @override
  String imprintDeleteConfirm(String name) {
    return 'Eliminar \"$name\"?';
  }

  @override
  String get imprintNoImprints => 'Não há chancelas criadas';

  @override
  String get collectionNone => 'Ainda não há coleções';

  @override
  String get collectionNoneSubtitle =>
      'Cria coleções e organiza os teus livros';

  @override
  String get collectionsAddFirst => 'Nova coleção';

  @override
  String get collectionDeleteTitle => 'Eliminar coleção';

  @override
  String collectionDeleteConfirm(String name) {
    return 'Eliminar \"$name\"?';
  }

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao Openshelf';

  @override
  String get onboardingWelcomeSub => 'A tua biblioteca pessoal, reimaginada';

  @override
  String get onboardingOrganizeTitle => 'Organiza o teu mundo';

  @override
  String get onboardingOrganizeSub =>
      'Cria estantes inteligentes e coleções temáticas';

  @override
  String get onboardingProgressTitle => 'Acompanha o teu progresso';

  @override
  String get onboardingProgressSub => 'Reading goals and detailed statistics';

  @override
  String get onboardingAddTitle => 'Adiciona instantaneamente';

  @override
  String get onboardingAddSub =>
      'Digitaliza códigos de barras ou procura na nuvem';

  @override
  String get onboardingNext => 'Seguinte';

  @override
  String get onboardingStart => 'Começar agora';

  @override
  String get settingsApplyIcon => 'Aplicar alteração de ícone';

  @override
  String get settingsDynamicIcon => 'Ícone da app dinâmico';

  @override
  String get settingsDynamicIconSub =>
      'Altera o ícone do ecrã principal para corresponder à cor escolhida (A app será reiniciada)';

  @override
  String get settingsLibraryColumns => 'Colunas na biblioteca';

  @override
  String get settingsLibraryColumnsSub =>
      'Ajusta o número de livros por fila na vista de grelha';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsSectionAppearance => 'Aparência';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema (automático)';

  @override
  String get settingsLanguageSpanish => 'Espanhol';

  @override
  String get settingsLanguageEnglish => 'Inglês';

  @override
  String get settingsLanguageFrench => 'Francês';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsLanguageCatalan => 'Catalão';

  @override
  String get settingsLanguagePortuguese => 'Português (Portugal)';

  @override
  String get settingsLanguagePortugueseBR => 'Português (Brasil)';

  @override
  String get settingsThemeMode => 'Modo de tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsAccentColor => 'Cor de destaque';

  @override
  String get settingsAccentColorHint => 'Toca numa cor para aplicá-la';

  @override
  String get settingsSectionStorage => 'Armazenamento';

  @override
  String get settingsCoversFolder => 'Pasta de capas';

  @override
  String get settingsDatabase => 'Base de dados';

  @override
  String get settingsDefaultDir => 'Diretório predefinido';

  @override
  String get settingsDbMoveTitle => 'Mover base de dados';

  @override
  String get settingsDbMoveContent =>
      'Mover a base de dados requer reiniciar a app. Os dados serão copiados para o novo diretório. Continuar?';

  @override
  String get settingsDbMoveConfirm => 'Mover e reiniciar';

  @override
  String get settingsSectionSearch => 'Procura de livros';

  @override
  String get settingsSearchServer => 'Servidor';

  @override
  String get settingsSearchServerHint =>
      'Será usado para procurar livros por ISBN ou título';

  @override
  String get settingsSectionData => 'Gestão de dados';

  @override
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => 'Importar livros';

  @override
  String get dataManagementExport => 'Exportar livros';

  @override
  String dataManagementImportHint(String source) {
    return 'Importar de CSV de $source';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return 'Importar de JSON de $source';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Exportar para CSV de $source';
  }

  @override
  String dataManagementExportHintJson(Object source) {
    return 'Exportar para JSON de $source';
  }

  @override
  String get dataManagementRestoreBackup => 'Restaurar cópia de segurança';

  @override
  String get dataManagementRestoreBackupHint =>
      'Restaurar de CSV/ZIP do OpenShelf';

  @override
  String get dataManagementCreateBackup => 'Criar cópia de segurança';

  @override
  String get dataManagementCreateBackupHint => 'Full export with covers option';

  @override
  String get settingsImportBookshelf => 'Importar do Bookshelf';

  @override
  String get settingsImportBookshelfHint =>
      'Importar livros de um ficheiro CSV';

  @override
  String get settingsExportCsv => 'Exportar biblioteca';

  @override
  String get settingsExportCsvHint =>
      'Exportar todos os livros para um ficheiro CSV';

  @override
  String get settingsFullBackup => 'Restaurar biblioteca';

  @override
  String get settingsFullBackupHint =>
      'Restaurar livros de uma cópia de segurança CSV';

  @override
  String get settingsAllFilesAccess => 'Acesso a todos os ficheiros';

  @override
  String get settingsAllFilesAccessSub =>
      'Necessário para mover a base de dados para pastas externas (Android 11+)';

  @override
  String get settingsAllFilesAccessInfo =>
      'Esta permissão permite que o Openshelf gira ficheiros fora do seu diretório privado. É necessário mover a base de dades para uma pasta personalizada.';

  @override
  String get settingsAutoNoCoverTitle => 'Estante sem capas';

  @override
  String get settingsAutoNoCoverSub =>
      'Cria automaticamente uma estante se faltarem capas';

  @override
  String get noCoverShelfTitle => 'Livros sem capa';

  @override
  String get settingsCompressImagesTitle => 'Comprimir capas automaticamente';

  @override
  String get settingsCompressImagesSub =>
      'Reduz o peso das imagens ao guardá-las ou importá-las';

  @override
  String get settingsBatchCompressTitle => 'Otimizar biblioteca agora';

  @override
  String get settingsBatchCompressSub =>
      'Comprime todas as capas existentes que não estejam otimizadas';

  @override
  String settingsBatchCompressSuccess(int count) {
    return 'Foram otimizadas $count capas.';
  }

  @override
  String get exportTitle => 'Exportar biblioteca';

  @override
  String get exportCoversPrompt =>
      'Queres incluir as imagens das capas na cópia de segurança? (Será criado um ficheiro ZIP junto ao CSV)';

  @override
  String get importRestoreCoversTitle => 'Restaurar capas';

  @override
  String get importRestoreCoversPrompt =>
      'Também tens um ficheiro ZIP com as capas para restaurar?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get devDeleteAllBooks => 'APAGAR TODOS OS LIVROS (DEV)';

  @override
  String get settingsDevClearDbSub =>
      'Ferramenta de programador: limpar base de dados';

  @override
  String get settingsDevDbCleared => 'Base de dados limpa';

  @override
  String get settingsImportSelectBackup =>
      'Selecionar cópia de segurança do Openshelf';

  @override
  String get settingsImportSelectCovers =>
      'Selecionar ZIP de capas do Openshelf';

  @override
  String get devDeleteConfirmTitle => 'Esvaziar Biblioteca?';

  @override
  String get devDeleteConfirmContent =>
      'Isto eliminará permanentemente TODOS os livros e categorias. Apenas para testes. Continuar?';

  @override
  String importSuccess(int count) {
    return 'Importação concluída: $count livros adicionados.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Importação parcial: $added adicionados, $skipped omitidos.';
  }

  @override
  String get settingsApiKeyTitle => 'Google Books API key';

  @override
  String get settingsApiKeyConfigured =>
      'Chave configurada. O Google Books está disponível.';

  @override
  String get settingsApiKeyMissing =>
      'Sem chave, o Google Books usará o Open Library como alternativa.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Mostrar';

  @override
  String get settingsApiKeyHide => 'Ocultar';

  @override
  String get settingsApiKeySave => 'Guardar chave';

  @override
  String get settingsApiKeySaved => 'Chave guardada';

  @override
  String get settingsApiKeyClear => 'Limpar chave';

  @override
  String get settingsApiKeyHowTo => 'Como obter';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'Como obter uma chave do Google Books';

  @override
  String get settingsApiKeyStep1 =>
      'Abre console.cloud.google.com e inicia sessão com a tua conta Google.';

  @override
  String get settingsApiKeyStep2 =>
      'Cria um projeto novo (o nome é indiferente).';

  @override
  String get settingsApiKeyStep3 =>
      'Vai a APIs e serviços → Biblioteca, procura \"Books API\" e ativa-a.';

  @override
  String get settingsApiKeyStep4 =>
      'Vai a APIs e serviços → Credenciais → Crear credenciais → Chave de API.';

  @override
  String get settingsApiKeyStep5 =>
      'Opcional mas recomendado: restringe a chave apenas à Books API.';

  @override
  String get settingsApiKeyStep6 =>
      'Copia a chave resultante (começa por \"AIza…\") e cola-a no campo acima.';

  @override
  String get settingsApiKeyNote =>
      'A chave é gratuita e permite até 1.000 procuras diárias. Não é partilhada com ninguém: é guardada apenas neste dispositivo.';

  @override
  String get bookSearchHint => 'Título, autor ou ISBN...';

  @override
  String get bookSearchPrompt => 'Procura por título, autor ou ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Sem resultados para \"$query\"';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return 'Resultados de: $providers.';
  }

  @override
  String get bookSearchRecommended => 'RECOMENDADO PELO OPENSHELF';

  @override
  String get bookSearchRecommendedSource => 'Recomendado pelo Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Open Library';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get searchTabStatus => 'Estado';

  @override
  String get searchTabImprint => 'Chancela';

  @override
  String get searchTabCategory => 'Categoria';

  @override
  String get searchTabCollection => 'Coleção';

  @override
  String searchFilterStatus(String value) {
    return 'Estado: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Chancela: $value';
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
      other: '$count filtros ativos',
      one: '1 filtro ativo',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => 'Guardar como estante';

  @override
  String get shelfShowInLibrary => 'Mostrar na biblioteca';

  @override
  String get searchClearAll => 'Limpar tudo';

  @override
  String get addedToLibrary => 'Adicionado à biblioteca';

  @override
  String get errorDuplicateIsbn => 'Já está na biblioteca';

  @override
  String get bookDuplicateTitle => 'Livro duplicado';

  @override
  String bookDuplicateContent(String isbn) {
    return 'Já tens um livro com o ISBN $isbn na tua biblioteca.';
  }

  @override
  String get bookSearchErrorNoApiKey =>
      'O Google Books requer uma chave de API.\nConfigura-a em Definições → Procura de livros.';

  @override
  String get bookSearchErrorRateLimit =>
      'O Google Books limitou os pedidos.\nAguarda um momento e tenta novamente.';

  @override
  String get bookSearchErrorNetwork =>
      'Não foi possível ligar a nenhum servidor.\nVerifica a tua ligação e tenta novamente.';

  @override
  String get coverPickerTitle => 'Capas';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults =>
      'Não foram encontradas capas para este livro.';

  @override
  String get coverPickerNetworkError =>
      'Não foi possível ligar. Verifica a tua ligação.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get statsPlaceholder => 'As tuas estatísticas aparecerão aqui';

  @override
  String get statsEmptySubtitle =>
      'Adiciona widgets para veres os teus hábitos de leitura, metas e recordes pessoais.';

  @override
  String get statsAddFirstWidget => 'Adicionar primeiro widget';

  @override
  String get statsAddWidgetTitle => 'Adicionar widget';

  @override
  String get statsGoalTargetShelf => 'Estante objetivo';

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
    return 'Editora: $publisher';
  }

  @override
  String get statsGoalTitle => 'META';

  @override
  String get statsGoalFullTitle => 'META DE LEITURA';

  @override
  String get statsGoalUnitBooks => 'livros';

  @override
  String get statsGoalUnitPages => 'págs';

  @override
  String statsGoalRemaining(int count) {
    return 'Faltam $count';
  }

  @override
  String get statsGoalCompleted => 'Concluído!';

  @override
  String get statsGoalNew => 'Nova meta';

  @override
  String get statsGoalEdit => 'Editar meta';

  @override
  String get statsGoalDelete => 'Eliminar';

  @override
  String get statsGoalNameLabel => 'Nome (ex: Desafio 2026)';

  @override
  String get statsGoalTypeLabel => 'Tipo';

  @override
  String get statsGoalTypeBooks => 'Livros lidos';

  @override
  String get statsGoalTypePages => 'Páginas lidas';

  @override
  String get statsGoalTargetLabel => 'Objetivo numérico';

  @override
  String get statsGoalFromLabel => 'Desde';

  @override
  String get statsGoalToLabel => 'Até';

  @override
  String get statsPagesTitle => 'PÁGINAS';

  @override
  String get statsPagesSub => 'páginas lidas';

  @override
  String get statsStreakTitle => 'SEQUÊNCIA';

  @override
  String get statsStreakSub => 'dias seguidos';

  @override
  String get statsStatusTitle => 'ESTADOS';

  @override
  String get statsAddedTitle => 'LIVROS ADICIONADOS';

  @override
  String get statsAddedNoData => 'Sem dados';

  @override
  String get statsCategoriesTitle => 'CATEGORIAS';

  @override
  String get statsYearsTitle => 'ANOS DE PUBLICAÇÃO';

  @override
  String get statsReadingTitle => 'LEITURA';

  @override
  String get statsReadingNowTitle => 'A LER AGORA';

  @override
  String get statsReadingNone => 'Nada a ser lido';

  @override
  String get statsReadByYearTitle => 'LIVROS LIDOS POR ANO';

  @override
  String get statsCollectionsTitle => 'COLEÇÕES';

  @override
  String get statsLastAddedTitle => 'ÚLTIMOS ADICIONADOS';

  @override
  String get statsDailyReadingTitle => 'LEITURA DIÀRIA';

  @override
  String get statsAvgPagesTitle => 'MÉDIA DE PÁGINAS';

  @override
  String get statsAvgPagesSub => 'páginas por livro';

  @override
  String get statsOptPagesTitle => 'Total de páginas';

  @override
  String get statsOptPagesSub => 'Total de páginas lidas';

  @override
  String get statsOptStreakTitle => 'Sequência';

  @override
  String get statsOptStreakSub => 'Dias consecutivos a ler';

  @override
  String get statsOptGoalTitle => 'Meta de leitura';

  @override
  String get statsOptGoalSub => 'Livros, estantes ou coleções';

  @override
  String get statsOptStatusTitle => 'Estados de leitura';

  @override
  String get statsOptStatusSub => 'Livros por estado';

  @override
  String get statsOptCurrentTitle => 'Livro atual';

  @override
  String get statsOptCurrentSub => 'Progresso de leitura em curso';

  @override
  String get statsOptAddedTimeTitle => 'Livros adicionados';

  @override
  String get statsOptAddedTimeSub => 'Gráfico temporal de aquisições';

  @override
  String get statsOptCategoriesTitle => 'Categorias';

  @override
  String get statsOptCategoriesSub => 'Distribuição por géneros';

  @override
  String get statsOptYearsTitle => 'Ano de publicação';

  @override
  String get statsOptYearsSub => 'Histograma histórico';

  @override
  String get statsOptReadYearTitle => 'Lidos por ano';

  @override
  String get statsOptReadYearSub => 'Gráfico de leitura anual';

  @override
  String get statsOptCollectionsTitle => 'Coleções';

  @override
  String get statsOptCollectionsSub => 'Livros por coleção';

  @override
  String get statsOptLastAddedTitle => 'Últimos adicionados';

  @override
  String get statsOptLastAddedSub => 'Recém-chegados';

  @override
  String get statsOptAvgPagesTitle => 'Extensão média';

  @override
  String get statsOptAvgPagesSub => 'Média de páginas por livro';

  @override
  String get statsOptReadListTitle => 'Lista de lidos';

  @override
  String get statsOptReadListSub => 'Livros lidos num período';

  @override
  String get statsOptAvgCompletionTitle => 'Tempo de leitura';

  @override
  String get statsOptAvgCompletionSub => 'Tempo médio para terminar um livro';

  @override
  String get statsOptDailyReadingTitle => 'Leitura diária';

  @override
  String get statsOptDailyReadingSub => 'Páginas lidas por dia';

  @override
  String statsAvgCompletionValue(String days) {
    return '$days dias';
  }

  @override
  String get statsPeriodThisMonth => 'Lidos este mês';

  @override
  String get statsPeriodLast3Months => 'Últimos 3 meses';

  @override
  String get statsPeriodThisYear => 'Lidos este ano';

  @override
  String get statsPeriodLast3Years => 'Últimos 3 anos';

  @override
  String get tabMore => 'mais';

  @override
  String get sortTitle => 'Ordenar';

  @override
  String get openSettings => 'Abrir definições';

  @override
  String get permissionRequired => 'Permissão necessária';

  @override
  String get paginationMarkersAndIndices => 'Secções e marcadores';

  @override
  String get paginationSaveProgress => 'Guardar Progresso';

  @override
  String get paginationAllPagesAssigned =>
      'Todas as páginas já foram atribuídas.';

  @override
  String get paginationChooseColor => 'Escolher cor';

  @override
  String paginationSegmentRequired(Object index) {
    return 'Segmento $index: Todos os campos de página são obrigatórios.';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return 'Segmento $index: O início não pode ser maior que o fim.';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return 'Segmento $index: Os valores excedem o total de páginas ($total).';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return 'O segmento $index1 sobrepõe-se ao segmento $index2';
  }

  @override
  String get paginationAdvancedConfig => 'Configuração avançada';

  @override
  String get paginationBlocksSegments => 'BLOCOS / SEGMENTOS';

  @override
  String get paginationNoSegmentsDefined =>
      'Não há segmentos definidos. É usado o intervalo 1-N por predefinição.';

  @override
  String get paginationAddBlock => 'Adicionar bloco';

  @override
  String get paginationAllPagesAssignedNote =>
      'Nota: Já atribuíste todas as páginas disponíveis.';

  @override
  String paginationPagesRemainingWarning(int count) {
    return 'Aviso: Restam $count páginas físicas por atribuir.';
  }

  @override
  String get paginationPhysicalTotalNote =>
      'Nota: O total de páginas refere-se às páginas físicas do livro (folhas totais).';

  @override
  String get paginationCorrectErrors => 'CORRIJA OS SEGUINTES ERROS:';

  @override
  String get paginationMarkersLabels => 'MARCADORES / ETIQUETAS';

  @override
  String get paginationMarkerDefaultName => 'Marcador';

  @override
  String get paginationSegmentsDefaultName => 'Bloco';

  @override
  String get paginationAddMarker => 'Adicionar marcador';

  @override
  String get paginationLabelOptional => 'Etiqueta (opcional)';

  @override
  String get paginationType => 'Tipo:';

  @override
  String get paginationArabic => 'Árabe';

  @override
  String get paginationRoman => 'Romano';

  @override
  String get paginationOffset => 'Offset';

  @override
  String get paginationMarkerLabel => 'Etiqueta do marcador';

  @override
  String get paginationVisualPage => 'Página Visual';

  @override
  String get paginationVisualPageHint => 'Ex: xiv ou 501';

  @override
  String paginationPhysicalLabel(Object page) {
    return 'Física: $page';
  }

  @override
  String get paginationAdjustsAutomatically => 'Ajusta-se automaticamente';

  @override
  String get paginationVisualMode => 'Modo visual';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return 'Equivale a físicas: $start - $end';
  }

  @override
  String paginationSectionLabel(int index) {
    return 'Secção $index';
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
  String get paginationStartPhysical => 'Início (Físico)';

  @override
  String get paginationEndPhysical => 'Fim (Físico)';

  @override
  String get paginationStartVisual => 'Início (Visual)';

  @override
  String get paginationEndVisual => 'Fim (Visual)';

  @override
  String get paginationAdvancedButton => 'Avançada';

  @override
  String get unknownAuthor => 'Desconhecido';

  @override
  String get storagePermissionExplanation =>
      'Para selecionar uma capa precisas de conceder acesso ao armazenamento. Podes fazê-lo nas definições da aplicação.';

  @override
  String get cameraPermissionExplanation =>
      'Para tirar uma foto precisas de conceder acesso à câmara. Podes fazê-lo nas definições da aplicação.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Openshelf';

  @override
  String errorPrefix(String message) {
    return 'Erro: $message';
  }

  @override
  String errorGeneric(String error) {
    return 'Erro: $error';
  }

  @override
  String criticalStartError(String error) {
    return 'Erro ao iniciar o aplicativo: $error';
  }

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navShelves => 'Estantes';

  @override
  String get navStats => 'Estatísticas';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmpty => 'Sua biblioteca está vazia';

  @override
  String get libraryEmptyHint => 'Qual vai ser seu primeiro livro?';

  @override
  String get libraryAddFirstBook => 'Adicionar primeiro livro';

  @override
  String get libraryNoResults => 'Sem resultados';

  @override
  String get libraryNoResultsHint => 'Teste com outros filtros';

  @override
  String get addBook => 'Adicionar livro';

  @override
  String get displaySettings => 'Mostrar na biblioteca';

  @override
  String get displaySettingsDragHint => 'Arrastar para reordenar';

  @override
  String get settingsButton => 'Configurações';

  @override
  String get fieldAuthor => 'Autor';

  @override
  String get fieldPublisher => 'Editora';

  @override
  String get fieldYear => 'Ano de publicação';

  @override
  String get fieldRating => 'Avaliação';

  @override
  String get fieldTags => 'Etiquetas';

  @override
  String get fieldReadingProgress => 'Progresso de leitura';

  @override
  String get fieldStatusChip => 'Marcador de status';

  @override
  String get searchHint => 'Buscar por título...';

  @override
  String get filterAuthor => 'Autor';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Editora';

  @override
  String get filterCollection => 'Coleção';

  @override
  String get filterImprintLabel => 'Selo editorial';

  @override
  String imprintBookCount(int count) {
    return '$count livros';
  }

  @override
  String get filterTagsLabel => 'Categorias';

  @override
  String get done => 'Feito';

  @override
  String get loading => 'Carregando...';

  @override
  String get loadingImport => 'Importando os livros, espere um pouco...';

  @override
  String get loadingExport => 'Exportando os livros, espere um pouco...';

  @override
  String get exportProgressData => 'Exportando dados...';

  @override
  String get exportProgressMedia => 'Preparando os arquivos multimídia...';

  @override
  String get exportProgressCompress => 'Exportando cópia de segurança...';

  @override
  String get exportProgressFinalize => 'Abrindo o menu de compartilhar...';

  @override
  String exportSaveSuccess(String path) {
    return 'Cópia de segurança salva em $path';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Apagar';

  @override
  String get create => 'Criar';

  @override
  String get edit => 'Editar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get photo => 'Foto';

  @override
  String get url => 'URL';

  @override
  String get download => 'Baixar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get share => 'Compartilhar';

  @override
  String get saveToDevice => 'Salvar no dispositivo';

  @override
  String get addBookModalTitle => 'Adicionar livro';

  @override
  String get addBookModalSubtitle => 'Como você quer adicionar seu livro';

  @override
  String get addManually => 'Adicionar manualmente';

  @override
  String get addManuallySubtitle => 'Preencha os dados manualmente';

  @override
  String get searchBook => 'Buscar livro';

  @override
  String get searchBookSubtitle => 'Por título, autor ou ISBN';

  @override
  String get scanBarcode => 'Escanear o código de barras';

  @override
  String get scanBarcodeSubtitle => 'Escanear código de barras';

  @override
  String get scanIsbnText => 'Escanear o número ISBN';

  @override
  String get scanIsbnTextSubtitle => 'Aponte o número impresso';

  @override
  String get scanIsbnSelect => 'Toque em um ISBN para selecioná-lo';

  @override
  String get scanOcrHoldMessage =>
      'Deixe o celular parado por alguns segundos...';

  @override
  String get scanBarcodePermission =>
      'Requer permissão da câmera para escanear códigos';

  @override
  String get scanBatch => 'Escanear em lote';

  @override
  String get scanBatchSubtitle => 'Escanear vários livros seguidos';

  @override
  String get scanModeBarcode => 'Código de barras';

  @override
  String get scanModeIsbn => 'Número ISBN';

  @override
  String get bookFormNewTitle => 'Novo livro';

  @override
  String get bookFormEditTitle => 'Editar livro';

  @override
  String get tabMain => 'Início';

  @override
  String get tabDetails => 'Detalhes';

  @override
  String get fieldTitle => 'Título';

  @override
  String get fieldSubtitle => 'Subtítulo';

  @override
  String get fieldDescription => 'Sinopse';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Idioma';

  @override
  String get fieldIsTranslation => 'É uma tradução?';

  @override
  String get fieldOriginalTitle => 'Título original';

  @override
  String get fieldOriginalLanguage => 'Idioma original';

  @override
  String get fieldTranslator => 'Tradução';

  @override
  String get fieldReads => 'Leituras';

  @override
  String get fieldCopies => 'Cópias';

  @override
  String get fieldTotalPages => 'Total de páginas';

  @override
  String get fieldTotalBooks => 'Total de livros';

  @override
  String get fieldCurrentPage => 'Página atual';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldCollection => 'Coleção / Série';

  @override
  String get fieldCollectionNumber => 'Número da coleção';

  @override
  String get sectionBasicInfo => 'Informação básica';

  @override
  String get sectionCategories => 'Categorias';

  @override
  String get sectionReadingStatus => 'Progresso de leitura';

  @override
  String get sectionFormat => 'Formato';

  @override
  String get sectionRating => 'Avaliação';

  @override
  String get sectionImprint => 'Selo editorial';

  @override
  String get coverPickPhoto => 'Tirar foto';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Buscar';

  @override
  String get coverUrlDialogTitle => 'URL da capa';

  @override
  String get coverUrlHint => 'https://exemplo.com/capa.jpg';

  @override
  String get coverDownloadError => 'Não deu para baixar a imagem';

  @override
  String get imageProcessError => 'Não foi possível processar a imagem';

  @override
  String get cropCoverTitle => 'Cortar a imagem';

  @override
  String get cropImprintTitle => 'Cortar selo';

  @override
  String get tagSearchOrCreate => 'Procurar ou criar etiqueta';

  @override
  String get tagCreateHint => 'Escreva e aperte Enter para adicionar ou criar';

  @override
  String get tagNoCategories => 'Não há categorias criadas';

  @override
  String get imprintSearch => 'Buscar selo editorial';

  @override
  String get requiredField => 'Campo obrigatório';

  @override
  String get statusWantToRead => 'Quero ler';

  @override
  String get statusReading => 'Lendo';

  @override
  String get statusRead => 'Lido';

  @override
  String get statusAbandoned => 'Abandonado';

  @override
  String get statusPaused => 'Pausado';

  @override
  String get ownershipStatusBought => 'Comprado';

  @override
  String get ownershipStatusGifted => 'Ganhado';

  @override
  String get ownershipStatusBorrowed => 'Emprestado';

  @override
  String get ownershipStatusReturned => 'Devolvido';

  @override
  String get ownershipStatusSold => 'Vendido';

  @override
  String get ownershipStatusOther => 'Outro';

  @override
  String get formatPaperback => 'Brochura';

  @override
  String get formatHardcover => 'Capa dura';

  @override
  String get formatLeatherbound => 'Couro';

  @override
  String get formatRustic => 'Rústica';

  @override
  String get formatDigital => 'Digital';

  @override
  String get formatOther => 'Outros';

  @override
  String get bookDetailNotFound => 'Livro não encontrado';

  @override
  String get bookDetailPagePickerTitle => 'Página atual';

  @override
  String get bookDetailNotesTitle => 'Notas pessoais';

  @override
  String get bookDetailNotesHint => 'Escreva suas notas aqui...';

  @override
  String get bookDetailNotesEmpty => 'Toque para adicionar notas...';

  @override
  String get bookDetailDeleteTitle => 'Apagar livro';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Eliminar \"$title\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get bookDetailDuplicateTitle => 'Duplicar livro';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return 'Quer criar uma cópia exata de \"$title\"?';
  }

  @override
  String get bookDetailNewReadingWholeBook => 'Livro inteiro';

  @override
  String get bookDetailNewReadingWholeBookDescription =>
      'Uma releitura completa será registrada a partir de hoje.';

  @override
  String get bookDetailNewReadingSections => 'Seções';

  @override
  String bookDetailNewReadingSectionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seções',
      one: '1 seção',
    );
    return '$_temp0';
  }

  @override
  String bookDetailNewReadingReadCount(Object count) {
    return 'Lida ${count}x';
  }

  @override
  String get bookDetailNewReadingSelectSections =>
      'Selecionar seções para reler';

  @override
  String get bookDetailStartNewReadingPrompt =>
      'Quer começar uma nova leitura?';

  @override
  String get bookDetailStartNewReadingTitle => 'Nova leitura';

  @override
  String get bookDetailStartNewReadingButton => 'Começar nova leitura';

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get bookDetailDeleteReadPrompt =>
      'Excluir a última leitura em andamento? As datas desta sessão serão perdidas.';

  @override
  String get bookDetailReadHistoryTitle => 'HISTÓRICO DE LEITURAS';

  @override
  String get bookDetailReadOngoing => 'em andamento';

  @override
  String bookDetailReadNumber(int number) {
    return 'Leitura $number';
  }

  @override
  String bookDetailReadEditDialogTitle(Object number) {
    return 'Editar leitura $number';
  }

  @override
  String get bookDetailReadDeleteConfirm =>
      'Excluir esta entrada do histórico?';

  @override
  String get bookDetailReadNumberLabel => 'Número da leitura';

  @override
  String get bookDetailFieldPages => 'Páginas';

  @override
  String get bookDetailFieldCategories => 'Categorias';

  @override
  String get bookDetailFieldFormat => 'Formato';

  @override
  String get bookDetailFieldRating => 'Avaliação';

  @override
  String get bookDetailFieldImprintSection => 'SELO EDITORIAL';

  @override
  String get bookDetailFieldPersonalNotes => 'Notas pessoais';

  @override
  String get bookDetailFieldAdded => 'Adicionado';

  @override
  String get bookDetailFieldStarted => 'Iniciar leitura';

  @override
  String get bookDetailFieldFinished => 'Fim da leitura';

  @override
  String get fieldOwnershipStatus => 'Estado de propriedade';

  @override
  String get ownershipHistoryTitle => 'HISTÓRICO DE PROPRIEDADE';

  @override
  String get ownershipLogEmpty => 'Não há eventos de propriedade registrados.';

  @override
  String get ownershipEventPerson => 'Pessoa / Quem';

  @override
  String get ownershipEventDate => 'Data';

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
  String get shelvesTitle => 'Estantes';

  @override
  String get shelvesSectionByStatus => 'Por estado';

  @override
  String get shelvesSectionMine => 'Estantes';

  @override
  String get shelvesSectionManagement => 'Gerenciamento';

  @override
  String get shelfAllBooks => 'Todos os livros';

  @override
  String get shelfReading => 'Lendo';

  @override
  String get shelfRead => 'Lidos';

  @override
  String booksReadProgress(int readCount, int totalCount) {
    return '$readCount / $totalCount livros lidos';
  }

  @override
  String get shelfWantToRead => 'Quero ler';

  @override
  String get shelfAbandoned => 'Abandonados';

  @override
  String get shelfPaused => 'Pausados';

  @override
  String get shelfNewTooltip => 'Nova estante';

  @override
  String get shelfEmpty => 'Você não tem estantes personalizadas';

  @override
  String get shelfEmptySubtitle => 'Organize suas leituras como quiser';

  @override
  String get shelvesAddFirstShelf => 'Criar estante';

  @override
  String get shelfBooksEmpty => 'Esta estante está vazia';

  @override
  String get shelfBooksEmptyHint =>
      'Os livros que correspondem aos seus critérios aparecerão aqui.';

  @override
  String get shelfStatusBooksEmpty => 'Não há livros aqui';

  @override
  String get shelfFormNew => 'Nova estante';

  @override
  String get shelfFormEdit => 'Editar estante';

  @override
  String get shelfFormNameLabel => 'Nome da estante';

  @override
  String get collectionNameLabel => 'Nome da coleção';

  @override
  String get shelfFormSectionStatus => 'Estado de leitura';

  @override
  String get shelfFormSectionTitle => 'Título';

  @override
  String get shelfFormSectionAuthor => 'Autor';

  @override
  String get shelfFormSectionPublisher => 'Editora';

  @override
  String get shelfFormSectionIsbn => 'ISBN';

  @override
  String get shelfFormSectionCollection => 'Coleção';

  @override
  String get shelfFormSectionCategories => 'Categorias';

  @override
  String get shelfFormSectionImprint => 'Selo editorial';

  @override
  String get shelfFormHintTitle => 'Buscar no título';

  @override
  String get shelfFormHintAuthor => 'Nome do autor';

  @override
  String get shelfFormHintPublisher => 'Nome da editora';

  @override
  String get shelfFormHintIsbn => 'ISBN';

  @override
  String get shelfFormHintCollection => 'Nome da coleção';

  @override
  String get shelfFormStatusAny => 'Qualquer um';

  @override
  String get shelfOptionEdit => 'Editar estante';

  @override
  String get shelfOptionDelete => 'Excluir';

  @override
  String get shelfStatusLabelReading => 'Lendo';

  @override
  String get shelfStatusLabelRead => 'Lidos';

  @override
  String get shelfStatusLabelWantToRead => 'Quero ler';

  @override
  String get shelfStatusLabelAbandoned => 'Abandonados';

  @override
  String get shelfStatusLabelPaused => 'Pausados';

  @override
  String get managementCategories => 'Categorias';

  @override
  String get managementCategoryCount => 'Nº de livros';

  @override
  String get managementImprints => 'Selos';

  @override
  String get managementCollections => 'Coleções';

  @override
  String get managementCategoryCloudCurve => 'Curva algorítmica (Libros)';

  @override
  String get tagNone => 'Não há categorias ainda';

  @override
  String get tagNoneSubtitle =>
      'As categorias ajudam você a encontrar livros e a construir um mapa mental da sua biblioteca';

  @override
  String get categoriesAddFirst => 'Nova categoria';

  @override
  String get tagNew => 'Nova categoria';

  @override
  String get tagNewDialogTitle => 'Nova categoria';

  @override
  String get tagNameLabel => 'Nome';

  @override
  String get tagColorLabel => 'Cor';

  @override
  String get tagDeleteTitle => 'Excluir categoria';

  @override
  String tagDeleteConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get imprintNone => 'Não há selos ainda';

  @override
  String get imprintNoneSubtitle =>
      'Agrupe seus livros por editoras ou seus selos';

  @override
  String get imprintsAddFirst => 'Adicionar selo';

  @override
  String get imprintNew => 'Novo selo';

  @override
  String get imprintNewDialogTitle => 'Novo selo editorial';

  @override
  String get imprintEditDialogTitle => 'Editar selo';

  @override
  String get imprintNameLabel => 'Nome do selo';

  @override
  String get imprintAddImageHint => 'Pressione para adicionar imagem';

  @override
  String get imprintChangeImageHint => 'Pressione para mudar imagem';

  @override
  String get imprintUrlDialogTitle => 'URL da imagem';

  @override
  String get imprintUrlHint => 'https://exemplo.com/selo.jpg';

  @override
  String get imprintDeleteTitle => 'Excluir selo';

  @override
  String imprintDeleteConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get imprintNoImprints => 'Não há selos criados';

  @override
  String get collectionNone => 'Não há coleções ainda';

  @override
  String get collectionNoneSubtitle => 'Crie coleções e organize seus livros';

  @override
  String get collectionsAddFirst => 'Nova coleção';

  @override
  String get collectionDeleteTitle => 'Excluir coleção';

  @override
  String collectionDeleteConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao Openshelf';

  @override
  String get onboardingWelcomeSub => 'Sua biblioteca pessoal, reimaginada';

  @override
  String get onboardingOrganizeTitle => 'Organize seu mundo';

  @override
  String get onboardingOrganizeSub =>
      'Crie estantes inteligentes e coleções temáticas';

  @override
  String get onboardingProgressTitle => 'Acompanhe seu progresso';

  @override
  String get onboardingProgressSub =>
      'Metas de leitura e estatísticas detalhadas';

  @override
  String get onboardingAddTitle => 'Adicione instantaneamente';

  @override
  String get onboardingAddSub =>
      'Escaneie códigos de barras ou busque na nuvem';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingStart => 'Começar agora';

  @override
  String get settingsApplyIcon => 'Aplicar mudança de ícone';

  @override
  String get settingsDynamicIcon => 'Ícone do app dinâmico';

  @override
  String get settingsDynamicIconSub =>
      'Muda o ícone da tela inicial para corresponder à cor escolhida (O app será reiniciado)';

  @override
  String get settingsLibraryColumns => 'Colunas na biblioteca';

  @override
  String get settingsLibraryColumnsSub =>
      'Ajusta o número de livros por linha na visualização de grade';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSectionAppearance => 'Aparência';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema (automático)';

  @override
  String get settingsLanguageSpanish => 'Espanhol';

  @override
  String get settingsLanguageEnglish => 'Inglês';

  @override
  String get settingsThemeMode => 'Modo de tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsAccentColor => 'Cor de destaque';

  @override
  String get settingsAccentColorHint => 'Toque em uma cor para aplicá-la';

  @override
  String get settingsSectionStorage => 'Armazenamento';

  @override
  String get settingsCoversFolder => 'Pasta de capas';

  @override
  String get settingsDatabase => 'Banco de dados';

  @override
  String get settingsDefaultDir => 'Diretório padrão';

  @override
  String get settingsDbMoveTitle => 'Mover banco de dados';

  @override
  String get settingsDbMoveContent =>
      'Mover o banco de dados requer reiniciar o app. Os datos serão copiados para o novo diretório. Continuar?';

  @override
  String get settingsDbMoveConfirm => 'Mover e reiniciar';

  @override
  String get settingsSectionSearch => 'Busca de livros';

  @override
  String get settingsSearchServer => 'Servidor';

  @override
  String get settingsSearchServerHint =>
      'Será usado para buscar livros por ISBN ou título';

  @override
  String get settingsSectionData => 'Gerenciamento de dados';

  @override
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => 'Importar livros';

  @override
  String get dataManagementExport => 'Exportar livros';

  @override
  String dataManagementImportHint(String source) {
    return 'Importar do CSV do $source';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return 'Importar do JSON do $source';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Exportar para o CSV do $source';
  }

  @override
  String dataManagementExportHintJson(Object source) {
    return 'Exportar para o JSON do $source';
  }

  @override
  String get dataManagementRestoreBackup => 'Restaurar cópia de segurança';

  @override
  String get dataManagementRestoreBackupHint =>
      'Restaurar do CSV/ZIP do OpenShelf';

  @override
  String get dataManagementCreateBackup => 'Criar cópia de segurança';

  @override
  String get dataManagementCreateBackupHint => 'Full export with covers option';

  @override
  String get settingsImportBookshelf => 'Importar do Bookshelf';

  @override
  String get settingsImportBookshelfHint => 'Importar livros de um arquivo CSV';

  @override
  String get settingsExportCsv => 'Exportar biblioteca';

  @override
  String get settingsExportCsvHint =>
      'Exportar todos os livros para um arquivo CSV';

  @override
  String get settingsFullBackup => 'Restaurar biblioteca';

  @override
  String get settingsFullBackupHint =>
      'Restaurar livros de uma cópia de segurança CSV';

  @override
  String get settingsAllFilesAccess => 'Acesso a todos os arquivos';

  @override
  String get settingsAllFilesAccessSub =>
      'Necessário para mover o banco de dados para pastas externas (Android 11+)';

  @override
  String get settingsAllFilesAccessInfo =>
      'Esta permissão permite que o Openshelf gerencie arquivos fora de seu diretório privado. É necessário para mover o banco de dados para uma pasta personalizada.';

  @override
  String get settingsAutoNoCoverTitle => 'Estante sem capas';

  @override
  String get settingsAutoNoCoverSub =>
      'Cria automaticamente uma estante se faltarem capas';

  @override
  String get noCoverShelfTitle => 'Livros sem capa';

  @override
  String get settingsCompressImagesTitle => 'Comprimir capas automaticamente';

  @override
  String get settingsCompressImagesSub =>
      'Reduz o peso das imagens ao salvá-las ou importá-las';

  @override
  String get settingsBatchCompressTitle => 'Otimizar biblioteca agora';

  @override
  String get settingsBatchCompressSub =>
      'Comprime todas as capas existentes que não estão otimizadas';

  @override
  String settingsBatchCompressSuccess(int count) {
    return 'Foram otimizadas $count capas.';
  }

  @override
  String get exportTitle => 'Exportar biblioteca';

  @override
  String get exportCoversPrompt =>
      'Você quer incluir as imagens das capas na cópia de segurança? (Um arquivo ZIP será criado junto ao CSV)';

  @override
  String get importRestoreCoversTitle => 'Restaurar capas';

  @override
  String get importRestoreCoversPrompt =>
      'Você também tem um arquivo ZIP com as capas para restaurar?';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get devDeleteAllBooks => 'APAGAR TODOS OS LIVROS (DEV)';

  @override
  String get settingsDevClearDbSub =>
      'Herramienta de desenvolvedor: limpar banco de dados';

  @override
  String get settingsDevDbCleared => 'Banco de dados limpo';

  @override
  String get settingsImportSelectBackup =>
      'Selecionar cópia de segurança do Openshelf';

  @override
  String get settingsImportSelectCovers =>
      'Selecionar ZIP de capas do Openshelf';

  @override
  String get devDeleteConfirmTitle => 'Esvaziar Biblioteca?';

  @override
  String get devDeleteConfirmContent =>
      'Isso excluirá permanentemente TODOS os livros e categorias. Apenas para testes. Continuar?';

  @override
  String importSuccess(int count) {
    return 'Importação concluída: $count livros adicionados.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Importação parcial: $added adicionados, $skipped ignorados.';
  }

  @override
  String get settingsApiKeyTitle => 'Google Books API key';

  @override
  String get settingsApiKeyConfigured =>
      'Chave configurada. Google Books está disponível.';

  @override
  String get settingsApiKeyMissing =>
      'Sem chave, Google Books usará Open Library como alternativa.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Mostrar';

  @override
  String get settingsApiKeyHide => 'Ocultar';

  @override
  String get settingsApiKeySave => 'Salvar chave';

  @override
  String get settingsApiKeySaved => 'Chave salva';

  @override
  String get settingsApiKeyClear => 'Apagar chave';

  @override
  String get settingsApiKeyHowTo => 'Como obter';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'Como obter uma chave do Google Books';

  @override
  String get settingsApiKeyStep1 =>
      'Abra console.cloud.google.com e faça login com sua conta do Google.';

  @override
  String get settingsApiKeyStep2 =>
      'Crie um projeto novo (o nome não importa).';

  @override
  String get settingsApiKeyStep3 =>
      'Vá em APIs e serviços → Biblioteca, procure por \"Books API\" e ative-a.';

  @override
  String get settingsApiKeyStep4 =>
      'Vá em APIs e serviços → Credenciais → Criar credenciais → API Key.';

  @override
  String get settingsApiKeyStep5 =>
      'Opcional mas recomendado: restrinja a chave apenas à Books API.';

  @override
  String get settingsApiKeyStep6 =>
      'Copie a chave resultante (começa com \"AIza…\") e cole no campo acima.';

  @override
  String get settingsApiKeyNote =>
      'A chave é gratuita e permite até 1.000 buscas diárias. Não é compartilhada com ninguém: é salva apenas neste dispositivo.';

  @override
  String get bookSearchHint => 'Título, autor ou ISBN...';

  @override
  String get bookSearchPrompt => 'Busque por título, autor ou ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Sem resultados para \"$query\"';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return 'Resultados de: $providers.';
  }

  @override
  String get bookSearchRecommended => 'RECOMENDADO PELO OPENSHELF';

  @override
  String get bookSearchRecommendedSource => 'Recomendado pelo Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Open Library';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get searchTabStatus => 'Estado';

  @override
  String get searchTabImprint => 'Selo';

  @override
  String get searchTabCategory => 'Categoria';

  @override
  String get searchTabCollection => 'Coleção';

  @override
  String searchFilterStatus(String value) {
    return 'Estado: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Selo: $value';
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
      other: '$count filtres ativos',
      one: '1 filtro ativo',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => 'Salvar como estante';

  @override
  String get shelfShowInLibrary => 'Mostrar na biblioteca';

  @override
  String get searchClearAll => 'Limpar tudo';

  @override
  String get addedToLibrary => 'Adicionado à biblioteca';

  @override
  String get errorDuplicateIsbn => 'Já está na biblioteca';

  @override
  String get bookDuplicateTitle => 'Livro duplicado';

  @override
  String bookDuplicateContent(String isbn) {
    return 'Você já tem um libro com o ISBN $isbn na sua biblioteca.';
  }

  @override
  String get bookSearchErrorNoApiKey =>
      'Google Books requer uma chave de API.\nConfigure-a em Configurações → Busca de livros.';

  @override
  String get bookSearchErrorRateLimit =>
      'Google Books limitou as requisições.\nEspere um momento e tente novamente.';

  @override
  String get bookSearchErrorNetwork =>
      'Não foi possível conectar a nenhum servidor.\nVerifique sua conexão e tente novamente.';

  @override
  String get coverPickerTitle => 'Capas';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults =>
      'Não foram encontradas capas para este livro.';

  @override
  String get coverPickerNetworkError =>
      'Não foi possível conectar. Verifique sua conexão.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get statsPlaceholder => 'Suas estatísticas aparecerão aqui';

  @override
  String get statsEmptySubtitle =>
      'Adicione widgets para ver seus hábitos de leitura, metas e recordes pessoais.';

  @override
  String get statsAddFirstWidget => 'Adicionar primeiro widget';

  @override
  String get statsAddWidgetTitle => 'Adicionar widget';

  @override
  String get statsGoalTargetShelf => 'Estante objetivo';

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
    return 'Editora: $publisher';
  }

  @override
  String get statsGoalTitle => 'META';

  @override
  String get statsGoalFullTitle => 'META DE LEITURA';

  @override
  String get statsGoalUnitBooks => 'livros';

  @override
  String get statsGoalUnitPages => 'págs';

  @override
  String statsGoalRemaining(int count) {
    return 'Faltam $count';
  }

  @override
  String get statsGoalCompleted => 'Pronto!';

  @override
  String get statsGoalNew => 'Nova meta';

  @override
  String get statsGoalEdit => 'Editar meta';

  @override
  String get statsGoalDelete => 'Excluir';

  @override
  String get statsGoalNameLabel => 'Nome (ex: Desafio 2026)';

  @override
  String get statsGoalTypeLabel => 'Tipo';

  @override
  String get statsGoalTypeBooks => 'Libros lidos';

  @override
  String get statsGoalTypePages => 'Páginas lidas';

  @override
  String get statsGoalTargetLabel => 'Objetivo numérico';

  @override
  String get statsGoalFromLabel => 'Desde';

  @override
  String get statsGoalToLabel => 'Até';

  @override
  String get statsPagesTitle => 'PÁGINAS';

  @override
  String get statsPagesSub => 'páginas lidas';

  @override
  String get statsStreakTitle => 'SEQUÊNCIA';

  @override
  String get statsStreakSub => 'dias seguidos';

  @override
  String get statsStatusTitle => 'ESTADOS';

  @override
  String get statsAddedTitle => 'LIVROS ADICIONADOS';

  @override
  String get statsAddedNoData => 'Sem dados';

  @override
  String get statsCategoriesTitle => 'CATEGORIAS';

  @override
  String get statsYearsTitle => 'ANOS DE PUBLICAÇÃO';

  @override
  String get statsReadingTitle => 'LEITURA';

  @override
  String get statsReadingNowTitle => 'LENDO AGORA';

  @override
  String get statsReadingNone => 'Nada em leitura';

  @override
  String get statsReadByYearTitle => 'LIVROS LIDOS POR ANO';

  @override
  String get statsCollectionsTitle => 'COLEÇÕES';

  @override
  String get statsLastAddedTitle => 'ÚLTIMOS ADICIONADOS';

  @override
  String get statsDailyReadingTitle => 'LEITURA DIÁRIA';

  @override
  String get statsAvgPagesTitle => 'MÉDIA DE PÁGINAS';

  @override
  String get statsAvgPagesSub => 'páginas por livro';

  @override
  String get statsOptPagesTitle => 'Total de páginas';

  @override
  String get statsOptPagesSub => 'Total de páginas lidas';

  @override
  String get statsOptStreakTitle => 'Sequência';

  @override
  String get statsOptStreakSub => 'Dias consecutivos lendo';

  @override
  String get statsOptGoalTitle => 'Meta de leitura';

  @override
  String get statsOptGoalSub => 'Livros, estantes ou coleções';

  @override
  String get statsOptStatusTitle => 'Estados de leitura';

  @override
  String get statsOptStatusSub => 'Libros por estado';

  @override
  String get statsOptCurrentTitle => 'Livro atual';

  @override
  String get statsOptCurrentSub => 'Progresso de leitura em andamento';

  @override
  String get statsOptAddedTimeTitle => 'Livros adicionados';

  @override
  String get statsOptAddedTimeSub => 'Gráfico temporal de aquisições';

  @override
  String get statsOptCategoriesTitle => 'Categorias';

  @override
  String get statsOptCategoriesSub => 'Distribuição por gêneros';

  @override
  String get statsOptYearsTitle => 'Ano de publicação';

  @override
  String get statsOptYearsSub => 'Histograma histórico';

  @override
  String get statsOptReadYearTitle => 'Lidos por ano';

  @override
  String get statsOptReadYearSub => 'Gráfico de leitura anual';

  @override
  String get statsOptCollectionsTitle => 'Coleções';

  @override
  String get statsOptCollectionsSub => 'Libros por coleção';

  @override
  String get statsOptLastAddedTitle => 'Últimos adicionados';

  @override
  String get statsOptLastAddedSub => 'Recém chegados';

  @override
  String get statsOptAvgPagesTitle => 'Extensão média';

  @override
  String get statsOptAvgPagesSub => 'Páginas médias por livro';

  @override
  String get statsOptReadListTitle => 'Lista de lidos';

  @override
  String get statsOptReadListSub => 'Livros lidos em um período';

  @override
  String get statsOptAvgCompletionTitle => 'Tempo de leitura';

  @override
  String get statsOptAvgCompletionSub => 'Tempo médio para terminar um livro';

  @override
  String get statsOptDailyReadingTitle => 'Leitura diária';

  @override
  String get statsOptDailyReadingSub => 'Páginas lidas por dia';

  @override
  String statsAvgCompletionValue(String days) {
    return '$days dias';
  }

  @override
  String get statsPeriodThisMonth => 'Lidos este mês';

  @override
  String get statsPeriodLast3Months => 'Últimos 3 meses';

  @override
  String get statsPeriodThisYear => 'Lidos este ano';

  @override
  String get statsPeriodLast3Years => 'Últimos 3 anos';

  @override
  String get tabMore => 'mais';

  @override
  String get sortTitle => 'Ordenar';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get permissionRequired => 'Permissão necessária';

  @override
  String get paginationMarkersAndIndices => 'Seções e marcadores';

  @override
  String get paginationSaveProgress => 'Salvar Progresso';

  @override
  String get paginationAllPagesAssigned =>
      'Todas as páginas já foram atribuídas.';

  @override
  String get paginationChooseColor => 'Escolher cor';

  @override
  String paginationSegmentRequired(Object index) {
    return 'Segmento $index: Todos os campos de página são obrigatórios.';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return 'Segmento $index: O início não pode ser maior que o fim.';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return 'Segmento $index: Os valores excedem o total de páginas ($total).';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return 'O segmento $index1 se sobrepõe ao segmento $index2';
  }

  @override
  String get paginationAdvancedConfig => 'Configuração avançada';

  @override
  String get paginationBlocksSegments => 'BLOCOS / SEGMENTOS';

  @override
  String get paginationNoSegmentsDefined =>
      'Não há segmentos definidos. O intervalo 1-N é usado por padrão.';

  @override
  String get paginationAddBlock => 'Adicionar bloco';

  @override
  String get paginationAllPagesAssignedNote =>
      'Nota: Você já atribuiu todas as páginas disponíveis.';

  @override
  String paginationPagesRemainingWarning(int count) {
    return 'Aviso: Restam $count páginas físicas sem atribuir.';
  }

  @override
  String get paginationPhysicalTotalNote =>
      'Nota: O total de páginas refere-se às páginas físicas do livro (folhas totais).';

  @override
  String get paginationCorrectErrors => 'CORRIJA OS SEGUINTES ERROS:';

  @override
  String get paginationMarkersLabels => 'MARCADORES / ETIQUETAS';

  @override
  String get paginationMarkerDefaultName => 'Marcador';

  @override
  String get paginationSegmentsDefaultName => 'Bloco';

  @override
  String get paginationAddMarker => 'Adicionar marcador';

  @override
  String get paginationLabelOptional => 'Etiqueta (opcional)';

  @override
  String get paginationType => 'Tipo:';

  @override
  String get paginationArabic => 'Arábico';

  @override
  String get paginationRoman => 'Romano';

  @override
  String get paginationOffset => 'Offset';

  @override
  String get paginationMarkerLabel => 'Etiqueta do marcador';

  @override
  String get paginationVisualPage => 'Página Visual';

  @override
  String get paginationVisualPageHint => 'Ex: xiv ou 501';

  @override
  String paginationPhysicalLabel(Object page) {
    return 'Física: $page';
  }

  @override
  String get paginationAdjustsAutomatically => 'Ajusta-se automaticamente';

  @override
  String get paginationVisualMode => 'Modo visual';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return 'Equivale a físicas: $start - $end';
  }

  @override
  String paginationSectionLabel(int index) {
    return 'Seção $index';
  }

  @override
  String paginationProgress(String current, String total) {
    return '$current / $total';
  }

  @override
  String get paginationCurrentPageShort => 'Pág.';

  @override
  String get paginationStartPhysical => 'Início (Físico)';

  @override
  String get paginationEndPhysical => 'Fim (Físico)';

  @override
  String get paginationStartVisual => 'Início (Visual)';

  @override
  String get paginationEndVisual => 'Fim (Visual)';

  @override
  String get paginationAdvancedButton => 'Avançada';

  @override
  String get unknownAuthor => 'Desconhecido';

  @override
  String get storagePermissionExplanation =>
      'Para selecionar uma capa você precisa conceder acesso ao armazenamento. Você pode fazer isso nas configurações do aplicativo.';

  @override
  String get cameraPermissionExplanation =>
      'Para tirar uma foto você precisa conceder acesso à câmera. Você pode fazer isso nas configurações do aplicativo.';
}
