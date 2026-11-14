
import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/progress_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.viewModel.loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.viewModel,
                builder: (context, child) {
                  return _buildContent();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Header

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE8D9FF),
            child: Icon(
              Icons.person,
              color: Color(0xFF9147F5),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // Settings/menu navigation will be implemented later.
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
    );
  }

  // Main content

  Widget _buildContent() {
    switch (widget.viewModel.state) {
      case HomeViewState.initial:
      case HomeViewState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case HomeViewState.error:
        return _buildErrorState();

      case HomeViewState.loaded:
        return _buildLoadedContent();
    }
  }

  Widget _buildLoadedContent() {
    return RefreshIndicator(
      onRefresh: widget.viewModel.loadMeals,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildProgressSection(),
          const SizedBox(height: AppSpacing.md),
          _buildMealSection(),
        ],
      ),
    );
  }

  // Daily progress

  Widget _buildProgressSection() {
    return const ProgressCard(
      calories: 1248,
      proteinPercentage: 0.75,
      carbsPercentage: 0.60,
      fatsPercentage: 0.45,
    );
  }

  // Meal recommendations

  Widget _buildMealSection() {
    final meals = widget.viewModel.meals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Meal recommendations screen will be implemented later.
              },
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (meals.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('No meals available yet.'),
            ),
          )
        else
          ...meals.map(
            (meal) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _MealCard(meal: meal),
            ),
          ),
      ],
    );
  }

  // Error state

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong while loading meals.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.viewModel.retryLoadingMeals,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom navigation

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _selectedNavigationIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedNavigationIndex = index;
        });

        // Other screens will be connected later.
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.wb_sunny_outlined),
          selectedIcon: Icon(Icons.wb_sunny),
          label: 'Today',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_menu),
          label: 'Meal Plan',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_basket_outlined),
          label: 'Grocery List',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
      ],
    );
  }
}

// Private meal card widget

class _MealCard extends StatelessWidget {
  final Meal meal;

  const _MealCard({
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meal.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 15,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meal.preparationTimeMinutes} min',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.local_fire_department_outlined,
                      size: 15,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meal.calories.round()} kcal',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF9147F5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (meal.imageUrl.isEmpty) {
      return Container(
        height: 170,
        width: double.infinity,
        color: const Color(0xFFEDE5F9),
        child: const Icon(
          Icons.restaurant,
          size: 48,
          color: Color(0xFF9147F5),
        ),
      );
    }

    return Image.network(
      meal.imageUrl,
      height: 170,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 170,
          width: double.infinity,
          color: const Color(0xFFEDE5F9),
          child: const Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: Color(0xFF9147F5),
          ),
        );
      },
    );
  }
}