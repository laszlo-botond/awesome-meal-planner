/// Framework-independent domain model consumed by the UI layer.
///
/// It contains no HTTP or JSON concerns: the remote representation is
/// normalized into this shape by the data-layer DTO. `toJson`/`fromJson` exist
/// only so the offline cache can persist the domain object losslessly.
class Meal {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  // Preparation information
  final int preparationTimeMinutes;
  final int servings;

  // Nutritional information (per serving).
  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fats;

  // Recipe information
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.preparationTimeMinutes = 0,
    this.servings = 1,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fats,
    required this.ingredients,
    required this.instructions,
    this.tags = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      preparationTimeMinutes: json['preparationTimeMinutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
      fats: (json['fats'] as num?)?.toDouble(),
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      instructions: (json['instructions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'preparationTimeMinutes': preparationTimeMinutes,
        'servings': servings,
        'calories': calories,
        'protein': protein,
        'carbohydrates': carbohydrates,
        'fats': fats,
        'ingredients': ingredients,
        'instructions': instructions,
        'tags': tags,
      };
}
