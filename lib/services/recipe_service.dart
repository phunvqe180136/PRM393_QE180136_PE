import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'recipes';

  /// Lấy danh sách công thức của user dưới dạng Stream thời gian thực
  /// Được sắp xếp theo thời gian nấu (cookTime) từ ngắn nhất đến dài nhất,
  /// nếu cookTime bằng nhau thì sắp xếp theo Tên (không phân biệt hoa/thường).
  Stream<List<RecipeModel>> getRecipesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final recipes = snapshot.docs
          .map((doc) => RecipeModel.fromFirestore(doc))
          .toList();

      recipes.sort((a, b) {
        int cookCompare = a.cookTime.compareTo(b.cookTime);
        if (cookCompare != 0) return cookCompare;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return recipes;
    });
  }

  /// Kiểm tra trùng lặp tên công thức cho cùng một người dùng (case-insensitive)
  Future<bool> isDuplicateRecipe({
    required String userId,
    required String name,
    String? excludeRecipeId,
  }) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    final targetName = name.trim().toLowerCase();

    for (var doc in querySnapshot.docs) {
      if (excludeRecipeId != null && doc.id == excludeRecipeId) {
        continue;
      }
      final data = doc.data();
      final docName = (data['name'] as String? ?? '').trim().toLowerCase();

      if (docName == targetName) {
        return true;
      }
    }
    return false;
  }

  /// Thêm một công thức mới vào Firestore
  Future<void> addRecipe(RecipeModel recipe) async {
    final isDup = await isDuplicateRecipe(
      userId: recipe.userId,
      name: recipe.name,
    );

    if (isDup) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A recipe with this name already exists.',
      );
    }

    await _firestore.collection(_collection).add(recipe.toMap());
  }

  /// Cập nhật thông tin công thức trong Firestore
  Future<void> updateRecipe(RecipeModel recipe) async {
    final isDup = await isDuplicateRecipe(
      userId: recipe.userId,
      name: recipe.name,
      excludeRecipeId: recipe.id,
    );

    if (isDup) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A recipe with this name already exists.',
      );
    }

    await _firestore.collection(_collection).doc(recipe.id).update(recipe.toMap());
  }

  /// Thay đổi trạng thái Yêu thích (favorite)
  Future<void> toggleFavorite(String recipeId, bool currentFavorite) async {
    await _firestore
        .collection(_collection)
        .doc(recipeId)
        .update({'favorite': !currentFavorite});
  }

  /// Xóa công thức khỏi Firestore
  Future<void> deleteRecipe(String recipeId) async {
    await _firestore.collection(_collection).doc(recipeId).delete();
  }
}
