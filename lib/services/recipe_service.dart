import '../models/recipe.dart';
import '../repositories/firestore_recipe_repository.dart';
import '../repositories/i_recipe_repository.dart';

/// Legacy Service Facade delegating to Firestore Recipe Repository
/// Author: Nguyen Vinh Phu (QE180136)
class RecipeService {
  final IRecipeRepository _repo;

  RecipeService({IRecipeRepository? repository})
      : _repo = repository ?? FirestoreRecipeRepository();

  Stream<List<Recipe>> getRecipesStream(String userId) =>
      _repo.subscribeUserRecipes(userId);

  Future<bool> isDuplicateRecipe({
    required String userId,
    required String name,
    String? excludeRecipeId,
  }) =>
      _repo.hasNameConflict(
        uid: userId,
        recipeTitle: name,
        currentDocId: excludeRecipeId,
      );

  Future<void> addRecipe(Recipe recipe) async {
    final res = await _repo.insertRecipe(recipe);
    if (res.isFailure) {
      throw res.errorOrNull!;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final res = await _repo.modifyRecipe(recipe);
    if (res.isFailure) {
      throw res.errorOrNull!;
    }
  }

  Future<void> toggleFavorite(String recipeId, bool currentFavorite) async {
    final res = await _repo.invertFavoriteFlag(recipeId, currentFavorite);
    if (res.isFailure) {
      throw res.errorOrNull!;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    final res = await _repo.eraseRecipe(recipeId);
    if (res.isFailure) {
      throw res.errorOrNull!;
    }
  }
}
