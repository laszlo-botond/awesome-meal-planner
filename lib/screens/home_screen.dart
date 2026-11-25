import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../models/meal.dart';
import '../state/favorites_providers.dart';
import '../theme/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/empty_state.dart';
import '../widgets/meal_card.dart';
import '../widgets/progress_card.dart';
import 'favorites_screen.dart';
import 'recipe_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final HomeViewModel viewModel;

  const HomeScreen({
    super.key,
    required this.viewModel,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();
    // Favorites live in Riverpod; the catalog keeps its ChangeNotifier.
    ref.read(favoritesProvider.notifier).initialize();
    widget.viewModel.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteIds = ref.watch(favoritesProvider).ids;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.viewModel,
                builder: (context, child) => _buildContent(favoriteIds),
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
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              Icons.person,
              color: AppColors.primary,
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

  Widget _buildContent(Set<String> favoriteIds) {
    final viewModel = widget.viewModel;

    switch (viewModel.state) {
      case HomeViewState.initial:
      case HomeViewState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case HomeViewState.error:
        return _buildErrorState();

      case HomeViewState.empty:
        return _buildEmptyState();

      case HomeViewState.loaded:
        return _buildLoadedContent(favoriteIds);
    }
  }

  Widget _buildEmptyState() {
    final isSearch = widget.viewModel.activeQuery.isNotEmpty;

    return EmptyState(
      icon: isSearch ? Icons.search_off : Icons.restaurant_menu,
      title: isSearch ? 'No recipes found' : 'No recipes yet',
      message: isSearch
          ? 'Nothing matched "${widget.viewModel.activeQuery}". Try another search.'
          : 'There are no recipes to show right now.',
      actionLabel: isSearch ? 'Show all recipes' : null,
      onAction: isSearch ? widget.viewModel.clearSearch : null,
    );
  }

  Widget _buildLoadedContent(Set<String> favoriteIds) {
    final viewModel = widget.viewModel;

    return RefreshIndicator(
      onRefresh: viewModel.activeQuery.isEmpty
          ? viewModel.loadMeals
          : () => viewModel.searchMeals(viewModel.activeQuery),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildProgressSection(),
          const SizedBox(height: AppSpacing.md),
          if (viewModel.isCached) _buildOfflineBanner(),
          _buildSearchField(),
          const SizedBox(height: AppSpacing.md),
          _buildMealSection(favoriteIds),
        ],
      ),
    );
  }

  // Daily progress

  Widget _buildProgressSection() {
    return const ProgressCard(
      calories: 1248,
      fatsPercentage: 0.29,
      proteinPercentage: 0.65,
      carbsPercentage: 0.85,
    );
  }

  Widget _buildOfflineBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadii.small),
        ),
        child: const Row(
          children: [
            Icon(Icons.cloud_off, size: 16, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Showing saved recipes (offline)',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search

  Widget _buildSearchField() {
    final viewModel = widget.viewModel;

    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: viewModel.searchMeals,
      decoration: InputDecoration(
        hintText: 'Search recipes',
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: viewModel.activeQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  viewModel.clearSearch();
                },
              ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Meal recommendations

  void _openRecipe(Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecipeDetailsScreen(meal: meal),
      ),
    );
  }

  Widget _buildMealSection(Set<String> favoriteIds) {
    final viewModel = widget.viewModel;
    final meals = viewModel.meals;
    final title = viewModel.activeQuery.isEmpty
        ? 'Recommended for you'
        : 'Results for "${viewModel.activeQuery}"';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(viewModel: viewModel),
                ),
              ),
              child: const Text('View favorites'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...meals.map(
          (meal) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MealCard(
              meal: meal,
              isFavorite: favoriteIds.contains(meal.id),
              onTap: () => _openRecipe(meal),
              onFavoriteTap: () =>
                  ref.read(favoritesProvider.notifier).toggle(meal.id),
            ),
          ),
        ),
      ],
    );
  }

  // Error state

  Widget _buildErrorState() {
    final viewModel = widget.viewModel;

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
            Text(
              _errorMessageFor(viewModel.failure),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (viewModel.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.retryLoadingMeals,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  String _errorMessageFor(MealLoadFailure? failure) {
    return switch (failure) {
      MealLoadFailure.network =>
        'You appear to be offline. Check your connection and try again.',
      MealLoadFailure.server =>
        'The recipe service is temporarily unavailable. Please try again.',
      MealLoadFailure.response =>
        'The recipe service returned unexpected data. Please try again.',
      MealLoadFailure.unknown || null =>
        'Something went wrong while loading meals.',
    };
  }

  // Bottom navigation

  Widget _buildBottomNavigation() {
    return NavigationBar(
      backgroundColor: AppColors.background,
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
