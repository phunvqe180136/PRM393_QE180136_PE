import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import '../widgets/add_recipe_bottom_sheet.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategoryFilter = 'All';
  String _selectedDifficultyFilter = 'All';
  bool _favoritesOnly = false;
  String _searchQuery = '';

  final List<String> _categoryFilterOptions = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Dessert'];
  final List<String> _difficultyFilterOptions = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryFilter = 'All';
      _selectedDifficultyFilter = 'All';
      _favoritesOnly = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _showAddRecipeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddRecipeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false, // Ngăn bấm nút Back quay lại form Login/Register
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            currentUser?.email ?? 'RecipeBox',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false, // Bỏ nút back
          actions: [
            TextButton.icon(
              onPressed: () async {
                await _authService.signOut();
              },
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: currentUser == null
            ? const Center(child: Text('User not authenticated'))
            : StreamBuilder<List<RecipeModel>>(
                stream: _recipeService.getRecipesStream(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading recipes: ${snapshot.error}'),
                    );
                  }

                  final allRecipes = snapshot.data ?? [];

                  // Lọc công thức theo 4 tiêu chí: Category, Difficulty, Favorites Only, Search
                  final filteredRecipes = allRecipes.where((recipe) {
                    // Lọc Category
                    if (_selectedCategoryFilter != 'All' && recipe.category != _selectedCategoryFilter) {
                      return false;
                    }
                    // Lọc Difficulty
                    if (_selectedDifficultyFilter != 'All' && recipe.difficulty != _selectedDifficultyFilter) {
                      return false;
                    }
                    // Lọc Favorites Only
                    if (_favoritesOnly && !recipe.favorite) {
                      return false;
                    }
                    // Lọc Search (Name hoặc Notes)
                    if (_searchQuery.trim().isNotEmpty) {
                      final q = _searchQuery.trim().toLowerCase();
                      final matchName = recipe.name.toLowerCase().contains(q);
                      final matchNotes = recipe.notes != null && recipe.notes!.toLowerCase().contains(q);
                      if (!matchName && !matchNotes) {
                        return false;
                      }
                    }
                    return true;
                  }).toList();

                  return Column(
                    children: [
                      // Vùng Bộ lọc, Tìm kiếm và Nút Clear
                      _buildFilterAndSearchSection(),
                      // Vùng Tổng quan Summary
                      _buildSummarySection(filteredRecipes),
                      const Divider(height: 1),
                      // Vùng Hiển thị Danh sách Công thức
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
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    child: ListTile(
                                      title: Text(
                                        recipe.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 2),
                                          Text('Cook time: ${recipe.cookTime} min'),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.deepOrange.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  recipe.category,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  recipe.difficulty,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.amber.shade900,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          recipe.favorite ? Icons.star : Icons.star_border,
                                          color: recipe.favorite ? Colors.amber : Colors.grey,
                                        ),
                                        onPressed: () {
                                          _recipeService.toggleFavorite(recipe.id, recipe.favorite);
                                        },
                                        tooltip: 'Toggle favorite',
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailScreen(recipe: recipe),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddRecipeBottomSheet,
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          tooltip: 'Add Recipe',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// Widget hiển thị Thanh tìm kiếm, dropdown Category, Difficulty, switch Favorites và nút Clear
  Widget _buildFilterAndSearchSection() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Search box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search name or notes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
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
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Category Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedCategoryFilter,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _categoryFilterOptions.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategoryFilter = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Difficulty Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedDifficultyFilter,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _difficultyFilterOptions.map((d) {
                    return DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedDifficultyFilter = val;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Favorites Only Switch
              FilterChip(
                label: const Text('Favorites Only'),
                selected: _favoritesOnly,
                avatar: Icon(
                  _favoritesOnly ? Icons.star : Icons.star_border,
                  color: _favoritesOnly ? Colors.amber : Colors.grey,
                  size: 18,
                ),
                onSelected: (selected) {
                  setState(() {
                    _favoritesOnly = selected;
                  });
                },
              ),
              const Spacer(),
              // Clear Button
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget tổng quan mô tả số lượng công thức, số lượng yêu thích, tổng thời gian nấu và phân bổ theo Category
  Widget _buildSummarySection(List<RecipeModel> recipes) {
    final int totalCount = recipes.length;
    final int favCount = recipes.where((r) => r.favorite).length;
    final int totalTime = recipes.fold(0, (sum, r) => sum + r.cookTime);

    // Đếm theo từng category
    final Map<String, int> categoryCounts = {};
    for (var recipe in recipes) {
      categoryCounts[recipe.category] = (categoryCounts[recipe.category] ?? 0) + 1;
    }

    // Sắp xếp các category xuất hiện: số lượng nhiều nhất xếp trước
    // Nếu bằng nhau: Breakfast -> Lunch -> Dinner -> Dessert
    final constOrder = ['Breakfast', 'Lunch', 'Dinner', 'Dessert'];
    final categoryEntries = categoryCounts.entries.where((e) => e.value > 0).toList();

    categoryEntries.sort((a, b) {
      int countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      int orderA = constOrder.indexOf(a.key);
      int orderB = constOrder.indexOf(b.key);
      if (orderA == -1) orderA = 99;
      if (orderB == -1) orderB = 99;
      return orderA.compareTo(orderB);
    });

    return Container(
      width: double.infinity,
      color: Colors.deepOrange.shade50.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recipes: $totalCount',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Text(
                'Favorites: $favCount',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber),
              ),
              const SizedBox(width: 16),
              Text(
                'Total time: $totalTime min',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepOrange),
              ),
            ],
          ),
          if (categoryEntries.isNotEmpty) ...[
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categoryEntries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    '${e.key}: ${e.value}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
