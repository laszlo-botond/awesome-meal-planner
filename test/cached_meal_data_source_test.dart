import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/meal.dart';
import 'package:flutter_application_1/models/meal_fetch_result.dart';
import 'package:flutter_application_1/services/cached_meal_data_source.dart';
import 'package:flutter_application_1/services/meal_api_exception.dart';
import 'package:flutter_application_1/services/meal_cache.dart';
import 'package:flutter_application_1/services/meal_data_source.dart';

class _FakeRemote implements MealDataSource {
  bool fail = false;

  @override
  Future<MealFetchResult> getMeals({String query = ''}) async {
    if (fail) throw const MealNetworkException();
    return MealFetchResult(
      meals: query.isEmpty ? const [soup, cake] : const [soup],
    );
  }
}

class _FakeCache implements MealCache {
  List<Meal> stored = const [];

  @override
  Future<List<Meal>> load() async => stored;

  @override
  Future<void> save(List<Meal> meals) async => stored = meals;
}

const soup = Meal(
  id: 'soup',
  name: 'Chicken Soup',
  description: 'Warm soup',
  imageUrl: '',
  tags: ['protein-foods'],
  ingredients: ['Chicken'],
  instructions: ['Cook.'],
);

const cake = Meal(
  id: 'cake',
  name: 'Apple Cake',
  description: 'Sweet cake',
  imageUrl: '',
  tags: ['grains'],
  ingredients: ['Apples'],
  instructions: ['Bake.'],
);

void main() {
  test('a successful browse result is cached', () async {
    final remote = _FakeRemote();
    final cache = _FakeCache();
    final source = CachedMealDataSource(remote: remote, cache: cache);

    final result = await source.getMeals();

    expect(result.meals, hasLength(2));
    expect(result.isCached, isFalse);
    expect(cache.stored, hasLength(2));
  });

  test('a failed request falls back to the cached catalog', () async {
    final remote = _FakeRemote()..fail = true;
    final cache = _FakeCache()..stored = const [soup, cake];
    final source = CachedMealDataSource(remote: remote, cache: cache);

    final result = await source.getMeals();

    expect(result.meals, hasLength(2));
    expect(result.isCached, isTrue);
  });

  test('offline search filters the cached catalog locally', () async {
    final remote = _FakeRemote()..fail = true;
    final cache = _FakeCache()..stored = const [soup, cake];
    final source = CachedMealDataSource(remote: remote, cache: cache);

    final result = await source.getMeals(query: 'apple');

    expect(result.meals, hasLength(1));
    expect(result.meals.first.id, 'cake');
    expect(result.isCached, isTrue);
  });

  test('with no cache the original error is surfaced', () async {
    final remote = _FakeRemote()..fail = true;
    final source = CachedMealDataSource(
      remote: remote,
      cache: _FakeCache(),
    );

    expect(
      () => source.getMeals(),
      throwsA(isA<MealNetworkException>()),
    );
  });
}
