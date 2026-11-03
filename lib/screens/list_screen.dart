import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe.dart';
import '../models/recipe_filter.dart';
import '../models/recipe_statistics.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import '../widgets/add_recipe_bottom_sheet.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_bar.dart';
import '../widgets/recipe_summary_card.dart';
import 'detail_screen.dart';

/// Protected Main Recipe List Screen
/// Author: Nguyen Vinh Phu (QE180136)
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  final TextEditingController _searchController = TextEditingController();

  RecipeFilterCriteria _filterCriteria = RecipeFilterCriteria.initial();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleResetFilters() {
    setState(() {
      _filterCriteria = RecipeFilterCriteria.initial();
      _searchController.clear();
    });
  }

  void _openAddRecipeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddRecipeBottomSheet(),
    );
  }

  Future<void> _handleDeleteConfirmation(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to permanently delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _recipeService.deleteRecipe(recipe.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${recipe.name}"'),
              backgroundColor: Colors.black87,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false, // Prevents Android back button from popping to auth screens
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            currentUser?.email ?? 'RecipeBox',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false, // Disables back chevron
          actions: [
            TextButton.icon(
              onPressed: () async {
                await _authService.signOut();
              },
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: currentUser == null
            ? const Center(child: Text('User not authenticated'))
            : StreamBuilder<List<Recipe>>(
                stream: _recipeService.getRecipesStream(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading recipes: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final allRecipes = snapshot.data ?? [];
                  final filteredRecipes = _filterCriteria.apply(allRecipes);
                  final summaryStats = RecipeStatistics.compute(filteredRecipes);

                  return Column(
                    children: [
                      // Filter & Search Controls
                      RecipeFilterBar(
                        criteria: _filterCriteria,
                        searchController: _searchController,
                        onCriteriaChanged: (updated) {
                          setState(() {
                            _filterCriteria = updated;
                          });
                        },
                        onClear: _handleResetFilters,
                      ),

                      // Aggregated Metrics Summary Card
                      RecipeSummaryCard(statistics: summaryStats),

                      const Divider(height: 1),

                      // Recipe Item Stream / Empty Placeholder
                      Expanded(
                        child: filteredRecipes.isEmpty
                            ? const Center(
                                child: Text(
                                  'No recipes found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: filteredRecipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = filteredRecipes[index];
                                  return RecipeCardWidget(
                                    recipe: recipe,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailScreen(recipe: recipe),
                                        ),
                                      );
                                    },
                                    onFavoriteToggle: () {
                                      _recipeService.toggleFavorite(recipe.id, recipe.favorite);
                                    },
                                    onDelete: () {
                                      _handleDeleteConfirmation(recipe);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddRecipeSheet,
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          tooltip: 'Add Recipe',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
