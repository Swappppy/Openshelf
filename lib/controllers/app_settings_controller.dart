import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'shared_prefs_provider.dart';

class AppSettingsController extends AsyncNotifier<AppSettings> {
  static const _keySeedColor = 'seedColor';
  static const _keyThemeMode = 'themeMode';
  static const _keyCoversPath = 'coversPath';
  static const _keyDbPath = 'dbPath';
  static const _keySearchServer = 'searchServer';
  static const _keyGoogleBooksApiKey = 'googleBooksApiKey';

  @override
  Future<AppSettings> build() async {
    final prefs = ref.watch(sharedPrefsProvider);
    return AppSettings(
      seedColor: Color(
        prefs.getInt(_keySeedColor) ?? const Color(0xFF6B4E3D).toARGB32(),
      ),
      themeMode: ThemeMode.values[prefs.getInt(_keyThemeMode) ?? 0],
      coversPath: prefs.getString(_keyCoversPath),
      dbPath: prefs.getString(_keyDbPath),
      searchServer: BookSearchServer.values[
      prefs.getInt(_keySearchServer) ?? 0],
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
    await prefs.setInt(_keySearchServer, s.searchServer.index);
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

  Future<void> setSearchServer(BookSearchServer server) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(searchServer: server));
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