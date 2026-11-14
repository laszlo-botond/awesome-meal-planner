import 'package:flutter/foundation.dart';

import '../models/meal.dart';
import '../repositories/meal_repository.dart';

enum HomeViewState {
  initial,
  loading,
  loaded,
  error,
}

class HomeViewModel extends ChangeNotifier {
  final MealRepository mealRepository;

  HomeViewModel({
    required this.mealRepository,
  });

  HomeViewState _state = HomeViewState.initial;
  List<Meal> _meals = [];
  String? _errorMessage;

  // Getters exposed to the View.

  HomeViewState get state => _state;

  List<Meal> get meals => List.unmodifiable(_meals);

  String? get errorMessage => _errorMessage;

  // Load meals from the repository.

  Future<void> loadMeals() async {
    if (_state == HomeViewState.loading) return;

    _state = HomeViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _meals = await mealRepository.getMeals();
      _state = HomeViewState.loaded;
    } catch (error) {
      _errorMessage = error.toString();
      _state = HomeViewState.error;
    }

    notifyListeners();
  }

  // Retry loading meals after an error.

  Future<void> retryLoadingMeals() async {
    await loadMeals();
  }
}
