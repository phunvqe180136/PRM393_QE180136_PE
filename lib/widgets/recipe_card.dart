import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/recipe.dart';

/// Gourmet Card Item representing a single recipe in the collection
/// Author: Nguyen Vinh Phu (QE180136)
class RecipeCardWidget extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const RecipeCardWidget({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  IconData _resolveCategoryIcon(String category) {
    return switch (category) {
      'Breakfast' => Icons.breakfast_dining_rounded,
      'Lunch' => Icons.lunch_dining_rounded,
      'Dinner' => Icons.dinner_dining_rounded,
      'Dessert' => Icons.cake_rounded,
      _ => Icons.restaurant_rounded,
    };
  }

  Color _resolveDifficultyColor(String difficulty) {
    return switch (difficulty) {
      'Easy' => const Color(0xFF16A34A),
      'Medium' => const Color(0xFFD97706),
      'Hard' => const Color(0xFFDC2626),
      _ => const Color(0xFF64748B),
    };
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _resolveDifficultyColor(recipe.difficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Category Icon Capsule
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _resolveCategoryIcon(recipe.category),
                    color: AppTheme.primaryEmerald,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Info Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          // Category tag
                          Text(
                            recipe.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                          const SizedBox(width: 8),

                          // Difficulty indicator
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: diffColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: diffColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                          const SizedBox(width: 8),

                          // Cooking time
                          const Icon(Icons.timer_outlined, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 3),
                          Text(
                            '${recipe.cookTime}m',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                IconButton(
                  icon: Icon(
                    recipe.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: recipe.favorite ? AppTheme.accentAmber : const Color(0xFF94A3B8),
                    size: 26,
                  ),
                  tooltip: 'Favorite',
                  onPressed: onFavoriteToggle,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
