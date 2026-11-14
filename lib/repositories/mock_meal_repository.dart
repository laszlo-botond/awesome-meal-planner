import '../models/meal.dart';
import '../services/meal_data_source.dart';
import 'meal_repository.dart';

class MockMealRepository implements MealRepository {
  final MealDataSource dataSource;

  MockMealRepository({
    required this.dataSource,
  });

  @override
  Future<List<Meal>> getMeals() async {
    return await dataSource.getMeals();
  }
}
