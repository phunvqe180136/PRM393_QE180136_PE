import 'package:flutter/material.dart';
import '../models/recipe.dart';

/// Individual Recipe Card Widget displayed in the list view
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Recipe Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildCategoryBadge(recipe.category),
                        const SizedBox(width: 8),
                        _buildDifficultyBadge(recipe.difficulty),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${recipe.cookTime}m',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      recipe.favorite ? Icons.star : Icons.star_border,
                      color: recipe.favorite ? Colors.amber : Colors.grey,
                      size: 26,
                    ),
                    tooltip: 'Toggle Favorite',
                    onPressed: onFavoriteToggle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                    tooltip: 'Delete Recipe',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.deepOrange.shade200),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.deepOrange.shade800,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color textColor;
    Color bgColor;

    switch (difficulty) {
      case 'Easy':
        textColor = Colors.green.shade800;
        bgColor = Colors.green.shade50;
        break;
      case 'Medium':
        textColor = Colors.orange.shade800;
        bgColor = Colors.orange.shade50;
        break;
      case 'Hard':
        textColor = Colors.red.shade800;
        bgColor = Colors.red.shade50;
        break;
      default:
        textColor = Colors.grey.shade800;
        bgColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

