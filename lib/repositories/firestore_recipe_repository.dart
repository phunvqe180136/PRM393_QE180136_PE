import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/results/app_result.dart';
import '../models/recipe.dart';
import 'i_recipe_repository.dart';

/// Concrete Cloud Firestore Recipe Repository Implementation
/// Author: Nguyen Vinh Phu (QE180136)
class FirestoreRecipeRepository implements IRecipeRepository {
  final FirebaseFirestore _firestore;
  final String _collectionId;

  FirestoreRecipeRepository({
    FirebaseFirestore? firestore,
    String? collectionId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _collectionId = collectionId ?? RecipeAppConstants.firestoreCollection;

  CollectionReference<Map<String, dynamic>> get _recipesTable =>
      _firestore.collection(_collectionId);

  @override
  Stream<List<Recipe>> subscribeUserRecipes(String uid) {
    return _recipesTable
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((querySnapshot) {
      final list = querySnapshot.docs
          .map((docSnap) => Recipe.fromSnapshot(docSnap))
          .toList();

      // Custom business sorting pipeline: cookTime ascending, then lowercase name
      list.sort((a, b) {
        final durationDelta = a.cookTime.compareTo(b.cookTime);
        if (durationDelta != 0) return durationDelta;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return list;
    });
  }

  @override
  Future<bool> hasNameConflict({
    required String uid,
    required String recipeTitle,
    String? currentDocId,
  }) async {
    final sanitizedInput = recipeTitle.trim().toLowerCase();
    final snapshot = await _recipesTable.where('userId', isEqualTo: uid).get();

    for (final doc in snapshot.docs) {
      if (currentDocId != null && doc.id == currentDocId) {
        continue;
      }
      final existingTitle = (doc.data()['name'] as String? ?? '').trim().toLowerCase();
      if (existingTitle == sanitizedInput) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<AppResult<String>> insertRecipe(Recipe entity) async {
    try {
      final duplicateFound = await hasNameConflict(
        uid: entity.userId,
        recipeTitle: entity.name,
      );

      if (duplicateFound) {
        return const AppResult.failure('A recipe with this name already exists.');
      }

      final docRef = await _recipesTable.add(entity.toMap());
      return AppResult.success(docRef.id);
    } catch (err) {
      return AppResult.failure('Failed to save recipe: ${err.toString()}');
    }
  }

  @override
  Future<AppResult<void>> modifyRecipe(Recipe entity) async {
    try {
      final duplicateFound = await hasNameConflict(
        uid: entity.userId,
        recipeTitle: entity.name,
        currentDocId: entity.id,
      );

      if (duplicateFound) {
        return const AppResult.failure('A recipe with this name already exists.');
      }

      await _recipesTable.doc(entity.id).update(entity.toMap());
      return const AppResult.success(null);
    } catch (err) {
      return AppResult.failure('Failed to update recipe: ${err.toString()}');
    }
  }

  @override
  Future<AppResult<void>> invertFavoriteFlag(String docId, bool currentFlag) async {
    try {
      await _recipesTable.doc(docId).update({
        'favorite': !currentFlag,
      });
      return const AppResult.success(null);
    } catch (err) {
      return AppResult.failure('Unable to toggle favorite status.');
    }
  }

  @override
  Future<AppResult<void>> eraseRecipe(String docId) async {
    try {
      await _recipesTable.doc(docId).delete();
      return const AppResult.success(null);
    } catch (err) {
      return AppResult.failure('Unable to delete recipe: ${err.toString()}');
    }
  }
}

