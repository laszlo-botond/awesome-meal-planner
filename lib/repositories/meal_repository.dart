import '../models/meal_fetch_result.dart';

abstract class MealRepository {
  /// Returns recipes (and whether they came from the offline cache).
  Future<MealFetchResult> getMeals({String query = ''});
}
