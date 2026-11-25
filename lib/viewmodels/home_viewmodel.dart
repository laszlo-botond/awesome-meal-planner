import 'package:flutter/foundation.dart';

import '../models/meal.dart';
import '../models/meal_fetch_result.dart';
import '../repositories/meal_repository.dart';
import '../services/meal_api_exception.dart';

enum HomeViewState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// UI-facing classification of load failures.
///
/// Keeping it separate from the exception types means screens render a stable
/// set of messages and never depend on transport details.
enum MealLoadFailure {
  network,
  server,
  response,
  unknown,
}

/// View state for the recipe catalog: loading, search, offline flag and errors.
///
/// Favorite ids are deliberately *not* here any more: they are owned by the
/// Riverpod `favoritesProvider` in `lib/state/favorites_providers.dart`.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this.mealRepository,
  });

  final MealRepository mealRepository;

  HomeViewState _state = HomeViewState.initial;
  List<Meal> _meals = const [];
  String? _errorMessage;
  MealLoadFailure? _failure;
  String _activeQuery = '';
  bool _isCached = false;

  // Getters exposed to the views.

  HomeViewState get state => _state;

  List<Meal> get meals => List.unmodifiable(_meals);

  String? get errorMessage => _errorMessage;

  MealLoadFailure? get failure => _failure;

  String get activeQuery => _activeQuery;

  bool get isCached => _isCached;

  /// Fetches the catalog. Favorites are restored independently by Riverpod.
  Future<void> initialize() => loadMeals();

  // Loading and searching

  Future<void> loadMeals() async {
    if (_state == HomeViewState.loading) return;
    _activeQuery = '';
    await _loadFrom(mealRepository.getMeals);
  }

  Future<void> searchMeals(String query) async {
    if (_state == HomeViewState.loading) return;

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      await loadMeals();
      return;
    }

    _activeQuery = trimmed;
    await _loadFrom(() => mealRepository.getMeals(query: trimmed));
  }

  Future<void> clearSearch() => loadMeals();

  Future<void> _loadFrom(Future<MealFetchResult> Function() fetch) async {
    if (_state == HomeViewState.loading) return;

    _state = HomeViewState.loading;
    _errorMessage = null;
    _failure = null;
    notifyListeners();

    try {
      final result = await fetch();
      _meals = result.meals;
      _isCached = result.isCached;
      _state = result.meals.isEmpty ? HomeViewState.empty : HomeViewState.loaded;
    } on MealDataSourceException catch (error) {
      _failure = switch (error) {
        MealNetworkException() => MealLoadFailure.network,
        MealServerException() => MealLoadFailure.server,
        MealResponseException() => MealLoadFailure.response,
      };
      _errorMessage = error.message;
      _state = HomeViewState.error;
    } on Object catch (error) {
      _failure = MealLoadFailure.unknown;
      _errorMessage = error.toString();
      _state = HomeViewState.error;
    }

    notifyListeners();
  }

  /// Retries the current view: the active search when there is one, otherwise
  /// the full catalog.
  Future<void> retryLoadingMeals() => _activeQuery.isEmpty
      ? loadMeals()
      : searchMeals(_activeQuery);
}
