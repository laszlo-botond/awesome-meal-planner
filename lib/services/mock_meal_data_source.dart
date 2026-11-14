import '../models/meal.dart';
import 'meal_data_source.dart';

class MockMealDataSource implements MealDataSource {
  final List<Meal> _meals = const [
    Meal(
      id: 'meal_001',
      name: 'Avocado Toast',
      description: 'Whole grain toast with creamy avocado and eggs.',
      imageUrl: '',
      preparationTimeMinutes: 15,
      servings: 1,
      calories: 350,
      protein: 18,
      carbohydrates: 32,
      fats: 17,
      ingredients: [
        '2 slices whole grain bread',
        '1 avocado',
        '2 eggs',
        'Salt',
        'Black pepper',
      ],
      instructions: [
        'Toast the bread.',
        'Mash the avocado with salt and pepper.',
        'Cook the eggs to your preference.',
        'Spread avocado on toast and add the eggs.',
      ],
      tags: ['Breakfast', 'Vegetarian'],
    ),
    Meal(
      id: 'meal_002',
      name: 'Grilled Chicken Salad',
      description: 'Fresh greens with grilled chicken and vegetables.',
      imageUrl: '',
      preparationTimeMinutes: 25,
      servings: 1,
      calories: 420,
      protein: 38,
      carbohydrates: 24,
      fats: 18,
      ingredients: [
        '150g chicken breast',
        'Mixed salad greens',
        '1 tomato',
        '1 cucumber',
        '1 tablespoon olive oil',
      ],
      instructions: [
        'Season the chicken breast.',
        'Grill the chicken until fully cooked.',
        'Chop the vegetables.',
        'Combine the vegetables and chicken.',
        'Drizzle with olive oil.',
      ],
      tags: ['Lunch', 'High Protein'],
    ),
    Meal(
      id: 'meal_003',
      name: 'Berry Smoothie Bowl',
      description: 'A refreshing smoothie bowl with berries and granola.',
      imageUrl: '',
      preparationTimeMinutes: 10,
      servings: 1,
      calories: 290,
      protein: 12,
      carbohydrates: 45,
      fats: 8,
      ingredients: [
        '100g mixed berries',
        '1 banana',
        '150g Greek yogurt',
        '30g granola',
        '1 teaspoon honey',
      ],
      instructions: [
        'Blend the berries, banana, and yogurt.',
        'Pour the mixture into a bowl.',
        'Add granola and honey on top.',
      ],
      tags: ['Breakfast', 'Vegetarian'],
    ),
  ];

  @override
  Future<List<Meal>> getMeals() async {
    // await Future.delayed(const Duration(milliseconds: 50));

    return List.unmodifiable(_meals);
  }
}
