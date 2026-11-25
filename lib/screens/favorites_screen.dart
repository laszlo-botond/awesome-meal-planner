import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../state/favorites_providers.dart';
import '../theme/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/empty_state.dart';
import '../widgets/meal_card.dart';
import 'recipe_details_screen.dart';

/// Dedicated screen for saved recipes.
///
/// Favorite ids come from Riverpod; the catalog itself comes from the shared
/// ViewModel. Both are observed, so removing a favorite here updates the heart
/// icons on the other screens immediately.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider).ids;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, child) {
          final favorites = viewModel.meals
              .where((meal) => favoriteIds.contains(meal.id))
              .toList(growable: false);

          if (favorites.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message: 'Tap the heart on a recipe to save it here for later.',
              actionLabel: 'Browse recipes',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final meal = favorites[index];
              return MealCard(
                meal: meal,
                isFavorite: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailsScreen(meal: meal),
                  ),
                ),
                onFavoriteTap: () =>
                    ref.read(favoritesProvider.notifier).toggle(meal.id),
              );
            },
          );
        },
      ),
    );
  }
}
