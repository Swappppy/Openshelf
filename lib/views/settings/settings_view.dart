import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n_extension.dart';
import '../../widgets/loading_overlay.dart';
import 'sections/appearance_section.dart';
import 'sections/storage_section.dart';
import 'sections/search_section.dart';
import 'sections/data_section.dart';

/// Main settings view for global application configuration.
/// Refactored to use modular sections and specialized controllers.
class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  static void show(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.05);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _isLoading = false;
  String? _loadingMessage;

  void _setLoading(bool loading, [String? message]) {
    setState(() {
      _isLoading = loading;
      _loadingMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: _loadingMessage,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settingsTitle),
          toolbarHeight: 40,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppearanceSection(),
            const SizedBox(height: 24),
            const StorageSection(),
            const SizedBox(height: 24),
            const SearchSection(),
            const SizedBox(height: 24),
            DataSection(onLoading: _setLoading),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
