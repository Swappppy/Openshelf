import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'shared_prefs_provider.dart';

/// Manages application-wide settings such as theme, locale, and storage paths.
class AppSettingsController extends Notifier<AppSettings> {
  static const _keyTheme = 'app_theme';
  static const _keyLocale = 'app_locale';
  static const _keySeedColor = 'app_seed_color';
  static const _keyCoversPath = 'app_covers_path';
  static const _keyDbPath = 'app_db_path';
  static const _keySearchServers = 'app_search_servers';
  static const _keyGoogleApiKey = 'app_google_api_key';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPrefsProvider);
    
    final themeStr = prefs.getString(_keyTheme);
    final theme = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final localeStr = prefs.getString(_keyLocale);
    final locale = localeStr != null ? Locale(localeStr) : null;

    final colorInt = prefs.getInt(_keySeedColor);
    final color = colorInt != null ? Color(colorInt) : const Color(0xFF6750A4);

    final coversPath = prefs.getString(_keyCoversPath);
    final dbPath = prefs.getString(_keyDbPath);
    
    final serversList = prefs.getStringList(_keySearchServers);
    List<BookSearchServer>? servers;
    if (serversList != null) {
      // Safely parse saved servers, ignoring unknown ones.
      servers = serversList
          .map((s) => BookSearchServer.values.where((v) => v.name == s).firstOrNull)
          .whereType<BookSearchServer>()
          .toList();
      
      // Ensure all known servers are present (migration for new additions like Inventaire).
      for (final server in BookSearchServer.values) {
        if (!servers.contains(server)) {
          servers.add(server);
        }
      }
    }

    final googleApiKey = prefs.getString(_keyGoogleApiKey);

    return AppSettings(
      themeMode: theme,
      locale: locale,
      seedColor: color,
      coversPath: coversPath,
      dbPath: dbPath,
      searchServers: servers ?? const [
        BookSearchServer.googleBooks,
        BookSearchServer.openLibrary,
        BookSearchServer.inventaire,
      ],
      googleBooksApiKey: googleApiKey,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    ref.read(sharedPrefsProvider).setString(_keyTheme, mode.name);
  }

  void setLocale(Locale? locale) {
    state = state.copyWith(locale: locale, clearLocale: locale == null);
    if (locale == null) {
      ref.read(sharedPrefsProvider).remove(_keyLocale);
    } else {
      ref.read(sharedPrefsProvider).setString(_keyLocale, locale.languageCode);
    }
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
    ref.read(sharedPrefsProvider).setInt(_keySeedColor, color.toARGB32());
  }

  Future<void> setCoversPath(String? path) async {
    state = state.copyWith(coversPath: path);
    if (path == null) {
      await ref.read(sharedPrefsProvider).remove(_keyCoversPath);
    } else {
      await ref.read(sharedPrefsProvider).setString(_keyCoversPath, path);
    }
  }

  Future<void> setDbPath(String? path) async {
    state = state.copyWith(dbPath: path);
    if (path == null) {
      await ref.read(sharedPrefsProvider).remove(_keyDbPath);
    } else {
      await ref.read(sharedPrefsProvider).setString(_keyDbPath, path);
    }
  }

  void setSearchServers(List<BookSearchServer> servers) {
    state = state.copyWith(searchServers: servers);
    ref.read(sharedPrefsProvider).setStringList(
      _keySearchServers,
      servers.map((s) => s.name).toList(),
    );
  }

  void setGoogleBooksApiKey(String? key) {
    state = state.copyWith(
      googleBooksApiKey: key,
      clearGoogleBooksApiKey: key == null,
    );
    if (key == null) {
      ref.read(sharedPrefsProvider).remove(_keyGoogleApiKey);
    } else {
      ref.read(sharedPrefsProvider).setString(_keyGoogleApiKey, key);
    }
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsController, AppSettings>(
  AppSettingsController.new,
);
