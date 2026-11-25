import 'meal.dart';

/// Recipes returned by the data layer together with their provenance.
///
/// The `isCached` flag lets the UI show an offline banner instead of silently
/// presenting stale data as fresh.
class MealFetchResult {
  const MealFetchResult({
    required this.meals,
    this.isCached = false,
  });

  final List<Meal> meals;
  final bool isCached;
}
