import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for [SharedPreferences] instance.
/// Must be overridden in [ProviderScope] with the initialized instance.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
