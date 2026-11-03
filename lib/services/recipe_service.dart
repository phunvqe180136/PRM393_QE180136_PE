import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/recipe.dart';

/// Firestore Database Service for Recipe Collection
/// Author: Nguyen Vinh Phu (QE180136)
class RecipeService {
  final FirebaseFirestore _firestoreInstance;
  final String _collectionPath;

  RecipeService({
    FirebaseFirestore? firestore,
    String? collectionPath,
  })  : _firestoreInstance = firestore ?? FirebaseFirestore.instance,
        _collectionPath = collectionPath ?? RecipeAppConstants.firestoreCollection;

  CollectionReference<Map<String, dynamic>> get _recipeRef =>
      _firestoreInstance.collection(_collectionPath);

  /// Streams private recipes belonging to the current user ordered by cookTime ASC,
  /// with secondary alphabetical tie-break by name.
  Stream<List<Recipe>> getRecipesStream(String userId) {
    return _recipeRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final recipes = snapshot.docs
          .map((doc) => Recipe.fromSnapshot(doc))
          .toList();

      // Custom deterministic comparator: cookTime ASC -> name ASC (case-insensitive)
      recipes.sort((first, second) {
        final timeComparison = first.cookTime.compareTo(second.cookTime);
        if (timeComparison != 0) {
          return timeComparison;
        }
        return first.name.toLowerCase().compareTo(second.name.toLowerCase());
      });

      return recipes;
    });
  }

  /// Verifies whether a recipe name already exists for this user (case-insensitive)
  Future<bool> isDuplicateRecipe({
    required String userId,
    required String name,
    String? excludeRecipeId,
  }) async {
    final cleanName = name.trim().toLowerCase();

    final querySnapshot = await _recipeRef
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in querySnapshot.docs) {
      if (excludeRecipeId != null && doc.id == excludeRecipeId) {
        continue;
      }
      final existingName = (doc.data()['name'] as String? ?? '').trim().toLowerCase();
      if (existingName == cleanName) {
        return true;
      }
    }
    return false;
  }

  /// Inserts a new recipe document after enforcing duplicate check
  Future<DocumentReference<Map<String, dynamic>>> addRecipe(Recipe recipe) async {
    final isDuplicate = await isDuplicateRecipe(
      userId: recipe.userId,
      name: recipe.name,
    );

    if (isDuplicate) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A recipe with this name already exists.',
      );
    }

    return await _recipeRef.add(recipe.toMap());
  }

  /// Updates an existing recipe document
  Future<void> updateRecipe(Recipe recipe) async {
    final isDuplicate = await isDuplicateRecipe(
      userId: recipe.userId,
      name: recipe.name,
      excludeRecipeId: recipe.id,
    );

    if (isDuplicate) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A recipe with this name already exists.',
      );
    }

    await _recipeRef.doc(recipe.id).update(recipe.toMap());
  }

  /// Toggles favorite status of an existing recipe
  Future<void> toggleFavorite(String recipeId, bool currentFavorite) async {
    await _recipeRef.doc(recipeId).update({
      'favorite': !currentFavorite,
    });
  }

  /// Permanently removes a recipe document from Firestore
  Future<void> deleteRecipe(String recipeId) async {
    await _recipeRef.doc(recipeId).delete();
  }
}
