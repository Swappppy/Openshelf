import 'package:flutter/material.dart';

enum BookSearchServer {
  openLibrary,
  googleBooks,
  inventaire,
}

/// Global application settings persisted in shared preferences.
class AppSettings {
  final ThemeMode themeMode;
  final Locale? locale;
  final Color seedColor;
  final String? coversPath;
  final String? dbPath;
  final List<BookSearchServer> searchServers;
  final String? googleBooksApiKey;

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
    ],
    this.googleBooksApiKey,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
    Color? seedColor,
    String? coversPath,
    String? dbPath,
    List<BookSearchServer>? searchServers,
    String? googleBooksApiKey,
    bool clearGoogleBooksApiKey = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
      seedColor: seedColor ?? this.seedColor,
      coversPath: coversPath ?? this.coversPath,
      dbPath: dbPath ?? this.dbPath,
      searchServers: searchServers ?? this.searchServers,
      googleBooksApiKey: clearGoogleBooksApiKey ? null : (googleBooksApiKey ?? this.googleBooksApiKey),
    );
  }
}
