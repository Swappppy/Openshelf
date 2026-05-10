import 'package:flutter/material.dart';

enum BookSearchServer { openLibrary, googleBooks }

class AppSettings {
  final Color seedColor;
  final ThemeMode themeMode;
  final String? coversPath;
  final String? dbPath;
  final Locale? locale;
  final BookSearchServer searchServer;
  final String? googleBooksApiKey;

  const AppSettings({
    this.seedColor = const Color(0xFF6B4E3D),
    this.themeMode = ThemeMode.system,
    this.coversPath,
    this.dbPath,
    this.locale,
    this.searchServer = BookSearchServer.openLibrary,
    this.googleBooksApiKey,
  });

  AppSettings copyWith({
    Color? seedColor,
    ThemeMode? themeMode,
    String? coversPath,
    String? dbPath,
    Locale? locale,
    bool clearLocale = false,
    BookSearchServer? searchServer,
    String? googleBooksApiKey,
    bool clearApiKey = false,
  }) =>
      AppSettings(
        seedColor: seedColor ?? this.seedColor,
        themeMode: themeMode ?? this.themeMode,
        coversPath: coversPath ?? this.coversPath,
        dbPath: dbPath ?? this.dbPath,
        locale: clearLocale ? null : (locale ?? this.locale),
        searchServer: searchServer ?? this.searchServer,
        googleBooksApiKey:
        clearApiKey ? null : (googleBooksApiKey ?? this.googleBooksApiKey),
      );
}