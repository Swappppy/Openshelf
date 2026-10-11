// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Openshelf';

  @override
  String errorPrefix(String message) {
    return 'Ошибка: $message';
  }

  @override
  String errorGeneric(String error) {
    return 'Ошибка: $error';
  }

  @override
  String criticalStartError(String error) {
    return 'Ошибка запуска приложения: $error';
  }

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navShelves => 'Полки';

  @override
  String get navStats => 'Статистика';

  @override
  String get libraryTitle => 'Библиотека';

  @override
  String get libraryEmpty => 'Ваша библиотека пуста';

  @override
  String get libraryEmptyHint => 'Какой будет ваша первая книга?';

  @override
  String get libraryAddFirstBook => 'Добавьте первую книгу';

  @override
  String get libraryNoResults => 'Нет результатов';

  @override
  String get libraryNoResultsHint => 'Попробуйте другие фильтры';

  @override
  String get addBook => 'Добавьте книгу';

  @override
  String get displaySettings => 'Показать в библиотеке';

  @override
  String get displaySettingsDragHint => 'Перетащите для изменения порядка';

  @override
  String get settingsButton => 'Настройки';

  @override
  String get fieldAuthor => 'Автор';

  @override
  String get fieldPublisher => 'Издатель';

  @override
  String get fieldYear => 'Год публикации';

  @override
  String get fieldRating => 'Рейтинг';

  @override
  String get fieldTags => 'Метки';

  @override
  String get fieldReadingProgress => 'Прогресс чтения';

  @override
  String get fieldStatusChip => 'Метка статуса';

  @override
  String get searchHint => 'Поиск по заголовку...';

  @override
  String get filterAuthor => 'Автор';

  @override
  String get filterIsbn => 'ISBN';

  @override
  String get filterPublisher => 'Издатель';

  @override
  String get filterCollection => 'Коллекция';

  @override
  String get filterImprintLabel => 'Издательская марка';

  @override
  String imprintBookCount(int count) {
    return '$count книг';
  }

  @override
  String get filterTagsLabel => 'Категории';

  @override
  String get done => 'Готово';

  @override
  String get loading => 'Загрузка...';

  @override
  String get loadingImport => 'Импорт книг, подождите...';

  @override
  String get loadingExport => 'Экспорт книг, подождите...';

  @override
  String get exportProgressData => 'Экспорт данных...';

  @override
  String get exportProgressMedia => 'Подготовка медиафайлов...';

  @override
  String get exportProgressCompress => 'Сжатие резервной копии...';

  @override
  String get exportProgressFinalize => 'Открытие меню...';

  @override
  String exportSaveSuccess(String path) {
    return 'Резервная копия сохранена в $path';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get create => 'Создать';

  @override
  String get edit => 'Редактировать';

  @override
  String get duplicate => 'Дубликат';

  @override
  String get photo => 'Фото';

  @override
  String get url => 'URL';

  @override
  String get download => 'Скачать';

  @override
  String get retry => 'Повторить';

  @override
  String get share => 'Поделиться';

  @override
  String get saveToDevice => 'Сохранить на устройстве';

  @override
  String get addBookModalTitle => 'Добавьте книгу';

  @override
  String get addBookModalSubtitle =>
      'Выберите, как вы хотите добавить свою книгу';

  @override
  String get addManually => 'Добавить вручную';

  @override
  String get addManuallySubtitle => 'Заполните данные самостоятельно';

  @override
  String get searchBook => 'Поиск книг';

  @override
  String get searchBookSubtitle => 'Поиск по имени, автору или ISBN';

  @override
  String get scanBarcode => 'Сканировать штрихкод';

  @override
  String get scanBarcodeSubtitle => 'Направьте камеру на ISBN';

  @override
  String get scanIsbnText => 'Сканируйте ISBN номер';

  @override
  String get scanIsbnTextSubtitle => 'Наведите на напечатанный номер';

  @override
  String get scanIsbnSelect => 'Выберите ISBN';

  @override
  String get scanOcrHoldMessage =>
      'Задержитесь на изображении на несколько секунд...';

  @override
  String get scanBarcodePermission => 'Разрешить камеру для сканирования кодов';

  @override
  String get scanBatch => 'Сканировать несколько';

  @override
  String get scanBatchSubtitle => 'Сканировать несколько книг подряд';

  @override
  String get scanModeBarcode => 'Баркод';

  @override
  String get scanModeIsbn => 'Номер ISBN';

  @override
  String get bookFormNewTitle => 'Новая книга';

  @override
  String get bookFormEditTitle => 'Редактировать книгу';

  @override
  String get tabMain => 'Главная';

  @override
  String get tabDetails => 'Информация';

  @override
  String get fieldTitle => 'Название книги';

  @override
  String get fieldSubtitle => 'Подзаголовок';

  @override
  String get fieldDescription => 'Описание';

  @override
  String get fieldIsbn => 'ISBN';

  @override
  String get fieldLanguage => 'Язык';

  @override
  String get fieldIsTranslation => 'Это перевод?';

  @override
  String get fieldOriginalTitle => 'Оригинальное название';

  @override
  String get fieldOriginalLanguage => 'Язык оригинала';

  @override
  String get fieldTranslator => 'Переводчик';

  @override
  String get fieldReads => 'Чтение';

  @override
  String get fieldCopies => 'Копии';

  @override
  String get fieldTotalPages => 'Всего страниц';

  @override
  String get fieldTotalBooks => 'Всего книг';

  @override
  String get fieldCurrentPage => 'Текущая страница';

  @override
  String get fieldNotes => 'Заметки';

  @override
  String get fieldCollection => 'Коллекция/серия';

  @override
  String get fieldCollectionNumber => 'Количество в коллекциях';

  @override
  String get sectionBasicInfo => 'Базовая информация';

  @override
  String get sectionCategories => 'Категории';

  @override
  String get sectionReadingStatus => 'Прогресс чтения';

  @override
  String get sectionFormat => 'Формат';

  @override
  String get sectionRating => 'Рейтинг';

  @override
  String get sectionImprint => 'Издательская марка';

  @override
  String get coverPickPhoto => 'Фото';

  @override
  String get coverPickUrl => 'URL';

  @override
  String get coverSearch => 'Поиск';

  @override
  String get coverUrlDialogTitle => 'URL-адрес обложки';

  @override
  String get coverUrlHint => 'https://ejemplo.com/portada.jpg';

  @override
  String get coverDownloadError => 'Невозможно загрузить изображение';

  @override
  String get imageProcessError => 'Не удалось обработать изображение';

  @override
  String get imageProcessing => 'Обработка изображения...';

  @override
  String get imagePreparing => 'Подготовка изображения...';

  @override
  String get imageOptimizing => 'Оптимизация изображения...';

  @override
  String get cropCoverTitle => 'Обрезать обложку';

  @override
  String get cropImprintTitle => 'Обрезать издательскую марку';

  @override
  String get tagSearchOrCreate => 'Поиск или создание категории';

  @override
  String get tagCreateHint =>
      'Введите текст и нажмите ввод, чтобы добавить или создать';

  @override
  String get tagNoCategories => 'Категории пока не созданы';

  @override
  String get imprintSearch => 'Найти издательскую марку';

  @override
  String get requiredField => 'Обязательное поле';

  @override
  String get statusWantToRead => 'Хочу прочесть';

  @override
  String get statusReading => 'Чтение';

  @override
  String get statusRead => 'Читаю';

  @override
  String get statusAbandoned => 'Брошено';

  @override
  String get statusPaused => 'На паузе';

  @override
  String get ownershipStatusBought => 'Куплено';

  @override
  String get ownershipStatusGifted => 'Подарено';

  @override
  String get ownershipStatusBorrowed => 'Взял почитать';

  @override
  String get ownershipStatusReturned => 'Возвращено';

  @override
  String get ownershipStatusSold => 'Продано';

  @override
  String get ownershipStatusOther => 'Другое';

  @override
  String get formatPaperback => 'Мягкая обложка';

  @override
  String get formatHardcover => 'Твердая обложка';

  @override
  String get formatLeatherbound => 'Кожаный переплет';

  @override
  String get formatRustic => 'Мягкий переплёт';

  @override
  String get formatDigital => 'Цифровой';

  @override
  String get formatOther => 'Другой';

  @override
  String get bookDetailNotFound => 'Книга не найдена';

  @override
  String get bookDetailPagePickerTitle => 'Текущая страница';

  @override
  String get bookDetailNotesTitle => 'Личная заметка';

  @override
  String get bookDetailNotesHint => 'Напишите свои заметки здесь...';

  @override
  String get bookDetailNotesEmpty => 'Нажмите, чтобы добавить заметки...';

  @override
  String get bookDetailDeleteTitle => 'Удалите книгу';

  @override
  String bookDetailDeleteConfirm(String title) {
    return 'Удалить \"$title\"? Это действие нельзя отменить.';
  }

  @override
  String get bookDetailDuplicateTitle => 'Дубликат книги';

  @override
  String bookDetailDuplicateConfirm(String title) {
    return 'Хотите создать точную копию \"$title\"?';
  }

  @override
  String get bookDetailNewReadingWholeBook => 'Вся книга';

  @override
  String get bookDetailNewReadingWholeBookDescription =>
      'Полное перечитывание будет записано с сегодняшнего дня.';

  @override
  String get bookDetailNewReadingSections => 'Разделы';

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
    return 'Чтение ${count}x';
  }

  @override
  String get bookDetailNewReadingSelectSections =>
      'Выберите раздел для перечитывания';

  @override
  String get bookDetailStartNewReadingPrompt => 'Хотите начать новое чтение?';

  @override
  String get bookDetailStartNewReadingTitle => 'Новое чтение';

  @override
  String get bookDetailStartNewReadingButton => 'Начало нового чтения';

  @override
  String get selectAll => 'Выберите все';

  @override
  String get bookDetailDeleteReadPrompt =>
      'Удалить последнюю текущую сессию чтения? Данные этой сессии будут потеряны.';

  @override
  String get bookDetailReadHistoryTitle => 'ИСТОРИЯ ЧТЕНИЯ';

  @override
  String get bookDetailReadOngoing => 'текущий';

  @override
  String bookDetailReadNumber(int number) {
    return 'Чтение $number';
  }

  @override
  String bookDetailReadEditDialogTitle(Object number) {
    return 'Редактирование чтения $number';
  }

  @override
  String get bookDetailReadDeleteConfirm => 'Удалить текущую историю ?';

  @override
  String get bookDetailReadNumberLabel => 'Номер прочтения';

  @override
  String get bookDetailFieldPages => 'СТРАНИЦЫ';

  @override
  String get bookDetailFieldCategories => 'КАТЕГОРИИ';

  @override
  String get bookDetailFieldFormat => 'Формат';

  @override
  String get bookDetailFieldRating => 'РЕЙТИНГ';

  @override
  String get bookDetailFieldImprintSection => 'ИЗДАТЕЛЬ';

  @override
  String get bookDetailFieldPersonalNotes => 'ПЕРСОНАЛЬНЫЕ ЗАМЕТКИ';

  @override
  String get bookDetailFieldAdded => 'Добавлено';

  @override
  String get bookDetailFieldStarted => 'Начало чтения';

  @override
  String get bookDetailFieldFinished => 'Окончание чтения';

  @override
  String get fieldOwnershipStatus => 'Статус владения';

  @override
  String get ownershipHistoryTitle => 'ИСТОРИЯ ВЛАДЕНИЯ';

  @override
  String get ownershipLogEmpty =>
      'Событий, связанных с владением, не зафиксировано.';

  @override
  String get ownershipEventPerson => 'Лицо / Кто';

  @override
  String get ownershipEventDate => 'Дата';

  @override
  String get ownershipEventNotes => 'Заметки';

  @override
  String pageProgress(String current, String total, String percent) {
    return '$current / $total стр. · $percent%';
  }

  @override
  String pageProgressShort(String current, String total) {
    return '$current / $total';
  }

  @override
  String pageSuffix(int count) {
    return '$count страниц.';
  }

  @override
  String get pagesLabel => 'страницы';

  @override
  String get shelvesTitle => 'Полки';

  @override
  String get shelvesSectionByStatus => 'По статусу';

  @override
  String get shelvesSectionMine => 'Полки';

  @override
  String get shelvesSectionManagement => 'Управление';

  @override
  String get shelfAllBooks => 'Все книги';

  @override
  String get shelfReading => 'Чтение';

  @override
  String get shelfRead => 'Читаю';

  @override
  String booksReadProgress(int readCount, int totalCount) {
    return '$readCount / $totalCount книги читаю';
  }

  @override
  String get shelfWantToRead => 'К прочтению';

  @override
  String get shelfAbandoned => 'Брошено';

  @override
  String get shelfPaused => 'На паузе';

  @override
  String get shelfNewTooltip => 'Новая полка';

  @override
  String get shelfEmpty => 'У вас нет созданных полок';

  @override
  String get shelfEmptySubtitle => 'Организуйте чтение как хочется';

  @override
  String get shelvesAddFirstShelf => 'Создать полку';

  @override
  String get shelfBooksEmpty => 'Нет книг в этой полке';

  @override
  String get shelfBooksEmptyHint =>
      'Здесь появятся книги по выбранным фильтрам.';

  @override
  String get shelfStatusBooksEmpty => 'Здесь нет книг';

  @override
  String get shelfFormNew => 'Новая полка';

  @override
  String get shelfFormEdit => 'Редактировать полку';

  @override
  String get shelfFormNameLabel => 'Название полки';

  @override
  String get collectionNameLabel => 'Название коллекции';

  @override
  String get shelfFormSectionStatus => 'Статус чтения';

  @override
  String get shelfFormSectionTitle => 'Название';

  @override
  String get shelfFormSectionAuthor => 'Автор';

  @override
  String get shelfFormSectionPublisher => 'Издатель';

  @override
  String get shelfFormSectionIsbn => 'ISBN';

  @override
  String get shelfFormSectionCollection => 'Коллекции';

  @override
  String get shelfFormSectionCategories => 'Категории';

  @override
  String get shelfFormSectionImprint => 'Издательская марка';

  @override
  String get shelfFormHintTitle => 'Поиск по названию';

  @override
  String get shelfFormHintAuthor => 'Имя автора';

  @override
  String get shelfFormHintPublisher => 'Название идателя';

  @override
  String get shelfFormHintIsbn => 'ISBN';

  @override
  String get shelfFormHintCollection => 'Название коллекции';

  @override
  String get shelfFormStatusAny => 'Любой';

  @override
  String get shelfOptionEdit => 'Редактирование полки';

  @override
  String get shelfOptionDelete => 'Удалить';

  @override
  String get shelfStatusLabelReading => 'Читаю';

  @override
  String get shelfStatusLabelRead => 'Прочитанные';

  @override
  String get shelfStatusLabelWantToRead => 'К прочтению';

  @override
  String get shelfStatusLabelAbandoned => 'Заброшенные';

  @override
  String get shelfStatusLabelPaused => 'Приостановленные';

  @override
  String get managementCategories => 'Категории';

  @override
  String get managementCategoryCount => 'Количество книг';

  @override
  String get managementImprints => 'Издательские марки';

  @override
  String get managementCollections => 'Коллекции';

  @override
  String get managementCategoryCloudCurve => 'Алгоритмическая кривая (книги)';

  @override
  String get tagNone => 'Категорий пока нет';

  @override
  String get tagNoneSubtitle =>
      'Категории помогают находить книги и создавать ментальную карту вашей библиотеки';

  @override
  String get categoriesAddFirst => 'Новая категория';

  @override
  String get tagNew => 'Новая категория';

  @override
  String get tagNewDialogTitle => 'Новая категория';

  @override
  String get tagNameLabel => 'Название';

  @override
  String get tagColorLabel => 'Цвет';

  @override
  String get tagDeleteTitle => 'Удалить категорию';

  @override
  String tagDeleteConfirm(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get imprintNone => 'Издательских марок пока нет';

  @override
  String get imprintNoneSubtitle =>
      'Группируйте книги по издательствам или их издательским маркам';

  @override
  String get imprintsAddFirst => 'Добавить издательскую марку';

  @override
  String get imprintNew => 'Новая издательская марка';

  @override
  String get imprintNewDialogTitle => 'Новая издательская марка';

  @override
  String get imprintEditDialogTitle => 'Редактировать издательскую марку';

  @override
  String get imprintNameLabel => 'Название издательской марки';

  @override
  String get imprintAddImageHint => 'Нажмите, чтобы добавить изображение';

  @override
  String get imprintChangeImageHint => 'Нажмите, чтобы изменить изображение';

  @override
  String get imprintUrlDialogTitle => 'URL изображения';

  @override
  String get imprintUrlHint => 'https://ejemplo.com/sello.jpg';

  @override
  String get imprintDeleteTitle => 'Удалить издательскую марку';

  @override
  String imprintDeleteConfirm(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get imprintNoImprints => 'Издательские марки не созданы';

  @override
  String get collectionNone => 'Коллекций пока нет';

  @override
  String get collectionNoneSubtitle =>
      'Создавайте коллекции и организуйте свои книги';

  @override
  String get collectionsAddFirst => 'Новая коллекция';

  @override
  String get collectionDeleteTitle => 'Удалить коллекцию';

  @override
  String collectionDeleteConfirm(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Openshelf';

  @override
  String get onboardingWelcomeSub =>
      'Ваша личная библиотека в новом представлении';

  @override
  String get onboardingOrganizeTitle => 'Организуйте свой мир';

  @override
  String get onboardingOrganizeSub =>
      'Создавайте умные полки и тематические коллекции';

  @override
  String get onboardingProgressTitle => 'Следите за своим прогрессом';

  @override
  String get onboardingProgressSub => 'Цели чтения и подробная статистика';

  @override
  String get onboardingAddTitle => 'Добавляйте мгновенно';

  @override
  String get onboardingAddSub => 'Сканируйте штрихкоды или ищите в облаке';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать сейчас';

  @override
  String get settingsApplyIcon => 'Применить изменение значка';

  @override
  String get settingsDynamicIcon => 'Динамический значок приложения';

  @override
  String get settingsDynamicIconSub =>
      'Измените значок на главном экране в соответствии с выбранным цветом (приложение будет перезапущено)';

  @override
  String get settingsLibraryColumns => 'Столбцы в библиотеке';

  @override
  String get settingsLibraryColumnsSub =>
      'Настройте количество книг в строке в режиме сетки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionAppearance => 'Внешний вид';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Система (автоматически)';

  @override
  String get settingsLanguageSpanish => 'Испанский';

  @override
  String get settingsLanguageEnglish => 'Английский';

  @override
  String get settingsLanguageFrench => 'Французский';

  @override
  String get settingsLanguageItalian => 'Итальянский';

  @override
  String get settingsLanguageCatalan => 'Каталанский';

  @override
  String get settingsLanguagePortuguese => 'Португальский (Португалия)';

  @override
  String get settingsLanguagePortugueseBR => 'Португальский (Бразилия)';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsThemeMode => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsAccentColor => 'Акцентный цвет';

  @override
  String get settingsAccentColorHint => 'Нажмите на цвет, чтобы применить его';

  @override
  String get settingsSectionStorage => 'Хранилище';

  @override
  String get settingsCoversFolder => 'Папка обложек';

  @override
  String get settingsDatabase => 'База данных';

  @override
  String get settingsDefaultDir => 'Каталог по умолчанию';

  @override
  String get settingsDbMoveTitle => 'Переместить базу данных';

  @override
  String get settingsDbMoveContent =>
      'Для перемещения базы данных требуется перезапустить приложение. Данные будут скопированы в новый каталог. Продолжить?';

  @override
  String get settingsDbMoveConfirm => 'Переместить и перезапустить';

  @override
  String get settingsSectionSearch => 'Поиск книг';

  @override
  String get settingsSearchServer => 'Сервер';

  @override
  String get settingsSearchServerHint =>
      'Используется для поиска книг по ISBN или названию';

  @override
  String get settingsSectionData => 'Управление данными';

  @override
  String get dataManagementOpenShelf => 'OpenShelf';

  @override
  String get dataManagementBookshelf => 'Bookshelf';

  @override
  String get dataManagementGoodreads => 'Goodreads';

  @override
  String get dataManagementLibraryThing => 'LibraryThing';

  @override
  String get dataManagementImport => 'Импортировать книги';

  @override
  String get dataManagementExport => 'Экспортировать книги';

  @override
  String dataManagementImportHint(String source) {
    return 'Импортировать из CSV $source';
  }

  @override
  String dataManagementImportHintJson(Object source) {
    return 'Импортировать из JSON $source';
  }

  @override
  String dataManagementExportHint(String source) {
    return 'Экспортировать в CSV $source';
  }

  @override
  String dataManagementExportHintJson(Object source) {
    return 'Экспортировать в JSON $source';
  }

  @override
  String get dataManagementRestoreBackup => 'Восстановить резервную копию';

  @override
  String get dataManagementRestoreBackupHint =>
      'Восстановить из CSV/ZIP OpenShelf';

  @override
  String get dataManagementCreateBackup => 'Создать резервную копию';

  @override
  String get dataManagementCreateBackupHint =>
      'Полный экспорт с возможностью включить обложки';

  @override
  String get settingsImportBookshelf => 'Импортировать из Bookshelf';

  @override
  String get settingsImportBookshelfHint => 'Импортировать книги из CSV-файла';

  @override
  String get settingsExportCsv => 'Экспортировать библиотеку';

  @override
  String get settingsExportCsvHint => 'Экспортировать все книги в CSV-файл';

  @override
  String get settingsFullBackup => 'Восстановить библиотеку';

  @override
  String get settingsFullBackupHint =>
      'Восстановить книги из резервной копии CSV';

  @override
  String get settingsAllFilesAccess => 'All Files Access';

  @override
  String get settingsAllFilesAccessSub =>
      'Required to move database to external folders (Android 11+)';

  @override
  String get settingsAllFilesAccessInfo =>
      'This permission allows Openshelf to manage files outside its private directory. It is required to move the database to a custom folder.';

  @override
  String get settingsAutoNoCoverTitle => 'Полка без обложек';

  @override
  String get settingsAutoNoCoverSub =>
      'Автоматически создаёт полку, если отсутствуют обложки';

  @override
  String get noCoverShelfTitle => 'Книги без обложки';

  @override
  String get settingsCompressImagesTitle => 'Автоматически сжимать обложки';

  @override
  String get settingsCompressImagesSub =>
      'Уменьшает размер изображений при сохранении или импорте';

  @override
  String get settingsBatchCompressTitle => 'Оптимизировать библиотеку сейчас';

  @override
  String get settingsBatchCompressSub =>
      'Сжимает все существующие неоптимизированные обложки';

  @override
  String settingsBatchCompressSuccess(int count) {
    return 'Оптимизировано обложек: $count.';
  }

  @override
  String get exportTitle => 'Экспортировать библиотеку';

  @override
  String get exportCoversPrompt =>
      'Включить изображения обложек в резервную копию? (Рядом с CSV будет создан ZIP-файл)';

  @override
  String get importRestoreCoversTitle => 'Восстановить обложки';

  @override
  String get importRestoreCoversPrompt =>
      'У вас также есть ZIP-файл с обложками для восстановления?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get devDeleteAllBooks => 'УДАЛИТЬ ВСЕ КНИГИ (DEV)';

  @override
  String get settingsDevClearDbSub =>
      'Инструмент разработчика: очистить базу данных';

  @override
  String get settingsDevDbCleared => 'База данных очищена';

  @override
  String get settingsImportSelectBackup => 'Выбрать резервную копию Openshelf';

  @override
  String get settingsImportSelectCovers =>
      'Выбрать ZIP-файл с обложками Openshelf';

  @override
  String get devDeleteConfirmTitle => 'Очистить библиотеку?';

  @override
  String get devDeleteConfirmContent =>
      'Это навсегда удалит ВСЕ книги и категории. Только для тестирования. Продолжить?';

  @override
  String importSuccess(int count) {
    return 'Импорт завершён: добавлено книг: $count.';
  }

  @override
  String importPartial(int added, int skipped) {
    return 'Частичный импорт: добавлено $added, пропущено $skipped.';
  }

  @override
  String get settingsApiKeyTitle => 'Ключ API Google Books';

  @override
  String get settingsApiKeyConfigured =>
      'Ключ настроен. Google Books доступен.';

  @override
  String get settingsApiKeyMissing =>
      'Без ключа Google Books будет использовать Open Library в качестве альтернативы.';

  @override
  String get settingsApiKeyHint => 'AIza...';

  @override
  String get settingsApiKeyShow => 'Показать';

  @override
  String get settingsApiKeyHide => 'Скрыть';

  @override
  String get settingsApiKeySave => 'Сохранить ключ';

  @override
  String get settingsApiKeySaved => 'Ключ сохранён';

  @override
  String get settingsApiKeyClear => 'Удалить ключ';

  @override
  String get settingsApiKeyHowTo => 'Как получить ключ';

  @override
  String get settingsApiKeyInstructionsTitle =>
      'Как получить ключ Google Books';

  @override
  String get settingsApiKeyStep1 =>
      'Откройте console.cloud.google.com и войдите в свой аккаунт Google.';

  @override
  String get settingsApiKeyStep2 =>
      'Создайте новый проект (название не имеет значения).';

  @override
  String get settingsApiKeyStep3 =>
      'Перейдите в «API и сервисы» → «Библиотека», найдите «Books API» и включите её.';

  @override
  String get settingsApiKeyStep4 =>
      'Перейдите в «API и сервисы» → «Учетные данные» → «Создать учетные данные» → «Ключ API».';

  @override
  String get settingsApiKeyStep5 =>
      'Необязательно, но рекомендуется: ограничьте ключ только для Books API.';

  @override
  String get settingsApiKeyStep6 =>
      'Скопируйте полученный ключ (он начинается с «AIza…») и вставьте его в поле выше.';

  @override
  String get settingsApiKeyNote =>
      'Ключ бесплатный и позволяет выполнять до 1 000 поисковых запросов в день. Ключ хранится только на этом устройстве.';

  @override
  String get bookSearchHint => 'Название, автор или ISBN...';

  @override
  String get bookSearchPrompt => 'Поиск по названию, автору или ISBN';

  @override
  String bookSearchNoResults(String query) {
    return 'Нет результатов для «$query»';
  }

  @override
  String bookSearchProvidersNotice(String providers) {
    return 'Результаты: $providers.';
  }

  @override
  String get bookSearchRecommended => 'РЕКОМЕНДОВАНО OPENSHELF';

  @override
  String get bookSearchRecommendedSource => 'Рекомендовано Openshelf';

  @override
  String get bookSearchServerOpenLibrary => 'Открыть библиотеку';

  @override
  String get bookSearchServerGoogleBooks => 'Google Books';

  @override
  String get bookSearchServerInventaire => 'Inventaire.io';

  @override
  String get bookSearchServerAnnasArchive => 'Anna\'s Archive';

  @override
  String get searchTabStatus => 'Статус';

  @override
  String get searchTabImprint => 'Издательская марка';

  @override
  String get searchTabCategory => 'Категория';

  @override
  String get searchTabCollection => 'Коллекция';

  @override
  String searchFilterStatus(String value) {
    return 'Статус: $value';
  }

  @override
  String searchFilterImprint(String value) {
    return 'Издательская марка: $value';
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
      other: '$count активный фильтр',
      one: '1 активный фильтр',
    );
    return '$_temp0';
  }

  @override
  String get searchSaveAsShelf => 'Сохранить как полку';

  @override
  String get shelfShowInLibrary => 'Показать в библиотеке';

  @override
  String get searchClearAll => 'Очистить всё';

  @override
  String get addedToLibrary => 'Добавлено в библиотеку';

  @override
  String get errorDuplicateIsbn => 'Уже в библиотеке';

  @override
  String get bookDuplicateTitle => 'Дубликат книги';

  @override
  String bookDuplicateContent(String isbn) {
    return 'В вашей библиотеке уже есть книга с ISBN $isbn.';
  }

  @override
  String get bookSearchErrorNoApiKey =>
      'Для Google Books требуется ключ API.\nНастройте его в «Настройки» → «Поиск книг».';

  @override
  String get bookSearchErrorRateLimit =>
      'Google Books ограничил количество запросов.\nПодождите немного и попробуйте снова.';

  @override
  String get bookSearchErrorNetwork =>
      'Не удалось подключиться ни к одному серверу.\nПроверьте соединение и попробуйте снова.';

  @override
  String get coverPickerTitle => 'Обложки';

  @override
  String coverPickerIsbnLabel(String isbn) {
    return 'ISBN $isbn';
  }

  @override
  String get coverPickerNoResults => 'Обложки для этой книги не найдены.';

  @override
  String get coverPickerNetworkError =>
      'Не удалось подключиться. Проверьте соединение.';

  @override
  String coverPickerProgress(int loaded, int total) {
    return '$loaded / $total';
  }

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsPlaceholder => 'Здесь появится ваша статистика';

  @override
  String get statsEmptySubtitle =>
      'Добавьте виджеты, чтобы видеть свои читательские привычки, цели и личные рекорды.';

  @override
  String get statsAddFirstWidget => 'Добавить первый виджет';

  @override
  String get statsAddWidgetTitle => 'Добавить виджет';

  @override
  String get statsGoalTargetShelf => 'Целевая полка';

  @override
  String searchFilterIsbnLabel(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String searchFilterLanguageLabel(String language) {
    return 'Язык: $language';
  }

  @override
  String searchFilterAuthorLabel(String author) {
    return 'Автор: $author';
  }

  @override
  String searchFilterSubtitleLabel(String subtitle) {
    return 'Подзаголовок: $subtitle';
  }

  @override
  String searchFilterTranslatorLabel(String translator) {
    return 'Переводчик: $translator';
  }

  @override
  String searchFilterPublisherLabel(String publisher) {
    return 'Издательство: $publisher';
  }

  @override
  String get statsGoalTitle => 'ЦЕЛИ';

  @override
  String get statsGoalFullTitle => 'ЦЕЛИ ЧТЕНИЯ';

  @override
  String get statsGoalUnitBooks => 'книг';

  @override
  String get statsGoalUnitPages => 'стр.';

  @override
  String statsGoalRemaining(int count) {
    return 'Осталось $count';
  }

  @override
  String get statsGoalCompleted => 'Готово!';

  @override
  String get statsGoalNew => 'Новая цель';

  @override
  String get statsGoalEdit => 'Редактировать цель';

  @override
  String get statsGoalDelete => 'Удалить';

  @override
  String get statsGoalNameLabel => 'Название (например: Цель 2026)';

  @override
  String get statsGoalTypeLabel => 'Тип';

  @override
  String get statsGoalTypeBooks => 'Прочитанные книги';

  @override
  String get statsGoalTypePages => 'Прочитанные страницы';

  @override
  String get statsGoalTargetLabel => 'Числовая цель';

  @override
  String get statsGoalFromLabel => 'С';

  @override
  String get statsGoalToLabel => 'По';

  @override
  String get statsPagesTitle => 'СТРАНИЦЫ';

  @override
  String get statsPagesSub => 'прочитанных страниц';

  @override
  String get statsStreakTitle => 'СЕРИЯ';

  @override
  String get statsStreakSub => 'дней подряд';

  @override
  String get statsStatusTitle => 'СТАТУСЫ';

  @override
  String get statsAddedTitle => 'ДОБАВЛЕННЫЕ КНИГИ';

  @override
  String get statsAddedNoData => 'Нет данных';

  @override
  String get statsCategoriesTitle => 'КАТЕГОРИИ';

  @override
  String get statsYearsTitle => 'ГОДЫ ПУБЛИКАЦИИ';

  @override
  String get statsReadingTitle => 'ЧТЕНИЕ';

  @override
  String get statsReadingNowTitle => 'ЧИТАЮ СЕЙЧАС';

  @override
  String get statsReadingNone => 'Нет книг в чтении';

  @override
  String get statsReadByYearTitle => 'ПРОЧИТАННЫЕ КНИГИ ПО ГОДАМ';

  @override
  String get statsCollectionsTitle => 'КОЛЛЕКЦИИ';

  @override
  String get statsLastAddedTitle => 'ПОСЛЕДНИЕ ДОБАВЛЕНИЯ';

  @override
  String get statsDailyReadingTitle => 'ЕЖЕДНЕВНОЕ ЧТЕНИЕ';

  @override
  String get statsAvgPagesTitle => 'СРЕДНЕЕ КОЛИЧЕСТВО СТРАНИЦ';

  @override
  String get statsAvgPagesSub => 'страниц на книгу';

  @override
  String get statsOptPagesTitle => 'Всего страниц';

  @override
  String get statsOptPagesSub => 'Всего прочитано страниц';

  @override
  String get statsOptStreakTitle => 'Серия';

  @override
  String get statsOptStreakSub => 'Дней чтения подряд';

  @override
  String get statsOptGoalTitle => 'Цель чтения';

  @override
  String get statsOptGoalSub => 'Книги, полки или коллекции';

  @override
  String get statsOptStatusTitle => 'Статусы чтения';

  @override
  String get statsOptStatusSub => 'Книги по статусу';

  @override
  String get statsOptCurrentTitle => 'Текущая книга';

  @override
  String get statsOptCurrentSub => 'Текущий прогресс чтения';

  @override
  String get statsOptAddedTimeTitle => 'Добавленные книги';

  @override
  String get statsOptAddedTimeSub => 'График добавлений во времени';

  @override
  String get statsOptCategoriesTitle => 'Категории';

  @override
  String get statsOptCategoriesSub => 'Распределение по жанрам';

  @override
  String get statsOptYearsTitle => 'Год публикации';

  @override
  String get statsOptYearsSub => 'Историческая гистограмма';

  @override
  String get statsOptReadYearTitle => 'Прочитанные по годам';

  @override
  String get statsOptReadYearSub => 'График чтения по годам';

  @override
  String get statsOptCollectionsTitle => 'Коллекции';

  @override
  String get statsOptCollectionsSub => 'Книги по коллекциям';

  @override
  String get statsOptLastAddedTitle => 'Последние добавления';

  @override
  String get statsOptLastAddedSub => 'Недавно добавленные';

  @override
  String get statsOptAvgPagesTitle => 'Средний объём';

  @override
  String get statsOptAvgPagesSub => 'Среднее количество страниц на книгу';

  @override
  String get statsOptReadListTitle => 'Список прочитанных';

  @override
  String get statsOptReadListSub => 'Книги, прочитанные за период';

  @override
  String get statsOptAvgCompletionTitle => 'Время чтения';

  @override
  String get statsOptAvgCompletionSub => 'Среднее время на прочтение книги';

  @override
  String get statsOptDailyReadingTitle => 'Ежедневное чтение';

  @override
  String get statsOptDailyReadingSub => 'Прочитанные страницы в день';

  @override
  String statsAvgCompletionValue(String days) {
    return '$days дн.';
  }

  @override
  String get statsPeriodThisMonth => 'Прочитанные в этом месяце';

  @override
  String get statsPeriodLast3Months => 'Последние 3 месяца';

  @override
  String get statsPeriodThisYear => 'Прочитанные в этом году';

  @override
  String get statsPeriodLast3Years => 'Последние 3 года';

  @override
  String get tabMore => 'ещё';

  @override
  String get sortTitle => 'Сортировать';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get permissionRequired => 'Требуется разрешение';

  @override
  String get paginationMarkersAndIndices => 'Разделы и закладки';

  @override
  String get paginationSaveProgress => 'Сохранить прогресс';

  @override
  String get paginationAllPagesAssigned => 'Все страницы уже распределены.';

  @override
  String get paginationChooseColor => 'Выбрать цвет';

  @override
  String paginationSegmentRequired(Object index) {
    return 'Сегмент $index: все поля страниц обязательны для заполнения.';
  }

  @override
  String paginationSegmentStartGreater(Object index) {
    return 'Сегмент $index: начало не может быть больше конца.';
  }

  @override
  String paginationSegmentExceedsTotal(int index, int total) {
    return 'Сегмент $index: значения превышают общее количество страниц ($total).';
  }

  @override
  String paginationSegmentOverlap(String index1, String index2) {
    return 'Сегмент $index1 пересекается с сегментом $index2';
  }

  @override
  String get paginationAdvancedConfig => 'Расширенные настройки';

  @override
  String get paginationBlocksSegments => 'БЛОКИ / СЕГМЕНТЫ';

  @override
  String get paginationNoSegmentsDefined =>
      'Сегменты не определены. По умолчанию используется диапазон 1–N.';

  @override
  String get paginationAddBlock => 'Добавить блок';

  @override
  String get paginationAllPagesAssignedNote =>
      'Примечание: вы уже распределили все доступные страницы.';

  @override
  String paginationPagesRemainingWarning(int count) {
    return 'Внимание: осталось $count нераспределённых физических страниц.';
  }

  @override
  String get paginationPhysicalTotalNote =>
      'Примечание: общее количество страниц относится к физическим страницам книги (общее количество листов).';

  @override
  String get paginationCorrectErrors => 'ИСПРАВЬТЕ СЛЕДУЮЩИЕ ОШИБКИ:';

  @override
  String get paginationMarkersLabels => 'ЗАКЛАДКИ / МЕТКИ';

  @override
  String get paginationMarkerDefaultName => 'Закладка';

  @override
  String get paginationSegmentsDefaultName => 'Блок';

  @override
  String get paginationAddMarker => 'Добавить закладку';

  @override
  String get paginationLabelOptional => 'Метка (необязательно)';

  @override
  String get paginationType => 'Тип:';

  @override
  String get paginationArabic => 'Арабские';

  @override
  String get paginationRoman => 'Римские';

  @override
  String get paginationOffset => 'Смещение';

  @override
  String get paginationMarkerLabel => 'Метка закладки';

  @override
  String get paginationVisualPage => 'Визуальная страница';

  @override
  String get paginationVisualPageHint => 'Например: xiv или 501';

  @override
  String paginationPhysicalLabel(Object page) {
    return 'Физическая: $page';
  }

  @override
  String get paginationAdjustsAutomatically => 'Корректируется автоматически';

  @override
  String get paginationVisualMode => 'Визуальный режим';

  @override
  String paginationEquivalentPhysical(int start, int end) {
    return 'Соответствует физическим страницам: $start — $end';
  }

  @override
  String paginationSectionLabel(int index) {
    return 'Раздел $index';
  }

  @override
  String paginationProgress(String current, String total) {
    return '$current / $total';
  }

  @override
  String get searchModeBasic => 'Базовая';

  @override
  String get searchModeAdvanced => 'Расширенная';

  @override
  String get searchModeBoolean => 'Булева';

  @override
  String get searchAddCondition => 'Добавить условие';

  @override
  String get searchPreview => 'Предпросмотр';

  @override
  String get searchFieldTitle => 'Название';

  @override
  String get searchFieldAuthor => 'Автор';

  @override
  String get searchFieldPublisher => 'Издательство';

  @override
  String get searchFieldIsbn => 'ISBN';

  @override
  String get searchFieldLanguage => 'Язык';

  @override
  String get searchFieldOriginalTitle => 'Оригинальное название';

  @override
  String get searchFieldOriginalLanguage => 'Оригинальный язык';

  @override
  String get searchFieldYear => 'Год';

  @override
  String get searchFieldPages => 'Страницы';

  @override
  String get searchFieldStatus => 'Статус';

  @override
  String get searchFieldCategory => 'Категория';

  @override
  String get searchFieldImprint => 'Издательская марка';

  @override
  String get searchFieldCollection => 'Коллекция';

  @override
  String get searchFieldNoCover => 'Без обложки';

  @override
  String get searchFieldNotes => 'Заметки';

  @override
  String get searchFieldHasNotes => 'Есть заметки';

  @override
  String get searchOpContains => 'содержит';

  @override
  String get searchOpExactly => 'точно равно';

  @override
  String get searchOpStartsWith => 'начинается с';

  @override
  String get searchOpIncludes => 'включает';

  @override
  String get searchOpNotIncludes => 'не включает';

  @override
  String get searchOpIncludesAll => 'включает все';

  @override
  String get searchOpEquals => '=';

  @override
  String get searchOpNotEquals => '≠';

  @override
  String get searchOpGreaterThan => '>';

  @override
  String get searchOpLessThan => '<';

  @override
  String get searchOpBetween => 'между';

  @override
  String get searchOpIs => 'равно';

  @override
  String get searchOpIsNot => 'не равно';

  @override
  String get paginationCurrentPageShort => 'Стр.';

  @override
  String get paginationStartPhysical => 'Начало (физическое)';

  @override
  String get paginationEndPhysical => 'Конец (физический)';

  @override
  String get paginationStartVisual => 'Начало (визуальное)';

  @override
  String get paginationEndVisual => 'Конец (визуальное)';

  @override
  String get paginationAdvancedButton => 'Расширенная';

  @override
  String get unknownAuthor => 'Неизвестно';

  @override
  String get storagePermissionExplanation =>
      'Чтобы выбрать обложку, необходимо предоставить доступ к хранилищу. Это можно сделать в настройках приложения.';

  @override
  String get cameraPermissionExplanation =>
      'Чтобы сделать фото, необходимо предоставить доступ к камере. Это можно сделать в настройках приложения.';

  @override
  String get settingsAutoPruneTagsTitle => 'Очистка пустых категорий';

  @override
  String get settingsAutoPruneTagsSub =>
      'Автоматически удалять категории, которые не используются ни в одной книге';

  @override
  String get settingsExcludedPruneTagsTitle => 'Исключенные категории';

  @override
  String settingsExcludedPruneTagsSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count категорий защищено',
      one: '1 категория защищена',
      zero: 'Нет исключенных категорий',
    );
    return '$_temp0';
  }

  @override
  String get settingsPruneWarningTitle => 'Обнаружены пустые категории';

  @override
  String get settingsPruneWarningContent =>
      'Активация этой опции удалит следующие категории, так как они не используются ни в одной книге. Продолжить?';

  @override
  String get settingsAutomationTitle => 'Автоматизация';

  @override
  String get removeFromCollection => 'Удалить из коллекции';

  @override
  String get removeFromImprint => 'Удалить из импринта';

  @override
  String get removeFromCategory => 'Удалить из категории';

  @override
  String get workEditionsEmpty =>
      'Не удалось загрузить дополнительные издания.';

  @override
  String get workEditionsUseGeneral => 'Использовать общие метаданные';

  @override
  String workEditionsCount(int count) {
    return '$count изд.';
  }
}
