import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/meal.dart';
import 'package:flutter_application_1/models/meal_fetch_result.dart';
import 'package:flutter_application_1/repositories/meal_repository.dart';
import 'package:flutter_application_1/services/meal_api_exception.dart';
import 'package:flutter_application_1/viewmodels/home_viewmodel.dart';

class _FakeMealRepository implements MealRepository {
  _FakeMealRepository({this.meals = const [], this.error});

  final List<Meal> meals;
  final Object? error;

  @override
  Future<MealFetchResult> getMeals({String query = ''}) async {
    if (error != null) throw error!;
    if (query.isEmpty) return MealFetchResult(meals: meals);

    final needle = query.toLowerCase();
    return MealFetchResult(
      meals: meals
          .where((meal) => meal.name.toLowerCase().contains(needle))
          .toList(),
    );
  }
}

void main() {
  const meal = Meal(
    id: 'meal_1',
    name: 'Chicken Soup',
    description: 'A warm bowl of soup',
    imageUrl: '',
    ingredients: ['Chicken'],
    instructions: ['Cook the chicken.'],
  );

  const other = Meal(
    id: 'meal_2',
    name: 'Apple Cake',
    description: 'A sweet cake',
    imageUrl: '',
    ingredients: ['Apples'],
    instructions: ['Bake.'],
  );

  test('loads meals from the repository', () async {
    final viewModel = HomeViewModel(
      mealRepository: _FakeMealRepository(meals: const [meal]),
    );

    await viewModel.initialize();

    expect(viewModel.state, HomeViewState.loaded);
    expect(viewModel.meals, hasLength(1));
    expect(viewModel.meals.first.id, 'meal_1');
  });

  test('network exceptions are exposed as a specific load failure', () async {
    final viewModel = HomeViewModel(
      mealRepository: _FakeMealRepository(
        error: const MealNetworkException(),
      ),
    );

    await viewModel.initialize();

    expect(viewModel.state, HomeViewState.error);
    expect(viewModel.failure, MealLoadFailure.network);
    expect(viewModel.errorMessage, isNotNull);
  });

  test('an empty result produces the explicit empty state', () async {
    final viewModel = HomeViewModel(
      mealRepository: _FakeMealRepository(),
    );

    await viewModel.initialize();

    expect(viewModel.state, HomeViewState.empty);
    expect(viewModel.meals, isEmpty);
  });

  test('search filters the catalog and clearing restores it', () async {
    final viewModel = HomeViewModel(
      mealRepository: _FakeMealRepository(meals: const [meal, other]),
    );
    await viewModel.initialize();

    await viewModel.searchMeals('chicken');

    expect(viewModel.activeQuery, 'chicken');
    expect(viewModel.meals, hasLength(1));
    expect(viewModel.meals.first.id, 'meal_1');

    await viewModel.clearSearch();

    expect(viewModel.activeQuery, isEmpty);
    expect(viewModel.meals, hasLength(2));
  });

  test('cached results are reported to the UI', () async {
    final viewModel = HomeViewModel(
      mealRepository: _CachedRepository(
        _FakeMealRepository(meals: const [meal]),
      ),
    );

    await viewModel.initialize();

    expect(viewModel.state, HomeViewState.loaded);
    expect(viewModel.isCached, isTrue);
  });
}

class _CachedRepository implements MealRepository {
  _CachedRepository(this.inner);

  final MealRepository inner;

  @override
  Future<MealFetchResult> getMeals({String query = ''}) async {
    final result = await inner.getMeals(query: query);
    return MealFetchResult(meals: result.meals, isCached: true);
  }
}
