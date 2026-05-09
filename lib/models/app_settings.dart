import 'package:flutter/material.dart';

enum BookSearchServer { openLibrary, googleBooks }

class AppSettings {
  final Color seedColor;
  final ThemeMode themeMode;
  final String? coversPath;
  final String? dbPath;
  final BookSearchServer searchServer;

  const AppSettings({
    this.seedColor = const Color(0xFF6B4E3D),
    this.themeMode = ThemeMode.system,
    this.coversPath,
    this.dbPath,
    this.searchServer = BookSearchServer.openLibrary,
  });

  AppSettings copyWith({
    Color? seedColor,
    ThemeMode? themeMode,
    String? coversPath,
    String? dbPath,
    BookSearchServer? searchServer,
  }) =>
      AppSettings(
        seedColor: seedColor ?? this.seedColor,
        themeMode: themeMode ?? this.themeMode,
        coversPath: coversPath ?? this.coversPath,
        dbPath: dbPath ?? this.dbPath,
        searchServer: searchServer ?? this.searchServer,
      );
}