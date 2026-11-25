import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/api_meal_repository.dart';
import 'screens/home_screen.dart';
import 'services/cached_meal_data_source.dart';
import 'services/my_plate_meal_data_source.dart';
import 'services/shared_preferences_meal_cache.dart';
import 'state/favorites_providers.dart';
import 'theme/app_theme.dart';
import 'viewmodels/home_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Composition root: the persistence plugin is supplied once to Riverpod,
  // while the catalog ViewModel keeps its existing constructor injection.
  final preferences = await SharedPreferences.getInstance();

  final remoteDataSource = MyPlateMealDataSource();
  final dataSource = CachedMealDataSource(
    remote: remoteDataSource,
    cache: SharedPreferencesMealCache(preferences),
  );
  final mealRepository = ApiMealRepository(dataSource: dataSource);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: MealPlannerApp(
        viewModel: HomeViewModel(mealRepository: mealRepository),
      ),
    ),
  );
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: AppTheme.light,
      home: HomeScreen(viewModel: viewModel),
    );
  }
}
