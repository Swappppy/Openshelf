import 'package:flutter/material.dart';

enum BookSearchServer { 
  openLibrary, 
  googleBooks,
  inventaire,
}

class AppSettings {
  final Color seedColor;
  final ThemeMode themeMode;
  final String? coversPath;
  final String? dbPath;
  final Locale? locale;
  final List<BookSearchServer> searchServers;
  final String? googleBooksApiKey;

  const AppSettings({
    this.seedColor = const Color(0xFF6B4E3D),
    this.themeMode = ThemeMode.system,
    this.coversPath,
    this.dbPath,
    this.locale,
    this.searchServers = const [
      BookSearchServer.openLibrary,
      BookSearchServer.googleBooks,
      BookSearchServer.inventaire,
    ],
    this.googleBooksApiKey,
  });

  AppSettings copyWith({
    Color? seedColor,
    ThemeMode? themeMode,
    String? coversPath,
    String? dbPath,
    Locale? locale,
    bool clearLocale = false,
    List<BookSearchServer>? searchServers,
    String? googleBooksApiKey,
    bool clearApiKey = false,
  }) =>
      AppSettings(
        seedColor: seedColor ?? this.seedColor,
        themeMode: themeMode ?? this.themeMode,
        coversPath: coversPath ?? this.coversPath,
        dbPath: dbPath ?? this.dbPath,
        locale: clearLocale ? null : (locale ?? this.locale),
        searchServers: searchServers ?? this.searchServers,
        googleBooksApiKey:
        clearApiKey ? null : (googleBooksApiKey ?? this.googleBooksApiKey),
      );
}