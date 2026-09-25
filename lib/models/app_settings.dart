import 'package:flutter/material.dart';

enum BookSearchServer {
  openLibrary,
  googleBooks,
  inventaire,
  annasArchive,
}

/// Global application settings persisted in shared preferences.
class AppSettings {
  final ThemeMode themeMode;
  final Locale? locale;
  final Color seedColor;
  final String? coversPath;
  final String? dbPath;
  final List<BookSearchServer> searchServers;
  final List<BookSearchServer> disabledSearchServers;
  final String? googleBooksApiKey;
  final int libraryGridColumns;
  final bool autoNoCoverShelf;
  final bool compressImages;
  final bool dynamicIconEnabled;
  final String? activeIconName;
  final bool hasSeenOnboarding;
  final bool pruneOrphanCategories;
  final List<int> excludedCategoriesFromPruning;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.seedColor = const Color(0xFF6750A4),
    this.coversPath,
    this.dbPath,
    this.searchServers = const [
      BookSearchServer.googleBooks,
      BookSearchServer.openLibrary,
      BookSearchServer.inventaire,
      BookSearchServer.annasArchive,
    ],
    this.disabledSearchServers = const [],
    this.googleBooksApiKey,
    this.libraryGridColumns = 3,
    this.autoNoCoverShelf = true,
    this.compressImages = true,
    this.dynamicIconEnabled = false,
    this.activeIconName,
    this.hasSeenOnboarding = false,
    this.pruneOrphanCategories = true,
    this.excludedCategoriesFromPruning = const [],
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
    Color? seedColor,
    String? coversPath,
    String? dbPath,
    List<BookSearchServer>? searchServers,
    List<BookSearchServer>? disabledSearchServers,
    String? googleBooksApiKey,
    bool clearGoogleBooksApiKey = false,
    int? libraryGridColumns,
    bool? autoNoCoverShelf,
    bool? compressImages,
    bool? dynamicIconEnabled,
    String? activeIconName,
    bool clearActiveIconName = false,
    bool? hasSeenOnboarding,
    bool? pruneOrphanCategories,
    List<int>? excludedCategoriesFromPruning,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
      seedColor: seedColor ?? this.seedColor,
      coversPath: coversPath ?? this.coversPath,
      dbPath: dbPath ?? this.dbPath,
      searchServers: searchServers ?? this.searchServers,
      disabledSearchServers: disabledSearchServers ?? this.disabledSearchServers,
      googleBooksApiKey: clearGoogleBooksApiKey ? null : (googleBooksApiKey ?? this.googleBooksApiKey),
      libraryGridColumns: libraryGridColumns ?? this.libraryGridColumns,
      autoNoCoverShelf: autoNoCoverShelf ?? this.autoNoCoverShelf,
      compressImages: compressImages ?? this.compressImages,
      dynamicIconEnabled: dynamicIconEnabled ?? this.dynamicIconEnabled,
      activeIconName: clearActiveIconName ? null : (activeIconName ?? this.activeIconName),
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      pruneOrphanCategories: pruneOrphanCategories ?? this.pruneOrphanCategories,
      excludedCategoriesFromPruning: excludedCategoriesFromPruning ?? this.excludedCategoriesFromPruning,
    );
  }
}
