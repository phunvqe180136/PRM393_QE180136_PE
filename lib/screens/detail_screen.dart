import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/validators.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

/// Recipe Detailed Specification & Editing Screen
/// Author: Nguyen Vinh Phu (QE180136)
class DetailScreen extends StatefulWidget {
  final Recipe recipe;

  const DetailScreen({super.key, required this.recipe});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Recipe _currentRecipe;
  final RecipeService _recipeService = RecipeService();

  bool _isEditModeActive = false;
  bool _isSavingUpdates = false;
  String? _saveErrorMessage;
  AutovalidateMode _validationMode = AutovalidateMode.disabled;

  final _editFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _notesController;

  String? _chosenCategory;
  String? _chosenDifficulty;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
    _initializeFormFields();
  }

  void _initializeFormFields() {
    _nameController = TextEditingController(text: _currentRecipe.name);
    _cookTimeController = TextEditingController(text: _currentRecipe.cookTime.toString());
    _servingsController = TextEditingController(
      text: _currentRecipe.servings != null ? _currentRecipe.servings.toString() : '',
    );
    _notesController = TextEditingController(text: _currentRecipe.notes ?? '');
    _chosenCategory = _currentRecipe.category;
    _chosenDifficulty = _currentRecipe.difficulty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final nextFavoriteState = !_currentRecipe.favorite;
    setState(() {
      _currentRecipe = _currentRecipe.copyWith(favorite: nextFavoriteState);
    });

    try {
      await _recipeService.toggleFavorite(_currentRecipe.id, !nextFavoriteState);
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentRecipe = _currentRecipe.copyWith(favorite: !nextFavoriteState);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to permanently delete "${_currentRecipe.name}"?'),
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
        await _recipeService.deleteRecipe(_currentRecipe.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${_currentRecipe.name}"'),
              backgroundColor: Colors.black87,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete recipe: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _validationMode = AutovalidateMode.onUserInteraction;
      _saveErrorMessage = null;
    });

    if (!_editFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSavingUpdates = true;
    });

    try {
      final parsedCookTime = int.parse(_cookTimeController.text.trim());
      final parsedServings = _servingsController.text.trim().isNotEmpty
          ? int.parse(_servingsController.text.trim())
          : null;
      final parsedNotes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      final updatedRecipe = _currentRecipe.copyWith(
        name: _nameController.text.trim(),
        category: _chosenCategory,
        difficulty: _chosenDifficulty,
        cookTime: parsedCookTime,
        servings: parsedServings,
        notes: parsedNotes,
      );

      await _recipeService.updateRecipe(updatedRecipe);

      if (mounted) {
        setState(() {
          _currentRecipe = updatedRecipe;
          _isEditModeActive = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _saveErrorMessage = e.toString().replaceFirst(RegExp(r'^\[.*?\]\s*'), '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingUpdates = false;
        });
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _initializeFormFields();
      _isEditModeActive = false;
      _saveErrorMessage = null;
      _validationMode = AutovalidateMode.disabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditModeActive ? 'Edit Recipe' : 'Recipe Details'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditModeActive) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Recipe',
              onPressed: () {
                setState(() {
                  _isEditModeActive = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Recipe',
              onPressed: _handleDelete,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel Edit',
              onPressed: _cancelEditing,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: _isEditModeActive ? _buildEditMode() : _buildViewMode(),
      ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Favorite Row
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
                      fontSize: 15,
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

        // Detail Specification Tiles
        _buildInfoTile('Category', _currentRecipe.category, Icons.category_outlined),
        const SizedBox(height: 12),
        _buildInfoTile('Difficulty', _currentRecipe.difficulty, Icons.speed_outlined),
        const SizedBox(height: 12),
        _buildInfoTile('Cooking Time', '${_currentRecipe.cookTime} minutes', Icons.timer_outlined),
        const SizedBox(height: 12),
        _buildInfoTile(
          'Servings',
          _currentRecipe.servings != null ? '${_currentRecipe.servings} people' : 'Not specified',
          Icons.people_outline,
        ),
        const SizedBox(height: 16),

        // Notes section
        const Text(
          'Notes & Cooking Instructions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            _currentRecipe.notes != null && _currentRecipe.notes!.isNotEmpty
                ? _currentRecipe.notes!
                : 'No notes provided for this recipe.',
            style: TextStyle(
              fontSize: 14,
              color: _currentRecipe.notes != null && _currentRecipe.notes!.isNotEmpty
                  ? Colors.black87
                  : Colors.grey.shade600,
              fontStyle: _currentRecipe.notes != null && _currentRecipe.notes!.isNotEmpty
                  ? FontStyle.normal
                  : FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Form(
      key: _editFormKey,
      autovalidateMode: _validationMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.restaurant),
            ),
            validator: RecipeValidators.validateRecipeName,
          ),
          const SizedBox(height: 14),

          // Category Dropdown
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _chosenCategory,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: [
              RecipeAppConstants.defaultCategoryPrompt,
              ...RecipeAppConstants.categories,
            ].map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _chosenCategory = val;
                });
              }
            },
            validator: RecipeValidators.validateCategory,
          ),
          const SizedBox(height: 14),

          // Difficulty Dropdown
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _chosenDifficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.speed),
            ),
            items: [
              RecipeAppConstants.defaultDifficultyPrompt,
              ...RecipeAppConstants.difficulties,
            ].map((diff) {
              return DropdownMenuItem(value: diff, child: Text(diff));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _chosenDifficulty = val;
                });
              }
            },
            validator: RecipeValidators.validateDifficulty,
          ),
          const SizedBox(height: 14),

          // Cook Time and Servings Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cookTimeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cook Time (min) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  validator: RecipeValidators.validateCookTime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _servingsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Servings',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  validator: RecipeValidators.validateServings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Notes Field
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
            validator: RecipeValidators.validateNotes,
          ),
          const SizedBox(height: 18),

          // Error Message Box
          if (_saveErrorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _saveErrorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons: Cancel and Save
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSavingUpdates ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSavingUpdates
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange, size: 22),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
