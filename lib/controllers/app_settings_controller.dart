import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'shared_prefs_provider.dart';

class AppSettingsController extends AsyncNotifier<AppSettings> {
  static const _keySeedColor = 'seedColor';
  static const _keyThemeMode = 'themeMode';
  static const _keyCoversPath = 'coversPath';
  static const _keyDbPath = 'dbPath';
  static const _keySearchServers = 'searchServers'; // Changed key
  static const _keyGoogleBooksApiKey = 'googleBooksApiKey';
  static const _keyLocale = 'locale';

  @override
  Future<AppSettings> build() async {
    final prefs = ref.watch(sharedPrefsProvider);
    final localeCode = prefs.getString(_keyLocale);
    final serversJson = prefs.getString(_keySearchServers);
    
    List<BookSearchServer>? servers;
    if (serversJson != null) {
      try {
        final list = jsonDecode(serversJson) as List;
        servers = list.map((e) => BookSearchServer.values[e as int]).toList();
      } catch (_) {}
    }

    return AppSettings(
      seedColor: Color(
        prefs.getInt(_keySeedColor) ?? const Color(0xFF6B4E3D).toARGB32(),
      ),
      themeMode: ThemeMode.values[prefs.getInt(_keyThemeMode) ?? 0],
      coversPath: prefs.getString(_keyCoversPath),
      dbPath: prefs.getString(_keyDbPath),
      locale: localeCode != null ? Locale(localeCode) : null,
      searchServers: servers ?? const [
        BookSearchServer.openLibrary,
        BookSearchServer.googleBooks,
        BookSearchServer.inventaire,
      ],
      googleBooksApiKey: prefs.getString(_keyGoogleBooksApiKey),
    );
  }

  Future<void> _save(AppSettings s) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setInt(_keySeedColor, s.seedColor.toARGB32());
    await prefs.setInt(_keyThemeMode, s.themeMode.index);
    if (s.coversPath != null) {
      await prefs.setString(_keyCoversPath, s.coversPath!);
    }
    if (s.dbPath != null) {
      await prefs.setString(_keyDbPath, s.dbPath!);
    }
    if (s.locale != null) {
      await prefs.setString(_keyLocale, s.locale!.languageCode);
    } else {
      await prefs.remove(_keyLocale);
    }
    
    final serversJson = jsonEncode(s.searchServers.map((e) => e.index).toList());
    await prefs.setString(_keySearchServers, serversJson);

    if (s.googleBooksApiKey != null) {
      await prefs.setString(_keyGoogleBooksApiKey, s.googleBooksApiKey!);
    } else {
      await prefs.remove(_keyGoogleBooksApiKey);
    }
    state = AsyncData(s);
  }

  Future<void> setSeedColor(Color color) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(seedColor: color));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(themeMode: mode));
  }

  Future<void> setCoversPath(String path) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(coversPath: path));
  }

  Future<void> setDbPath(String path) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(dbPath: path));
  }

  Future<void> setSearchServers(List<BookSearchServer> servers) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(searchServers: servers));
  }

  Future<void> setLocale(Locale? locale) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(
      locale: locale,
      clearLocale: locale == null,
    ));
  }

  Future<void> setGoogleBooksApiKey(String? key) async {
    final current = state.value ?? const AppSettings();
    final trimmed = key?.trim().isEmpty == true ? null : key?.trim();
    await _save(current.copyWith(
      googleBooksApiKey: trimmed,
      clearApiKey: trimmed == null,
    ));
  }
}

final appSettingsProvider =
AsyncNotifierProvider<AppSettingsController, AppSettings>(
  AppSettingsController.new,
);