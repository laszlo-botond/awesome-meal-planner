import '../models/meal.dart';

/// Storage boundary for the offline recipe catalog.
abstract class MealCache {
  Future<List<Meal>> load();

  Future<void> save(List<Meal> meals);
}
