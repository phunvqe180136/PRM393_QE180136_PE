import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String difficulty;
  final int cookTime;
  final int? servings;
  final bool favorite;
  final String? notes;
  final DateTime? createdAt;

  RecipeModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.cookTime,
    this.servings,
    this.favorite = false,
    this.notes,
    this.createdAt,
  });

  /// Chuyển đổi từ Firestore DocumentSnapshot sang RecipeModel
  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RecipeModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? 'Breakfast',
      difficulty: data['difficulty'] as String? ?? 'Easy',
      cookTime: data['cookTime'] != null ? (data['cookTime'] as num).toInt() : 0,
      servings: data['servings'] != null ? (data['servings'] as num).toInt() : null,
      favorite: data['favorite'] as bool? ?? false,
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(data['createdAt'].toString()))
          : null,
    );
  }

  /// Chuyển đổi từ RecipeModel sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'cookTime': cookTime,
      'servings': servings,
      'favorite': favorite,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Tạo bản sao với các thuộc tính được cập nhật
  RecipeModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? difficulty,
    int? cookTime,
    int? servings,
    bool? favorite,
    String? notes,
    DateTime? createdAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      favorite: favorite ?? this.favorite,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
