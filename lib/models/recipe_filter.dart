import 'recipe.dart';

/// Filter and Search state criteria for Recipe collection
/// Author: Nguyen Vinh Phu (QE180136)
class RecipeFilterCriteria {
  final String category;
  final String difficulty;
  final bool onlyFavorites;
  final String searchQuery;

  const RecipeFilterCriteria({
    this.category = 'All',
    this.difficulty = 'All',
    this.onlyFavorites = false,
    this.searchQuery = '',
  });

  /// Factory creating clean default filter state
  factory RecipeFilterCriteria.initial() => const RecipeFilterCriteria();

  /// Create updated filter state
  RecipeFilterCriteria copyWith({
    String? category,
    String? difficulty,
    bool? onlyFavorites,
    String? searchQuery,
  }) {
    return RecipeFilterCriteria(
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Evaluates and filters a list of recipes according to the current criteria
  List<Recipe> apply(List<Recipe> source) {
    return source.where((recipe) {
      // 1. Category check
      if (category != 'All' && recipe.category != category) {
        return false;
      }

      // 2. Difficulty check
      if (difficulty != 'All' && recipe.difficulty != difficulty) {
        return false;
      }

      // 3. Favorites only switch
      if (onlyFavorites && !recipe.favorite) {
        return false;
      }

      // 4. Search query (Matches against recipe name or notes)
      final query = searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matchesName = recipe.name.toLowerCase().contains(query);
        final matchesNotes = recipe.notes != null &&
            recipe.notes!.toLowerCase().contains(query);
        if (!matchesName && !matchesNotes) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool get isDefault =>
      category == 'All' &&
      difficulty == 'All' &&
      !onlyFavorites &&
      searchQuery.trim().isEmpty;
}

