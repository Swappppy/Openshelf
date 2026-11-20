import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n_extension.dart';
import 'theme/app_theme.dart';
import 'views/onboarding/onboarding_view.dart';
import 'views/library/library_view.dart';
import 'controllers/app_settings_controller.dart';
import 'controllers/shelf_automation_controller.dart';
import 'controllers/shared_prefs_provider.dart';
import 'services/database.dart';

/// English first, then every other generated locale.
final List<Locale> _supportedLocales = [
  const Locale('en'),
  ...AppLocalizations.supportedLocales.where((l) => l.languageCode != 'en'),
];

/// Exact match (language + country) first, then language only, then English.
Locale _resolveLocale(List<Locale>? locales, Iterable<Locale> supported) {
  for (final locale in locales ?? const <Locale>[]) {
    final exact = supported.where((s) => s.languageCode == locale.languageCode && s.countryCode == locale.countryCode);
    if (exact.isNotEmpty) return exact.first;
    final language = supported.where((s) => s.languageCode == locale.languageCode);
    if (language.isNotEmpty) return language.first;
  }
  return supported.firstWhere((l) => l.languageCode == 'en', orElse: () => supported.first);
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock the app to portrait mode as requested
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final prefs = await SharedPreferences.getInstance();
    final missingDbDir = AppDatabase.missingCustomDatabaseDir(prefs);
    if (missingDbDir != null) {
      runApp(_MissingDatabaseApp(prefs: prefs, path: missingDbDir, onResolved: () => _runApp(prefs)));
    } else {
      _runApp(prefs);
    }
  } catch (e) {
    debugPrint('Critical initialization error: $e');
    runApp(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: _supportedLocales,
        localeListResolutionCallback: _resolveLocale,
        home: Scaffold(
          body: Center(
            child: Text(
              'Critical error: $e\nPlease restart the app.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

void _runApp(SharedPreferences prefs) {
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const OpenshelfApp(),
    ),
  );
}

class OpenshelfApp extends ConsumerWidget {
  const OpenshelfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    // Force initialization of the bookshelf automation listener
    ref.watch(shelfAutomationProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(settings.seedColor),
      darkTheme: AppTheme.dark(settings.seedColor),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: _supportedLocales,
      localeListResolutionCallback: _resolveLocale,
      home: settings.hasSeenOnboarding ? const LibraryView() : const OnboardingView(),
    );
  }
}

/// Shown at startup when the configured custom database folder no longer
/// contains the library, instead of silently starting an empty one.
class _MissingDatabaseApp extends StatelessWidget {
  final SharedPreferences prefs;
  final String path;
  final VoidCallback onResolved;

  const _MissingDatabaseApp({required this.prefs, required this.path, required this.onResolved});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(const Color(0xFF6750A4)),
      darkTheme: AppTheme.dark(const Color(0xFF6750A4)),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: _supportedLocales,
      localeListResolutionCallback: _resolveLocale,
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.storage_outlined, size: 56, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(context.l10n.dbMissingTitle,
                      style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(context.l10n.dbMissingBody(path), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      if (AppDatabase.missingCustomDatabaseDir(prefs) == null) onResolved();
                    },
                    child: Text(context.l10n.retry),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await prefs.remove(AppDatabase.customPathPrefKey);
                      onResolved();
                    },
                    child: Text(context.l10n.dbMissingUseDefault),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
