import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_icon_config.dart';
import 'app_settings_controller.dart';

/// Manages native app icon switching via MethodChannel and tracks active icon state.
class AppIconController extends Notifier<void> {
  static const _channel = MethodChannel('org.ftena.openshelf/icon');

  @override
  void build() {}

  /// Requests the native platform to switch the launcher icon.
  /// This will typically restart the app on Android.
  Future<void> updateIcon(Color color) async {
    try {
      final config = AppIconConfig.getByColor(color);
      if (config == null) return;

      // 1. Invoke native switch
      await _channel.invokeMethod('setAlternateIcon', {
        'iconName': config.name == 'default' ? null : config.name,
      });

      // 2. Persist state in settings
      ref.read(appSettingsProvider.notifier).setActiveIconName(config.name);
      
    } catch (e) {
      debugPrint('AppIconController Error: $e');
    }
  }
}

final appIconProvider = NotifierProvider<AppIconController, void>(
  AppIconController.new,
);
