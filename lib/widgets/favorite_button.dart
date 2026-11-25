import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Shared favorite control used on every screen that displays a recipe.
///
/// Reusing one widget keeps the tooltip, icon states and hit area identical
/// in the recommendation list, the favorites list and the detail screen.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.iconSize = 22,
  });

  final bool isFavorite;
  final VoidCallback onToggle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
        onPressed: onToggle,
        padding: EdgeInsets.zero,
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.primary : Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
