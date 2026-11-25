import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/my_plate_recipe_dto.dart';

void main() {
  test('maps USDA nutrition, ingredients and directions into a Meal', () {
    final json = <String, dynamic>{
      'slug': 'chicken-soup',
      'name': 'Chicken Soup',
      'description': 'A warm bowl of soup.',
      'image_url': 'https://example.com/soup.jpg',
      'directions':
          'Wash hands. Simmer the chicken for 20 minutes. Let it rest for 5 minutes.',
      'ingredients': [
        {'text': '1 cup chicken'},
        {'text': '2 carrots'},
      ],
      'yield': '4 Servings',
      'food_groups': [
        {
          'key': 'protein-foods',
          'label': 'Protein Foods',
          'amount': 1.5,
          'unit': 'ounces',
        },
        {'key': 'vegetables', 'label': 'Vegetables'},
      ],
      'nutrition': [
        {'key': 'total_calories', 'amount': 210.5, 'unit': null},
        {'key': 'protein', 'amount': 24.2, 'unit': 'g'},
        {'key': 'carbohydrates', 'amount': 12.4, 'unit': 'g'},
        {'key': 'total_fat', 'amount': 7.1, 'unit': 'g'},
        {'key': 'saturated_fat', 'amount': 1.2, 'unit': 'g'},
      ],
    };

    final meal = MyPlateRecipeDetail.fromJson(json).toMeal(
          category: 'Main dish',
        );

    expect(meal.id, 'chicken-soup');
    expect(meal.name, 'Chicken Soup');
    expect(meal.imageUrl, 'https://example.com/soup.jpg');
    expect(meal.calories, 210.5);
    expect(meal.protein, 24.2);
    expect(meal.carbohydrates, 12.4);
    expect(meal.fats, 7.1);
    expect(meal.servings, 4);
    expect(meal.ingredients, ['1 cup chicken', '2 carrots']);
    expect(meal.instructions, hasLength(3));
    expect(meal.tags, ['Main dish', 'Protein Foods', 'Vegetables']);
  });

  test('estimates preparation time from duration phrases', () {
    expect(
      MyPlateRecipeDetail.estimateMinutes(
        'Bake for one hour, then cool for ten minutes.',
      ),
      60,
    );
    expect(
      MyPlateRecipeDetail.estimateMinutes('Mix everything and serve.'),
      0,
    );
    expect(
      MyPlateRecipeDetail.estimateMinutes(
        '20-Minute Chicken Creole. Cook for 5 minutes, then simmer 15 minutes.',
      ),
      20,
    );
    expect(
      MyPlateRecipeDetail.estimateMinutes('Bake for forty-five minutes.'),
      45,
    );
  });
}
