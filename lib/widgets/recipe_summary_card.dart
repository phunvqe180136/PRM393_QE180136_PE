import 'package:flutter/material.dart';
import '../models/recipe_statistics.dart';

/// Recipe Summary & Category Breakdown Dashboard Widget
/// Author: Nguyen Vinh Phu (QE180136)
class RecipeSummaryCard extends StatelessWidget {
  final RecipeStatistics statistics;

  const RecipeSummaryCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 3 Primary Metric Counters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                label: 'Recipes',
                value: statistics.totalRecipes.toString(),
                icon: Icons.menu_book_outlined,
                color: Colors.deepOrange,
              ),
              _buildVerticalDivider(),
              _buildMetricItem(
                label: 'Favorites',
                value: statistics.favoriteCount.toString(),
                icon: Icons.star,
                color: Colors.amber.shade700,
              ),
              _buildVerticalDivider(),
              _buildMetricItem(
                label: 'Total time',
                value: '${statistics.totalCookingMinutes}m',
                icon: Icons.access_time_filled,
                color: Colors.blueGrey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 10),

          // Category Breakdown Badges
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statistics.categoryCounts.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(color: Colors.grey.shade300),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}
