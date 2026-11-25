import '../models/meal_fetch_result.dart';
import 'meal_cache.dart';
import 'meal_data_source.dart';

/// Decorator that adds offline display and caching to any data source.
///
/// A successful browse result is written to the cache. If the remote source
/// fails, the cached catalog is returned (and filtered locally for searches),
/// flagged with `isCached` so the UI can tell the user. When there is no
/// cache, the original error is rethrown and the normal error state is shown.
class CachedMealDataSource implements MealDataSource {
  const CachedMealDataSource({
    required this.remote,
    required this.cache,
  });

  final MealDataSource remote;
  final MealCache cache;

  @override
  Future<MealFetchResult> getMeals({String query = ''}) async {
    try {
      final result = await remote.getMeals(query: query);
      if (query.isEmpty) await cache.save(result.meals);
      return result;
    } on Object {
      final cached = await cache.load();
      if (cached.isEmpty) rethrow;

      if (query.isEmpty) {
        return MealFetchResult(meals: cached, isCached: true);
      }

      final needle = query.toLowerCase();
      final matches = cached
          .where(
            (meal) =>
                meal.name.toLowerCase().contains(needle) ||
                meal.description.toLowerCase().contains(needle) ||
                meal.tags.any((tag) => tag.toLowerCase().contains(needle)),
          )
          .toList(growable: false);

      return MealFetchResult(meals: matches, isCached: true);
    }
  }
}
