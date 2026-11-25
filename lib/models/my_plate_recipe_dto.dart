import 'meal.dart';

/// DTO for a full recipe returned by `GET /recipes/{slug}` on MyPlate.food.
///
/// The list endpoint only returns slugs and calories; this detail object is
/// where ingredients, directions and the USDA nutrient table are mapped into
/// the typed domain model.
class MyPlateRecipeDetail {
  static const _numberToken =
      r'(\d{1,3}|forty-five|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|fifteen|twenty|thirty|forty)';

  final String slug;
  final String name;
  final String description;
  final String imageUrl;
  final String directions;
  final List<String> ingredients;
  final int servings;
  final String category;
  final List<String> foodGroups;
  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fats;

  const MyPlateRecipeDetail({
    required this.slug,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.directions,
    required this.ingredients,
    required this.servings,
    required this.category,
    required this.foodGroups,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
  });

  factory MyPlateRecipeDetail.fromJson(Map<String, dynamic> json) {
    final nutrition = json['nutrition'] as List<dynamic>? ?? const [];

    return MyPlateRecipeDetail(
      slug: _string(json['slug']),
      name: _string(json['name']),
      description: _string(json['description']),
      imageUrl: _string(json['image_url']),
      directions: _string(json['directions']),
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((item) => _string(item['text']))
          .where((text) => text.isNotEmpty)
          .toList(),
      servings: _servings(json['yield']),
      category: _string(json['category']),
      // The detail endpoint returns objects such as
      // {key: protein-foods, label: Protein Foods, ...}, not plain strings.
      foodGroups: (json['food_groups'] as List<dynamic>? ?? const [])
          .map(_foodGroupLabel)
          .where((group) => group.isNotEmpty)
          .toList(),
      calories: _nutrient(nutrition, 'total_calories'),
      protein: _nutrient(nutrition, 'protein'),
      carbohydrates: _nutrient(nutrition, 'carbohydrates'),
      fats: _nutrient(nutrition, 'total_fat'),
    );
  }

  /// The detail endpoint has no `category` field, so the list summary supplies
  /// it (e.g. "Main dish") and becomes the label shown on the recipe screen.
  Meal toMeal({String? category}) {
    final primaryCategory = category?.trim().isNotEmpty == true
        ? category!.trim()
        : this.category;

    return Meal(
      id: slug,
      name: name,
      description: _shorten(description),
      imageUrl: imageUrl,
      // MyPlate.food has no structured duration. The estimate is derived from
      // the title (e.g. "20-Minute Chicken Creole") and the fetched directions
      // (see `estimateMinutes`), and is shown as "~X min".
      preparationTimeMinutes: estimateMinutes('$name. $directions'),
      servings: servings,
      calories: calories,
      protein: protein,
      carbohydrates: carbohydrates,
      fats: fats,
      ingredients: ingredients,
      instructions: _steps(directions),
      tags: <String>[
        if (primaryCategory.isNotEmpty) primaryCategory,
        ...foodGroups,
      ],
    );
  }

  /// Rough duration derived from phrases such as "10 minutes", "1 hour" or
  /// the "20-Minute" part of a recipe title.
  ///
  /// Used only because the chosen API does not expose a timing field; the UI
  /// labels the value as an estimate. Returns 0 when nothing is found.
  static int estimateMinutes(String text) {
    final pattern = RegExp(
      r'\b' +
          _numberToken +
          r'\s*(?:-|to)?\s*' +
          _numberToken +
          r'?\s*(minutes?|hours?)\b',
      caseSensitive: false,
    );

    var minutes = 0;
    for (final match in pattern.allMatches(text.toLowerCase())) {
      final amount = _toMinutes(match.group(2) ?? match.group(1), match.group(3));
      if (amount > minutes) minutes = amount;
    }

    // Guard against unrealistic values produced by a malformed instruction.
    return minutes > 240 ? 240 : minutes;
  }

  /// USDA descriptions are long paragraphs; cards use a short teaser.
  static String _shorten(String value, [int maxLength = 100]) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength).trimRight()}…';
  }

  static List<String> _steps(String directions) {
    return directions
        .split(RegExp(r'\.\s+'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .map((step) => step.endsWith('.') ? step : '$step.')
        .toList();
  }

  static int _toMinutes(String? rawAmount, String? unit) {
    if (rawAmount == null) return 0;

    const words = <String, int>{
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10,
      'eleven': 11,
      'twelve': 12,
      'fifteen': 15,
      'twenty': 20,
      'thirty': 30,
      'forty': 40,
      'forty-five': 45,
    };

    final amount = int.tryParse(rawAmount) ?? words[rawAmount.toLowerCase()] ?? 0;
    if (amount == 0) return 0;
    final lowerUnit = unit?.toLowerCase() ?? '';
    return lowerUnit.startsWith('hour') ? amount * 60 : amount;
  }

  static String _foodGroupLabel(Object? value) {
    if (value is Map<String, dynamic>) {
      final label = _string(value['label']);
      if (label.isNotEmpty) return label;
      return _string(value['key']).replaceAll('-', ' ');
    }
    return _string(value);
  }

  static double? _nutrient(List<dynamic> nutrition, String key) {
    for (final item in nutrition) {
      if (item is Map<String, dynamic> && item['key'] == key) {
        return (item['amount'] as num?)?.toDouble();
      }
    }
    return null;
  }

  static int _servings(Object? value) {
    final match = RegExp(r'\d+').firstMatch(_string(value));
    if (match == null) return 1;
    return int.tryParse(match.group(0)!) ?? 1;
  }

  static String _string(Object? value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}
