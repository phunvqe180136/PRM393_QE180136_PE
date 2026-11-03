import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

class DetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const DetailScreen({super.key, required this.recipe});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late RecipeModel _currentRecipe;
  final RecipeService _recipeService = RecipeService();
  bool _isEditingInline = false;

  // Form controllers cho Inline Edit mode
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;
  late final TextEditingController _notesController;

  String? _selectedCategory;
  String? _selectedDifficulty;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isSaving = false;
  String? _errorMessage;

  final List<String> _categoryOptions = ['Choose category', 'Breakfast', 'Lunch', 'Dinner', 'Dessert'];
  final List<String> _difficultyOptions = ['Choose difficulty', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: _currentRecipe.name);
    _cookTimeController = TextEditingController(text: _currentRecipe.cookTime.toString());
    _servingsController = TextEditingController(
      text: _currentRecipe.servings != null ? _currentRecipe.servings.toString() : '',
    );
    _notesController = TextEditingController(text: _currentRecipe.notes ?? '');

    _selectedCategory = _categoryOptions.contains(_currentRecipe.category)
        ? _currentRecipe.category
        : 'Choose category';

    _selectedDifficulty = _difficultyOptions.contains(_currentRecipe.difficulty)
        ? _currentRecipe.difficulty
        : 'Choose difficulty';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Toggle trạng thái Yêu thích
  Future<void> _toggleFavorite() async {
    final newFavorite = !_currentRecipe.favorite;
    setState(() {
      _currentRecipe = _currentRecipe.copyWith(favorite: newFavorite);
    });

    try {
      await _recipeService.toggleFavorite(_currentRecipe.id, !newFavorite);
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentRecipe = _currentRecipe.copyWith(favorite: !newFavorite);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite: $e')),
        );
      }
    }
  }

  /// Xóa công thức
  Future<void> _deleteRecipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${_currentRecipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _recipeService.deleteRecipe(_currentRecipe.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete recipe: $e')),
        );
      }
    }
  }

  /// Lưu chỉnh sửa trong Inline Edit
  Future<void> _saveEdit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final cookTimeVal = int.parse(_cookTimeController.text.trim());
    final servingsVal = _servingsController.text.trim().isNotEmpty
        ? int.tryParse(_servingsController.text.trim())
        : null;

    final updatedRecipe = _currentRecipe.copyWith(
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      difficulty: _selectedDifficulty!,
      cookTime: cookTimeVal,
      servings: servingsVal,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    try {
      await _recipeService.updateRecipe(updatedRecipe);
      if (mounted) {
        setState(() {
          _currentRecipe = updatedRecipe;
          _isEditingInline = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _initControllers();
      _isEditingInline = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditingInline ? 'Edit Recipe' : _currentRecipe.name),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditingInline) ...[
            IconButton(
              icon: Icon(
                _currentRecipe.favorite ? Icons.star : Icons.star_border,
                color: _currentRecipe.favorite ? Colors.amber : Colors.white,
              ),
              onPressed: _toggleFavorite,
              tooltip: 'Favorite',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditingInline = true;
                });
              },
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteRecipe,
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: _isEditingInline ? _buildEditMode() : _buildViewMode(),
      ),
    );
  }

  /// Giao diện Chế độ Xem (View Mode)
  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentRecipe.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Category: ${_currentRecipe.category}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              iconSize: 32,
              icon: Icon(
                _currentRecipe.favorite ? Icons.star : Icons.star_border,
                color: _currentRecipe.favorite ? Colors.amber : Colors.grey,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        const Divider(height: 32),
        _buildInfoTile('Category', _currentRecipe.category, Icons.category_outlined),
        const SizedBox(height: 12),
        _buildInfoTile('Difficulty', _currentRecipe.difficulty, Icons.speed_outlined),
        const SizedBox(height: 12),
        _buildInfoTile('Cook Time', '${_currentRecipe.cookTime} min', Icons.timer_outlined),
        const SizedBox(height: 12),
        _buildInfoTile(
          'Servings',
          _currentRecipe.servings != null ? '${_currentRecipe.servings}' : 'Not specified',
          Icons.people_outline,
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          'Notes',
          _currentRecipe.notes != null && _currentRecipe.notes!.isNotEmpty
              ? _currentRecipe.notes!
              : 'No notes added.',
          Icons.note_alt_outlined,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditingInline = true;
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Recipe'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepOrange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Giao diện Chế độ Chỉnh sửa (Edit Mode)
  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              if (value.trim().length > 80) {
                return 'Name must be at most 80 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
            ),
            items: _categoryOptions.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCategory = val;
              });
            },
            validator: (value) {
              if (value == null || value == 'Choose category') {
                return 'Please choose a category';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedDifficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty *',
              border: OutlineInputBorder(),
            ),
            items: _difficultyOptions.map((d) {
              return DropdownMenuItem(value: d, child: Text(d));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDifficulty = val;
              });
            },
            validator: (value) {
              if (value == null || value == 'Choose difficulty') {
                return 'Please choose a difficulty';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cookTimeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cook time (minutes) *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Cook time is required';
              }
              final cookVal = int.tryParse(value.trim());
              if (cookVal == null || cookVal < 1 || cookVal > 600) {
                return 'Cook time must be a whole number from 1 to 600';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _servingsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Servings (1 to 20, optional)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final servingsVal = int.tryParse(value.trim());
                if (servingsVal == null || servingsVal < 1 || servingsVal > 20) {
                  return 'Servings must be a whole number from 1 to 20';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != null && value.trim().length > 300) {
                return 'Notes must be at most 300 characters';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _cancelEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
