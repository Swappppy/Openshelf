import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n_extension.dart';
import 'theme/app_theme.dart';
import 'views/library/library_view.dart';
import 'controllers/app_settings_controller.dart';
import 'controllers/shared_prefs_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    final prefs = await _getSharedPreferences();

    runApp(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const OpenshelfApp(),
      ),
    );
  } catch (e) {
    // Fail-safe: If SharedPreferences fails even after retries, 
    // run the app with defaults or show a critical error UI.
    debugPrint('Critical initialization error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => Text(context.l10n.criticalStartError(e.toString())),
            ),
          ),
        ),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es'),
          Locale('en'),
        ],
      ),
    );
  }
}

/// Robustly retrieves SharedPreferences with a retry mechanism.
/// This addresses common race conditions or 'channel-error' issues during fast hot restarts.
Future<SharedPreferences> _getSharedPreferences() async {
  int retries = 0;
  const maxRetries = 10;
  
  // Give the Flutter engine a moment to settle after a hot restart.
  await Future.delayed(const Duration(milliseconds: 300));

  while (retries < maxRetries) {
    try {
      return await SharedPreferences.getInstance();
    } on PlatformException catch (e) {
      if (e.code == 'channel-error') {
        retries++;
        // Incremental delay to give the platform channel time to recover.
        await Future.delayed(Duration(milliseconds: 100 * retries));
        continue;
      }
      rethrow;
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('channel-error') || 
          errorStr.contains('Unable to establish connection')) {
        retries++;
        await Future.delayed(Duration(milliseconds: 100 * retries));
        continue;
      }
      rethrow;
    }
  }
  
  // Final desperate attempt.
  return await SharedPreferences.getInstance();
}

class OpenshelfApp extends ConsumerWidget {
  const OpenshelfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(settings.seedColor),
      darkTheme: AppTheme.dark(settings.seedColor),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      home: const LibraryView(),
    );
  }
}
