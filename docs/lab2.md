## Technical Summary

### What changed

The static, mock-fed UI became a data-driven app. Recipes are loaded from a public REST API, parsed into typed Dart models, and cached for offline display.
Loading, error and empty states are explicit; recipes can be searched and marked as favorites on three screens, and favorites are persisted locally so they survive a restart.
Favorites now have a dedicated screen instead of a
strip on the home feed. All data logic sits behind repositories and data sources; screens only talk to a shared ViewModel.

### Architecture decisions

- **Data layer stays behind interfaces.** `MealDataSource` is the low-level transport contract; `MyPlateMealDataSource` implements it with `package:http`, an injectable client and a 15 s timeout. `MealRepository` remains the domain-facing boundary; `ApiMealRepository` is the default implementation and the mock implementations are still injectable. Swapping providers therefore requires no changes to the ViewModel or screens.

- **DTO separate from domain model.** `MyPlateRecipeDetail.fromJson()` mirrors the raw API shape (including the nutrition array and food-group objects) and `toMeal()` produces the typed `Meal` used by the UI. API field names, nulls and cleanup never leak into screens. `Meal.toJson()`/`fromJson()` exist only for the offline cache. Food-group objects are mapped to readable labels and the category comes from the list endpoint, so the recipe header never shows raw JSON.

- **Typed error handling.** Sealed `MealDataSourceException` subclasses (network / server / response) are mapped once in the ViewModel to a `MealLoadFailure` enum. Each failure kind has its own message, and the retry button re-runs the active search or the catalog load.

- **Catalog state in a shared ViewModel.** `main.dart` is the composition root: it initializes the persistence plugin and injects the meal repository into a single `HomeViewModel`. HomeScreen and FavoritesScreen observe it with `AnimatedBuilder` for loading/search/offline state. This part of the original architecture was kept unchanged.

- **Favorite state in Riverpod (see below).** `FavoritesRepository` abstracts persistence and `SharedPreferencesFavoritesRepository` stores a sorted id list. Ids stay valid when recipes are re-fetched. Toggles update the UI optimistically and roll back if writing fails.

- **Shared widgets, existing design tokens.** `FavoriteButton`, `MealCard` and `EmptyState` are reused across screens, keeping icon states, tooltips and hit areas identical. Brand colors (including the home avatar) now come from `AppColors` instead of hardcoded hex values; no new design tokens were needed.

### Favorite state with Riverpod

`flutter_riverpod` is now part of the project. Favorite ids are no longer a
field on `HomeViewModel`; they are owned by a dedicated Riverpod controller in
`lib/state/favorites_providers.dart`:

- `favoritesRepositoryProvider` wraps `FavoritesRepository`, with the
  `SharedPreferences` instance supplied once by a `ProviderScope` override in
  `main()` (composition root).
- `FavoritesController extends Notifier<FavoritesState>` exposes
  `initialize()`, `isFavorite(id)` and `toggle(id)`. `FavoritesState` holds the
  id set plus an optional persistence error message.
- `favoritesProvider` is a `NotifierProvider`, so any screen can
  `ref.watch(favoritesProvider)` and `ref.read(favoritesProvider.notifier)`.
  HomeScreen is a `ConsumerStatefulWidget`; FavoritesScreen and
  RecipeDetailsScreen are `ConsumerWidget`s. A heart toggled on one screen is
  immediately reflected on the others, and ids are reloaded from storage at
  startup, so they survive a restart.

Rationale: favorites are global, cross-cutting state that several independent
screens mutate — a good fit for Riverpod. The catalog loading/search state is
unchanged (`ChangeNotifier` + `AnimatedBuilder`), which keeps the existing data
logic and its tests intact rather than rewriting the whole state layer at once.
`FavoriteButton` stays a pure presentational widget; screens pass it the
current state and the controller callback.

### API choice and rate limits

The first data source was TheMealDB; it was replaced by [MyPlate.food](https://myplate.food/api), a free, no-key API over the public-domain USDA MyPlate Kitchen collection (1,072 recipes). It returns real **kcal and macros** (protein / carbs / fat), images and text search.

| API | kcal | macros | time | images | search | key |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| TheMealDB | ✗ | ✗ | ✗ | ✓ | ✓ | no |
| DummyJSON | ✓ | ✗ | ✓ | ✓ | ✓ | no |
| **MyPlate.food (chosen)** | ✓ | ✓ | — | ✓ | ✓ | no |
| Spoonacular / Edamam / API Ninjas / recipe-api.com | ✓ | ✓ | ✓ | varies | ✓ | required |

No keyless public API exposes kcal, macros **and** a structured preparation time. Genuine USDA nutrition was preferred over a time field, so
`preparationTimeMinutes` is **estimated in the DTO** from the title and the fetched directions (e.g. "20-Minute Chicken Creole" or "simmer for 20 minutes"). The UI marks it with `~`, and cards show `Not specified` when no duration is found.

A cold catalog load costs **9 requests** (1 list + 8 detail calls, fetched in a bounded parallel fan-out). A stale slug returning 404 is skipped rather than failing the whole feed.

Rate limits matter: TheMealDB's free test access is prototype-oriented with no published per-minute quota (v2 needs a supporter key). MyPlate.food allows **20 requests/minute per IP** and **100 full recipe detail fetches/day per IP**; over-limit calls return HTTP 429 with a `Retry-After` header. A 429 becomes a `MealServerException`, so the cache decorator serves the saved catalog and the home screen shows the "Showing saved recipes (offline)" banner **even while online** after repeated reloads.

### Favorites screen

Favorites moved out of the home feed into a dedicated `FavoritesScreen`. The home section header's former no-op **"View all"** button is now **"View favorites"** and navigates there; the compact favorites strip was removed. Rationale: a separate screen gives favorites a clear home and keeps the recommendation feed focused, while reusing the same `MealCard` and shared ViewModel keeps add/remove consistent on all three screens. The screen has its own empty state and back action.

### Offline, cache and search

- `CachedMealDataSource` decorates the remote source: a successful browse is persisted by `SharedPreferencesMealCache`; on failure the saved catalog is returned with `isCached = true` and the home screen shows an offline banner. With no cache, the original error is surfaced instead.
- `MealFetchResult` carries recipes plus the cache flag, making staleness explicit. Searches use the remote API first and fall back to filtering the cached catalog locally.
- `HomeViewModel.searchMeals()` / `clearSearch()` back the search field; `HomeViewState.empty` is an explicit state with a reusable `EmptyState` widget and a "Show all recipes" action.

### Definition of Done

| # | Requirement | Implementation |
| :-- | :--- | :--- |
| 1 | Recipes from a public API | MyPlate.food REST endpoints, `http` client |
| 2 | JSON → typed model | `MyPlateRecipeDetail.fromJson().toMeal()` → `Meal` |
| 3 | Loading state | `HomeViewState.loading` + spinner |
| 4 | Error state | typed exceptions → `MealLoadFailure` → specific messages + retry |
| 5 | Empty state | `HomeViewState.empty` + `EmptyState` widget |
| 6 | Retry | "Try again" retries the active search or the catalog |
| 7 | Add/remove favorites | `FavoriteButton` on home, favorites and details |
| 8 | Shared favorite state | Riverpod `favoritesProvider` watched by all three screens |
| 9 | Local favorite storage | `FavoritesRepository` / SharedPreferences (ids only) |
| 10 | Survives restart | Riverpod controller loads ids from storage at startup |
| 11 | UI / data separation | screens → viewmodel → repository → data source + cache |
| 12 | Recipe search | search field → `/recipes?q=` (optional item, implemented) |
| 13 | Offline display | cached catalog fallback + offline banner (optional, implemented) |
| 14 | Cache | `MealCache` boundary + SharedPreferences implementation (optional, implemented) |

### Verification

- `flutter analyze` — no issues; `flutter test` — 14 tests covering DTO mapping, time estimation, Riverpod favorite restore/toggle/rollback (with a fake repository override), catalog search/empty/cached states and cache fallback.
- On the emulator: real nutrition, images and category labels load; "View favorites" opens the dedicated screen; a favorite toggled on home is immediately shown in the detail and favorites screens, and survives a force-stop/relaunch through Riverpod + SharedPreferences; search, empty state and offline relaunch with the banner work.
- Added `INTERNET` permission to the release manifest and disabled Kotlin incremental compilation in `android/gradle.properties` because this machine's project drive differs from the pub-cache drive.