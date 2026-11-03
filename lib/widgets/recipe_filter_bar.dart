import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/recipe_filter.dart';

/// Modern Segmented Filter & Search Control Dashboard
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

  static const List<String> availableCategories = [
    'All',
    ...RecipeAppConstants.categories,
  ];

  static const List<String> availableDifficulties = [
    'All',
    ...RecipeAppConstants.difficulties,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Pill
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search name or notes...',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryEmerald, size: 22),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        searchController.clear();
                        onCriteriaChanged(criteria.copyWith(searchQuery: ''));
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppTheme.primaryEmerald, width: 1.5),
              ),
            ),
            onChanged: (q) => onCriteriaChanged(criteria.copyWith(searchQuery: q)),
          ),
          const SizedBox(height: 10),

          // Horizontal Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: availableCategories.map((cat) {
                final isSelected = criteria.category == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: AppTheme.primaryEmerald,
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    onSelected: (_) => onCriteriaChanged(criteria.copyWith(category: cat)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Secondary Controls: Difficulty Selector, Favorites switch, Clear action
          Row(
            children: [
              // Difficulty selector button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: criteria.difficulty,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF64748B)),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w600),
                    items: availableDifficulties.map((diff) {
                      return DropdownMenuItem(value: diff, child: Text(diff == 'All' ? 'Difficulty: All' : diff));
                    }).toList(),
                    onChanged: (d) {
                      if (d != null) onCriteriaChanged(criteria.copyWith(difficulty: d));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Favorites Only FilterChip
              FilterChip(
                label: const Text('Favorites Only'),
                selected: criteria.onlyFavorites,
                avatar: Icon(
                  criteria.onlyFavorites ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16,
                  color: criteria.onlyFavorites ? AppTheme.accentAmber : const Color(0xFF94A3B8),
                ),
                showCheckmark: false,
                selectedColor: AppTheme.accentAmber.withValues(alpha: 0.15),
                backgroundColor: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: criteria.onlyFavorites ? AppTheme.accentAmber : const Color(0xFFE2E8F0),
                  ),
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: criteria.onlyFavorites ? AppTheme.accentAmber : const Color(0xFF475569),
                ),
                onSelected: (fav) => onCriteriaChanged(criteria.copyWith(onlyFavorites: fav)),
              ),
              const Spacer(),

              // Clear button
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
