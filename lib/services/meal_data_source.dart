import '../models/meal.dart';

abstract class MealDataSource {
  Future<List<Meal>> getMeals();
}
