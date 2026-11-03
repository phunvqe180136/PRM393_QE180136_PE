import 'package:cloud_firestore/cloud_firestore.dart';

/// Recipe Entity Model
/// Represents a private culinary recipe document in Firestore.
/// Developed by Nguyen Vinh Phu (QE180136)
class Recipe {
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

  const Recipe({
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

  /// Factory constructor to deserialize Firestore DocumentSnapshot into Recipe entity
  factory Recipe.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final rawData = doc.data() ?? <String, dynamic>{};
    return Recipe.fromMap(rawData, doc.id);
  }

  /// Create a Recipe entity from a raw Map and document ID
  factory Recipe.fromMap(Map<String, dynamic> data, [String id = '']) {
    DateTime? parseCreatedDate(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is DateTime) return timestamp;
      return DateTime.tryParse(timestamp.toString());
    }

    return Recipe(
      id: id,
      userId: (data['userId'] as String?)?.trim() ?? '',
      name: (data['name'] as String?)?.trim() ?? '',
      category: (data['category'] as String?)?.trim() ?? 'Breakfast',
      difficulty: (data['difficulty'] as String?)?.trim() ?? 'Easy',
      cookTime: data['cookTime'] is num ? (data['cookTime'] as num).toInt() : 0,
      servings: data['servings'] is num ? (data['servings'] as num).toInt() : null,
      favorite: (data['favorite'] as bool?) ?? false,
      notes: data['notes'] as String?,
      createdAt: parseCreatedDate(data['createdAt']),
    );
  }

  /// Serialize Recipe entity to a Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name.trim(),
      'category': category,
      'difficulty': difficulty,
      'cookTime': cookTime,
      if (servings != null) 'servings': servings,
      'favorite': favorite,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Immutable copyWith utility
  Recipe copyWith({
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
    return Recipe(
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

  // Convenient helper getters
  bool get hasNotes => notes != null && notes!.trim().isNotEmpty;
  bool get hasServings => servings != null && servings! > 0;
  String get formattedCookTime => '$cookTime min';

  @override
  String toString() => 'Recipe(id: $id, name: "$name", category: $category, cookTime: ${cookTime}m)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Backward compatibility typedef for existing references
typedef RecipeModel = Recipe;

