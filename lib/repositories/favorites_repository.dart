/// Persistence boundary for favorite meal ids.
///
/// The rest of the app works with recipe ids only, so favorites survive API
/// reloads (ids are stable even when meal objects are rebuilt).
abstract class FavoritesRepository {
  Future<Set<String>> loadFavoriteIds();

  Future<void> saveFavoriteIds(Set<String> favoriteIds);
}
