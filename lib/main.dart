import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'views/library/library_view.dart';

void main() {
  runApp(
    const ProviderScope(
      child: OpenshelfApp(),
    ),
  );
}

class OpenshelfApp extends StatelessWidget {
  const OpenshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Openshelf',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const LibraryView(),
    );
  }
}