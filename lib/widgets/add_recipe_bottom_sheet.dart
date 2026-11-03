import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

class AddRecipeBottomSheet extends StatefulWidget {
  final RecipeModel? recipeToEdit; // Nếu != null thì là chế độ Chỉnh sửa

  const AddRecipeBottomSheet({super.key, this.recipeToEdit});

  @override
  State<AddRecipeBottomSheet> createState() => _AddRecipeBottomSheetState();
}

class _AddRecipeBottomSheetState extends State<AddRecipeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _recipeService = RecipeService();

  late final TextEditingController _nameController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;
  late final TextEditingController _notesController;

  String? _selectedCategory;
  String? _selectedDifficulty;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _categoryOptions = ['Choose category', 'Breakfast', 'Lunch', 'Dinner', 'Dessert'];
  final List<String> _difficultyOptions = ['Choose difficulty', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipeToEdit;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _cookTimeController = TextEditingController(text: recipe?.cookTime != null ? recipe!.cookTime.toString() : '');
    _servingsController = TextEditingController(text: recipe?.servings != null ? recipe!.servings.toString() : '');
    _notesController = TextEditingController(text: recipe?.notes ?? '');

    _selectedCategory = (recipe != null && _categoryOptions.contains(recipe.category))
        ? recipe.category
        : 'Choose category';

    _selectedDifficulty = (recipe != null && _difficultyOptions.contains(recipe.difficulty))
        ? recipe.difficulty
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

  Future<void> _submitForm() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final cookTimeVal = int.parse(_cookTimeController.text.trim());
    final servingsVal = _servingsController.text.trim().isNotEmpty
        ? int.tryParse(_servingsController.text.trim())
        : null;

    final newRecipe = RecipeModel(
      id: widget.recipeToEdit?.id ?? '',
      userId: currentUser.uid,
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      difficulty: _selectedDifficulty!,
      cookTime: cookTimeVal,
      servings: servingsVal,
      favorite: widget.recipeToEdit?.favorite ?? false,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.recipeToEdit?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.recipeToEdit == null) {
        await _recipeService.addRecipe(newRecipe);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe added'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _recipeService.updateRecipe(newRecipe);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe updated'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, newRecipe);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.recipeToEdit == null ? 'Add a recipe' : 'Edit recipe',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 16),
              // Name Field
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
              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categoryOptions.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
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
              // Difficulty Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty *',
                  border: OutlineInputBorder(),
                ),
                items: _difficultyOptions.map((difficulty) {
                  return DropdownMenuItem<String>(
                    value: difficulty,
                    child: Text(difficulty),
                  );
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
              // Cook time Field
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
              // Servings Field (Optional)
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
              // Notes Field (Optional)
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
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.recipeToEdit == null ? 'Save Recipe' : 'Save Changes',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
