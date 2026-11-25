import 'package:material_ui/material_ui.dart';

import '../models/meal.dart';
import '../theme/app_theme.dart';
import 'favorite_button.dart';

/// Recipe card reused by the home feed and the favorites screen.
class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Meal meal;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _buildImage(),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      onToggle: onFavoriteTap,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(meal.description, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(_timeLabel(), style: AppTypography.label),
                        const SizedBox(width: AppSpacing.md),
                        const Icon(Icons.local_fire_department_outlined,
                            size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          meal.calories != null
                              ? '${meal.calories!.round()} kcal'
                              : 'kcal n/a',
                          style: AppTypography.label,
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel() {
    if (meal.preparationTimeMinutes <= 0) return 'Not specified';
    // MyPlate.food has no structured duration, so the value is derived from
    // the instructions; the tilde makes that explicit in the UI.
    return '~${meal.preparationTimeMinutes} min';
  }

  Widget _buildImage() {
    if (meal.imageUrl.isEmpty) {
      return Container(
        height: 170,
        width: double.infinity,
        color: AppColors.primaryLight,
        child: const Icon(Icons.restaurant, size: 48, color: AppColors.primary),
      );
    }

    return Image.network(
      meal.imageUrl,
      height: 170,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 170,
        width: double.infinity,
        color: AppColors.primaryLight,
        child: const Icon(Icons.broken_image_outlined,
            size: 40, color: AppColors.primary),
      ),
    );
  }
}
