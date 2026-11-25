import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';
import 'meal_cache.dart';

/// Persists the last successfully loaded catalog for offline display.
///
/// This is intentionally a separate concern from favorites: favorites store
/// only ids, while the cache stores whole recipe objects.
class SharedPreferencesMealCache implements MealCache {
  static const String _storageKey = 'cached_meals_v1';

  const SharedPreferencesMealCache(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<List<Meal>> load() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Meal.fromJson)
          .toList(growable: false);
    } on Object {
      // A corrupt cache must never prevent a fresh network load.
      return const [];
    }
  }

  @override
  Future<void> save(List<Meal> meals) async {
    await _preferences.setString(
      _storageKey,
      jsonEncode(meals.map((meal) => meal.toJson()).toList()),
    );
  }
}
