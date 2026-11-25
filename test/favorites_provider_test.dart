import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/repositories/favorites_repository.dart';
import 'package:flutter_application_1/state/favorites_providers.dart';

class _FakeFavoritesRepository implements FavoritesRepository {
  Set<String> stored = {'meal_1'};
  bool failOnSave = false;

  @override
  Future<Set<String>> loadFavoriteIds() async => Set<String>.from(stored);

  @override
  Future<void> saveFavoriteIds(Set<String> favoriteIds) async {
    if (failOnSave) throw StateError('storage unavailable');
    stored = Set<String>.from(favoriteIds);
  }
}

void main() {
  late ProviderContainer container;
  late _FakeFavoritesRepository repository;

  setUp(() {
    repository = _FakeFavoritesRepository();
    container = ProviderContainer(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('restores persisted favorites into the Riverpod state', () async {
    final controller = container.read(favoritesProvider.notifier);

    await controller.initialize();

    expect(container.read(favoritesProvider).ids, {'meal_1'});
    expect(controller.isFavorite('meal_1'), isTrue);
  });

  test('toggle updates the provider and persists the new set', () async {
    final controller = container.read(favoritesProvider.notifier);
    await controller.initialize();

    await controller.toggle('meal_1');

    expect(controller.isFavorite('meal_1'), isFalse);
    expect(container.read(favoritesProvider).ids, isEmpty);
    expect(repository.stored, isEmpty);
  });

  test('a failed save rolls the optimistic toggle back', () async {
    repository.failOnSave = true;
    final controller = container.read(favoritesProvider.notifier);
    await controller.initialize();

    await controller.toggle('meal_1');

    expect(controller.isFavorite('meal_1'), isTrue);
    expect(container.read(favoritesProvider).error, isNotNull);
  });
}
