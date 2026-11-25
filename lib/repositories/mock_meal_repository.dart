import '../models/meal_fetch_result.dart';
import '../services/meal_data_source.dart';
import 'meal_repository.dart';

class MockMealRepository implements MealRepository {
  MockMealRepository({
    required this.dataSource,
  });

  final MealDataSource dataSource;

  @override
  Future<MealFetchResult> getMeals({String query = ''}) {
    return dataSource.getMeals(query: query);
  }
}
