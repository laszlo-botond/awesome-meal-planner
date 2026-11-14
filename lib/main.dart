import 'package:flutter/material.dart';

import 'repositories/mock_meal_repository.dart';
import 'screens/home_screen.dart';
import 'services/mock_meal_data_source.dart';
import 'viewmodels/home_viewmodel.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MealPlannerApp());
}

class MealPlannerApp extends StatefulWidget {
  const MealPlannerApp({super.key});

  @override
  State<MealPlannerApp> createState() => _MealPlannerAppState();
}

class _MealPlannerAppState extends State<MealPlannerApp> {
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();

    // Initialize dependencies.
    final dataSource = MockMealDataSource();

    final repository = MockMealRepository(
      dataSource: dataSource,
    );

    _homeViewModel = HomeViewModel(
      mealRepository: repository,
    );
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: AppTheme.light,
      home: HomeScreen(
        viewModel: _homeViewModel,
      ),
    );
  }
}
