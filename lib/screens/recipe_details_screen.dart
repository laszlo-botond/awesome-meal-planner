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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildImageHeader(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTags(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(meal.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(meal.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickFacts(),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Nutrition per serving', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  _buildNutrition(),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ...meal.ingredients.map(_buildIngredient),
                  if (meal.instructions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Text('Preparation', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    ...meal.instructions.asMap().entries.map(
                      (entry) => _buildInstruction(entry.key + 1, entry.value),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showCookingInstructions(context),
            icon: const Icon(Icons.restaurant),
            label: const Text('Start cooking'),
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
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
            top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
            left: AppSpacing.md,
            child: Material(
              color: Colors.white.withOpacity(0.92),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    color: const Color(0xFFEDE5F9),
    child: const Center(
      child: Icon(Icons.restaurant, size: 64, color: AppColors.primary),
    ),
  );

  Widget _buildTags() {
    if (meal.tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: meal.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(tag, style: AppTypography.label.copyWith(color: AppColors.primary)),
      )).toList(),
    );
  }

  Widget _buildQuickFacts() {
    return Row(
      children: [
        _fact(Icons.schedule, '${meal.preparationTimeMinutes} min', 'Time'),
        const SizedBox(width: AppSpacing.md),
        _fact(Icons.people_outline, '${meal.servings}', 'Servings'),
        const SizedBox(width: AppSpacing.md),
        _fact(Icons.local_fire_department_outlined, '${meal.calories.round()} kcal', 'Calories'),
      ],
    );
  }

  Widget _fact(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
        child: Column(
          children: [
            Icon(icon, size: 19, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            Text(label, style: AppTypography.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrition() {
    final values = [
      ('Protein', meal.protein, AppColors.protein),
      ('Carbs', meal.carbohydrates, AppColors.carbohydrates),
      ('Fats', meal.fats, AppColors.fats),
    ];
    return Row(
      children: values.map((item) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$1, style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              Text('${item.$2.round()} g', style: AppTypography.title),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildIngredient(String ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(ingredient, style: AppTypography.body)),
        ],
      ),
    );
  }

  Widget _buildInstruction(int number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text('$number', style: AppTypography.label.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(instruction, style: AppTypography.bodyLarge)),
        ],
      ),
    );
  }

  void _showCookingInstructions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cooking mode will be available in a future update.')),
    );
  }
}
