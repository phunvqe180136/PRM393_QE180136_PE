import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/app_theme.dart';
import '../models/recipe.dart';
import '../models/recipe_filter.dart';
import '../models/recipe_statistics.dart';
import '../repositories/firebase_auth_repository.dart';
import '../repositories/firestore_recipe_repository.dart';
import '../widgets/add_recipe_bottom_sheet.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_bar.dart';
import '../widgets/recipe_summary_card.dart';
import 'detail_screen.dart';

/// Next-Generation Recipe Collection Screen
/// Author: Nguyen Vinh Phu (QE180136)
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _authGateway = FirebaseAuthRepository();
  final _recipeGateway = FirestoreRecipeRepository();
  final TextEditingController _searchFilterController = TextEditingController();

  RecipeFilterCriteria _currentFilterCriteria = RecipeFilterCriteria.initial();

  @override
  void dispose() {
    _searchFilterController.dispose();
    super.dispose();
  }

  void _resetActiveFilters() {
    setState(() {
      _currentFilterCriteria = RecipeFilterCriteria.initial();
      _searchFilterController.clear();
    });
  }

  void _triggerAddRecipeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddRecipeBottomSheet(),
    );
  }

  Future<void> _confirmRecipeRemoval(Recipe targetRecipe) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete "${targetRecipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final res = await _recipeGateway.eraseRecipe(targetRecipe.id);
      if (mounted) {
        if (res.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${targetRecipe.name}"'),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.errorOrNull!), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false, // Strict exam compliance: Disable hardware back to auth screens
      child: Scaffold(
        backgroundColor: AppTheme.surfaceCanvas,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppTheme.primaryEmerald,
          title: Text(
            activeUser?.email ?? 'RecipeBox',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton.icon(
              onPressed: () async => await _authGateway.logOut(),
              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: activeUser == null
            ? const Center(child: Text('User not authenticated'))
            : StreamBuilder<List<Recipe>>(
                stream: _recipeGateway.subscribeUserRecipes(activeUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryEmerald),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Error loading recipes: ${snapshot.error}',
                          style: const TextStyle(color: Color(0xFFDC2626)),
                        ),
                      ),
                    );
                  }

                  final allRecipes = snapshot.data ?? [];
                  final filteredCollection = _currentFilterCriteria.apply(allRecipes);
                  final metricSummary = RecipeStatistics.compute(filteredCollection);

                  return Column(
                    children: [
                      // Filter & Search Header
                      RecipeFilterBar(
                        criteria: _currentFilterCriteria,
                        searchController: _searchFilterController,
                        onCriteriaChanged: (newCriteria) {
                          setState(() => _currentFilterCriteria = newCriteria);
                        },
                        onClear: _resetActiveFilters,
                      ),

                      // Metrics Dashboard
                      RecipeSummaryCard(statistics: metricSummary),

                      // Recipe Scroll View / Empty State
                      Expanded(
                        child: filteredCollection.isEmpty
                            ? _buildEmptyStatePlaceholder()
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: filteredCollection.length,
                                itemBuilder: (context, index) {
                                  final item = filteredCollection[index];
                                  return RecipeCardWidget(
                                    recipe: item,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailScreen(recipe: item),
                                        ),
                                      );
                                    },
                                    onFavoriteToggle: () {
                                      _recipeGateway.invertFavoriteFlag(item.id, item.favorite);
                                    },
                                    onDelete: () => _confirmRecipeRemoval(item),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _triggerAddRecipeModal,
          backgroundColor: AppTheme.primaryEmerald,
          foregroundColor: Colors.white,
          elevation: 3,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyStatePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.soup_kitchen_outlined,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No recipes found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add a recipe or adjust your filters',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
