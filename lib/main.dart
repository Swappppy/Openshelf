import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n_extension.dart';
import 'theme/app_theme.dart';
import 'views/library/library_view.dart';
import 'controllers/app_settings_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock the app to portrait mode as requested
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
  } catch (e) {
    // Fail-safe: If SharedPreferences fails even after retries, 
    // run the app with defaults or show a critical error UI.
    debugPrint('Critical initialization error: $e');
    runApp(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
