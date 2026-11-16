import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProgressCard extends StatelessWidget {
  final int calories;
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatsPercentage;

  const ProgressCard({
    super.key,
    required this.calories,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatsPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Progress",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'View more',
                style: TextStyle(
                  color: AppColors.navLinkText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCalories(),
              _buildMacroProgress(
                label: 'Fats',
                percentage: fatsPercentage,
                color: AppColors.fats,
              ),
              _buildMacroProgress(
                label: 'Protein',
                percentage: proteinPercentage,
                color: AppColors.protein,
              ),
              _buildMacroProgress(
                label: 'Carbs',
                percentage: carbsPercentage,
                color: AppColors.carbohydrates,
              ),
            ],
          ),

          _buildEncouragementMessage()
        ],
      ),
    );
  }

  
  Widget _buildCalories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calories',
          style: AppTypography.label,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department,
              size: 23,
              color: Colors.black,
            ),
            const SizedBox(width: 4),
            Text(
              calories.toString(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroProgress({
    required String label,
    required double percentage,
    required Color color,
  }) {
    // Keep the progress value within the valid 0.0–1.0 range.
    final progress = percentage.clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          width: 58,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEncouragementMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.medium),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.border,
            child: Icon(
              Icons.person,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              "Keep the pace! You're doing great.",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
