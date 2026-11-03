import '../core/results/app_result.dart';
import '../models/recipe.dart';

/// Contract interface defining Recipe data access operations
/// Author: Nguyen Vinh Phu (QE180136)
abstract interface class IRecipeRepository {
  Stream<List<Recipe>> subscribeUserRecipes(String uid);

  Future<AppResult<String>> insertRecipe(Recipe entity);

  Future<AppResult<void>> modifyRecipe(Recipe entity);

  Future<AppResult<void>> invertFavoriteFlag(String docId, bool currentFlag);

  Future<AppResult<void>> eraseRecipe(String docId);

  Future<bool> hasNameConflict({
    required String uid,
    required String recipeTitle,
    String? currentDocId,
  });
}

