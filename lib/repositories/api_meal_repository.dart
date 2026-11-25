import '../models/meal_fetch_result.dart';
import '../services/meal_data_source.dart';
import 'meal_repository.dart';

/// Default repository implementation.
///
/// It is the boundary the ViewModel talks to: swapping the remote API for a
/// mock cache or a different provider only requires another implementation of
/// [MealRepository], with no changes to the ViewModel or the screens.
class ApiMealRepository implements MealRepository {
  ApiMealRepository({required this.dataSource});

  final MealDataSource dataSource;

  @override
  Future<MealFetchResult> getMeals({String query = ''}) {
    return dataSource.getMeals(query: query);
  }
}
