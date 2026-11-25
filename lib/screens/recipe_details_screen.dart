import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../models/meal.dart';
import '../state/favorites_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/favorite_button.dart';

class RecipeDetailsScreen extends ConsumerWidget {
  final Meal meal;

  const RecipeDetailsScreen({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(meal.id);
    return _buildScreen(context, ref, isFavorite);
  }

  Widget _buildScreen(BuildContext context, WidgetRef ref, bool isFavorite) {
    final category = meal.tags.isNotEmpty ? meal.tags.first : 'Recipe';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: _buildImageHeader(context, ref, isFavorite),
          ),
          Positioned.fill(
            top: 260,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.large),
                ),
              ),
              child: Column(
                children: [
                  _buildTitle(category),
                  _buildNutritionSummary(),
                  _buildIngredientsHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Column(
                        children: meal.ingredients
                            .map(_buildIngredient)
                            .toList(),
                      ),
                    ),
                  ),
                  _buildStartCookingButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context, WidgetRef ref, bool isFavorite) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (meal.imageUrl.isNotEmpty)
          Image.network(
            meal.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _imagePlaceholder(),
          )
        else
          _imagePlaceholder(),
        Positioned(
          top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
          left: AppSpacing.sm,
          child: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
          right: AppSpacing.sm,
          child: FavoriteButton(
            isFavorite: isFavorite,
            onToggle: () => ref.read(favoritesProvider.notifier).toggle(meal.id),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEDEDEB),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 64,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTitle(String category) {
    final subtitle = meal.preparationTimeMinutes > 0
        ? '$category / ~${meal.preparationTimeMinutes} mins'
        : category;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.refresh, size: 21, color: AppColors.textPrimary),
              Expanded(
                child: Text(
                  meal.name,
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(fontSize: 20),
                ),
              ),
              const SizedBox(width: 21),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    final items = [
      (_nutrition(meal.calories, 'k'), 'Energy'),
      (_nutrition(meal.protein, 'g'), 'Protein'),
      (_nutrition(meal.carbohydrates, 'g'), 'Carbs'),
      (_nutrition(meal.fats, 'g'), 'Fat'),
    ];

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: Column(
              children: [
                Text(
                  item.$1,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.$2,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _nutrition(double? value, String unit) {
    if (value == null) return '—';
    return '${value.round()} $unit';
  }

  Widget _buildIngredientsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text('Ingredients', style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${meal.servings} serves',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredient(String ingredient) {
    final parsed = _splitIngredient(ingredient);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              parsed.$1,
              style: AppTypography.body,
            ),
          ),
          if (parsed.$2.isNotEmpty)
            Text(
              parsed.$2,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  (String, String) _splitIngredient(String ingredient) {
    // Supports whole numbers, decimals and fractions such as "1/2 cup".
    final match = RegExp(
      r'^(\d+(?:[/.,]\d+)?\s*(?:g|kg|ml|l|tbsp|tsp|slices?|cups?|pieces?)?)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(ingredient.trim());

    if (match == null) return (ingredient, '');
    return (match.group(2)!, match.group(1)!);
  }

  Widget _buildStartCookingButton(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () => _showCookingPlaceholder(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.small),
            ),
            elevation: 0,
          ),
          child: Text(
            'Start cooking',
            style: AppTypography.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showCookingPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cooking mode will be available in a future update.'),
      ),
    );
  }
}
