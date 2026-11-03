import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/validators.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

/// Modal Bottom Sheet for adding a new recipe
/// Author: Nguyen Vinh Phu (QE180136)
class AddRecipeBottomSheet extends StatefulWidget {
  const AddRecipeBottomSheet({super.key});

  @override
  State<AddRecipeBottomSheet> createState() => _AddRecipeBottomSheetState();
}

class _AddRecipeBottomSheetState extends State<AddRecipeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _recipeService = RecipeService();

  AutovalidateMode _validationMode = AutovalidateMode.disabled;
  bool _isSubmitting = false;
  String? _submissionErrorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _chosenCategory = RecipeAppConstants.defaultCategoryPrompt;
  String _chosenDifficulty = RecipeAppConstants.defaultDifficultyPrompt;

  @override
  void dispose() {
    _nameController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitNewRecipe() async {
    setState(() {
      _validationMode = AutovalidateMode.onUserInteraction;
      _submissionErrorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _submissionErrorMessage = 'User is not logged in. Please log in first.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final int parsedCookTime = int.parse(_cookTimeController.text.trim());
      final int? parsedServings = _servingsController.text.trim().isNotEmpty
          ? int.parse(_servingsController.text.trim())
          : null;
      final String? parsedNotes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      final newRecipe = Recipe(
        id: '',
        userId: currentUser.uid,
        name: _nameController.text.trim(),
        category: _chosenCategory,
        difficulty: _chosenDifficulty,
        cookTime: parsedCookTime,
        servings: parsedServings,
        favorite: false,
        notes: parsedNotes,
        createdAt: DateTime.now(),
      );

      await _recipeService.addRecipe(newRecipe);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe added'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _submissionErrorMessage = error.toString().replaceFirst(RegExp(r'^\[.*?\]\s*'), '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: _validationMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Recipe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // Recipe Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name *',
                    hintText: 'e.g., Pho Bo, Spaghetti Carbonara',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: RecipeValidators.validateRecipeName,
                ),
                const SizedBox(height: 14),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _chosenCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    RecipeAppConstants.defaultCategoryPrompt,
                    ...RecipeAppConstants.categories,
                  ].map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
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
                    prefixIcon: Icon(Icons.speed),
                  ),
                  items: [
                    RecipeAppConstants.defaultDifficultyPrompt,
                    ...RecipeAppConstants.difficulties,
                  ].map((diff) {
                    return DropdownMenuItem(
                      value: diff,
                      child: Text(diff),
                    );
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

                // Cook Time & Servings Side by Side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cookTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cook Time (min) *',
                          hintText: '1 - 600',
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
                          hintText: '1 - 20',
                          prefixIcon: Icon(Icons.people_alt_outlined),
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
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Cooking steps, key ingredients, reminders...',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                  validator: RecipeValidators.validateNotes,
                ),
                const SizedBox(height: 18),

                // Error Message banner
                if (_submissionErrorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _submissionErrorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitNewRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Recipe'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
