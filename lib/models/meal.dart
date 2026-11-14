class Meal {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  // Preparation information
  final int preparationTimeMinutes;
  final int servings;

  // Nutritional information (per serving)
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fats;

  // Recipe information
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.preparationTimeMinutes,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
    required this.ingredients,
    required this.instructions,
    this.tags = const [],
  });
}
