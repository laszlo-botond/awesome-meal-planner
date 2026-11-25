import 'package:shared_preferences/shared_preferences.dart';

import 'favorites_repository.dart';

/// Stores favorites as a string list in SharedPreferences.
///
/// The plugin instance is injected at startup, which keeps this repository
/// synchronous to construct and trivial to replace in tests.
class SharedPreferencesFavoritesRepository implements FavoritesRepository {
  static const String _storageKey = 'favorite_meal_ids';

  const SharedPreferencesFavoritesRepository(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<Set<String>> loadFavoriteIds() async {
    return _preferences.getStringList(_storageKey)?.toSet() ?? <String>{};
  }

  @override
  Future<void> saveFavoriteIds(Set<String> favoriteIds) async {
    final sorted = favoriteIds.toList()..sort();
    await _preferences.setStringList(_storageKey, sorted);
  }
}
