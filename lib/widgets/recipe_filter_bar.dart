import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/recipe_filter.dart';

/// Interactive Filter & Search Control Panel
/// Author: Nguyen Vinh Phu (QE180136)
class RecipeFilterBar extends StatelessWidget {
  final RecipeFilterCriteria criteria;
  final TextEditingController searchController;
  final ValueChanged<RecipeFilterCriteria> onCriteriaChanged;
  final VoidCallback onClear;

  const RecipeFilterBar({
    super.key,
    required this.criteria,
    required this.searchController,
    required this.onCriteriaChanged,
    required this.onClear,
  });

  static const List<String> categoryOptions = [
    'All',
    ...RecipeAppConstants.categories,
  ];

  static const List<String> difficultyOptions = [
    'All',
    ...RecipeAppConstants.difficulties,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Column(
        children: [
          // Search Box with instant clear icon
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search name or notes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onCriteriaChanged(criteria.copyWith(searchQuery: ''));
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) {
              onCriteriaChanged(criteria.copyWith(searchQuery: val));
            },
          ),
          const SizedBox(height: 8),

          // Dropdowns for Category and Difficulty
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: criteria.category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: categoryOptions.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (newCat) {
                    if (newCat != null) {
                      onCriteriaChanged(criteria.copyWith(category: newCat));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: criteria.difficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: difficultyOptions.map((diff) {
                    return DropdownMenuItem(
                      value: diff,
                      child: Text(diff, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (newDiff) {
                    if (newDiff != null) {
                      onCriteriaChanged(criteria.copyWith(difficulty: newDiff));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Filter Controls: Favorites Only Chip & Reset Action
          Row(
            children: [
              FilterChip(
                label: const Text('Favorites Only'),
                selected: criteria.onlyFavorites,
                avatar: Icon(
                  criteria.onlyFavorites ? Icons.star : Icons.star_border,
                  color: criteria.onlyFavorites ? Colors.amber : Colors.grey,
                  size: 18,
                ),
                onSelected: (selected) {
                  onCriteriaChanged(criteria.copyWith(onlyFavorites: selected));
                },
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
