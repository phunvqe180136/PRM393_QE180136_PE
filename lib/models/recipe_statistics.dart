import 'recipe.dart';
import '../core/constants/app_constants.dart';

/// Aggregated statistics summary for a recipe list
/// Author: Nguyen Vinh Phu (QE180136)
class RecipeStatistics {
  final int totalRecipes;
  final int favoriteCount;
  final int totalCookingMinutes;
  final Map<String, int> categoryCounts;

  const RecipeStatistics({
    required this.totalRecipes,
    required this.favoriteCount,
    required this.totalCookingMinutes,
    required this.categoryCounts,
  });

  /// Factory computing metrics from a given list of recipes
  factory RecipeStatistics.compute(List<Recipe> recipes) {
    int favorites = 0;
    int minutes = 0;
    final Map<String, int> distribution = {
      for (final cat in RecipeAppConstants.categories) cat: 0,
    };

    for (final r in recipes) {
      if (r.favorite) {
        favorites++;
      }
      minutes += r.cookTime;
      if (distribution.containsKey(r.category)) {
        distribution[r.category] = (distribution[r.category] ?? 0) + 1;
      }
    }

    return RecipeStatistics(
      totalRecipes: recipes.length,
      favoriteCount: favorites,
      totalCookingMinutes: minutes,
      categoryCounts: distribution,
    );
  }
}

