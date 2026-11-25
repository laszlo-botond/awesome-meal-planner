import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/favorites_repository.dart';
import '../repositories/shared_preferences_favorites_repository.dart';

/// The persistence plugin instance is supplied by the composition root in
/// `main()` via a ProviderScope override, so no async provider is needed here.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences must be overridden at app startup.');
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return SharedPreferencesFavoritesRepository(ref.watch(sharedPreferencesProvider));
});

/// Favorite state: ids plus an optional persistence error message.
class FavoritesState {
  const FavoritesState({
    this.ids = const <String>{},
    this.error,
  });

  final Set<String> ids;
  final String? error;

  bool contains(String mealId) => ids.contains(mealId);

  FavoritesState copyWith({
    Set<String>? ids,
    String? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      ids: ids ?? this.ids,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// Riverpod controller that owns favorite ids for the whole app.
///
/// Persistence is delegated to [FavoritesRepository]; the controller only
/// manages in-memory state, optimistic updates and rollback on failure.
class FavoritesController extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => const FavoritesState();

  Future<void> initialize() async {
    try {
      final ids = await ref.read(favoritesRepositoryProvider).loadFavoriteIds();
      state = FavoritesState(ids: ids);
    } on Object {
      state = const FavoritesState(
        error: 'Saved favorites could not be restored.',
      );
    }
  }

  bool isFavorite(String mealId) => state.ids.contains(mealId);

  /// Optimistically toggles a recipe and persists the result.
  Future<void> toggle(String mealId) async {
    final previous = state;
    final updated = Set<String>.from(previous.ids);

    if (!updated.add(mealId)) {
      updated.remove(mealId);
    }

    state = previous.copyWith(ids: updated);

    try {
      await ref.read(favoritesRepositoryProvider).saveFavoriteIds(updated);
      state = state.copyWith(clearError: true);
    } on Object {
      state = previous.copyWith(
        ids: previous.ids,
        error: 'Favorites could not be saved.',
      );
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesController, FavoritesState>(FavoritesController.new);
