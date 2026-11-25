import '../models/meal_fetch_result.dart';

abstract class MealDataSource {
  /// Loads the catalog, or the recipes matching [query] when it is non-empty.
  Future<MealFetchResult> getMeals({String query = ''});
}
