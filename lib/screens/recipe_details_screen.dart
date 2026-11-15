import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../theme/app_theme.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Meal meal;

  const RecipeDetailsScreen({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
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
            child: _buildImageHeader(context),
          ),
          Positioned.fill(
            top: 260,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.extraLarge),
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

  Widget _buildImageHeader(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (meal.imageUrl.isNotEmpty)
          Image.network(
            meal.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
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
          child: IconButton(
            tooltip: 'More options',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, color: Colors.black, size: 26),
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
            '$category / ${meal.preparationTimeMinutes} mins',
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    final items = [
      ('${meal.calories.round()} k', 'Energy'),
      ('${meal.protein.round()} g', 'Protein'),
      ('${meal.carbohydrates.round()} g', 'Carbs'),
      ('${meal.fats.round()} g', 'Fat'),
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
          const Spacer(),
          _servingButton(Icons.remove),
          const SizedBox(width: 1),
          _servingButton(Icons.add),
        ],
      ),
    );
  }

  Widget _servingButton(IconData icon) {
    return Container(
      width: 27,
      height: 25,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textSecondary, width: 0.8),
        borderRadius: BorderRadius.circular(AppRadii.small / 2),
      ),
      child: Icon(icon, size: 17, color: AppColors.textPrimary),
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
                color: AppColors.textSecondary.withOpacity(0.65),
              ),
            ),
        ],
      ),
    );
  }

  (String, String) _splitIngredient(String ingredient) {
    final match = RegExp(r'^(\d+(?:[.,]\d+)?\s*(?:g|kg|ml|l|tbsp|tsp|slices?|cups?|pieces?)?)\s+(.+)$',
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
          onPressed: () => _showCookingInstructions(context),
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

  void _showCookingInstructions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cooking mode will be available in a future update.'),
      ),
    );
  }
}
