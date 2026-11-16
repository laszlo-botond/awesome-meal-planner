## Technical Summary

### Project structure
The app follows a layered structure, separating the follwing layers:
- screens
- reusable widgets
- models
- viewmodels
- repositories
- data sources
- theme definitions

The Meal model represents recipe data, while a mock data source provides sample meals through the repository layer.

### Reusable widgets and design system
ProgressCard is a reusable widget, and meal cards are currently implemented as a private widget in HomeScreen. Shared colors, typography, spacing, and border radii are centralized in the theme/ directory and applied through AppTheme.

### Navigation
Flutter's Navigator is used to open a recipe details screen when a meal card is tapped and return to the home screen using the back button. A Material NavigationBar provides the main navigation destinations, although the other sections are currently placeholders.