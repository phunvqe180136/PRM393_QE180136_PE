import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../models/recipe.dart';
import '../repositories/firestore_recipe_repository.dart';

/// Next-Generation Recipe Creator Sheet
/// Author: Nguyen Vinh Phu (QE180136)
class AddRecipeBottomSheet extends StatefulWidget {
  const AddRecipeBottomSheet({super.key});

  @override
  State<AddRecipeBottomSheet> createState() => _AddRecipeBottomSheetState();
}

class _AddRecipeBottomSheetState extends State<AddRecipeBottomSheet> {
  final _creationFormKey = GlobalKey<FormState>();
  final _repository = FirestoreRecipeRepository();

  AutovalidateMode _validationMode = AutovalidateMode.disabled;
  bool _isPersisting = false;
  String? _serverErrorMessage;

  final TextEditingController _titleInputController = TextEditingController();
  final TextEditingController _minutesInputController = TextEditingController();
  final TextEditingController _portionInputController = TextEditingController();
  final TextEditingController _instructionInputController = TextEditingController();

  String _pickedCategory = RecipeAppConstants.defaultCategoryPrompt;
  String _pickedDifficulty = RecipeAppConstants.defaultDifficultyPrompt;

  @override
  void dispose() {
    _titleInputController.dispose();
    _minutesInputController.dispose();
    _portionInputController.dispose();
    _instructionInputController.dispose();
    super.dispose();
  }

  Future<void> _commitNewRecipe() async {
    setState(() {
      _validationMode = AutovalidateMode.onUserInteraction;
      _serverErrorMessage = null;
    });

    if (!_creationFormKey.currentState!.validate()) {
      return;
    }

    final activeUser = FirebaseAuth.instance.currentUser;
    if (activeUser == null) {
      setState(() => _serverErrorMessage = 'Active session required to save recipes.');
      return;
    }

    setState(() => _isPersisting = true);

    final duration = int.parse(_minutesInputController.text.trim());
    final portions = _portionInputController.text.trim().isNotEmpty
        ? int.parse(_portionInputController.text.trim())
        : null;
    final instructions = _instructionInputController.text.trim().isNotEmpty
        ? _instructionInputController.text.trim()
        : null;

    final candidate = Recipe(
      id: '',
      userId: activeUser.uid,
      name: _titleInputController.text.trim(),
      category: _pickedCategory,
      difficulty: _pickedDifficulty,
      cookTime: duration,
      servings: portions,
      favorite: false,
      notes: instructions,
      createdAt: DateTime.now(),
    );

    final outcome = await _repository.insertRecipe(candidate);

    if (!mounted) return;

    if (outcome.isSuccess) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _serverErrorMessage = outcome.errorOrNull;
        _isPersisting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _creationFormKey,
            autovalidateMode: _validationMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sheet drag handle & header
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Recipe',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryEmerald,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Name
                TextFormField(
                  controller: _titleInputController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name *',
                    hintText: 'e.g., Spring Rolls, Pho Bo',
                    prefixIcon: Icon(Icons.restaurant_rounded, size: 20),
                  ),
                  validator: RecipeValidators.validateRecipeName,
                ),
                const SizedBox(height: 14),

                // Category & Difficulty in row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _pickedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          prefixIcon: Icon(Icons.category_outlined, size: 20),
                        ),
                        items: [
                          RecipeAppConstants.defaultCategoryPrompt,
                          ...RecipeAppConstants.categories,
                        ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13.5)))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _pickedCategory = v);
                        },
                        validator: RecipeValidators.validateCategory,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _pickedDifficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty *',
                          prefixIcon: Icon(Icons.speed_rounded, size: 20),
                        ),
                        items: [
                          RecipeAppConstants.defaultDifficultyPrompt,
                          ...RecipeAppConstants.difficulties,
                        ].map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13.5)))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _pickedDifficulty = v);
                        },
                        validator: RecipeValidators.validateDifficulty,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Cook time & Servings
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minutesInputController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cook Time (min) *',
                          hintText: '1 - 600',
                          prefixIcon: Icon(Icons.schedule_rounded, size: 20),
                        ),
                        validator: RecipeValidators.validateCookTime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _portionInputController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Servings',
                          hintText: '1 - 20',
                          prefixIcon: Icon(Icons.groups_outlined, size: 20),
                        ),
                        validator: RecipeValidators.validateServings,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Notes
                TextFormField(
                  controller: _instructionInputController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Cooking reminders, special ingredients...',
                    prefixIcon: Icon(Icons.edit_note_rounded, size: 22),
                    alignLabelWithHint: true,
                  ),
                  validator: RecipeValidators.validateNotes,
                ),
                const SizedBox(height: 18),

                // Error message
                if (_serverErrorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      _serverErrorMessage!,
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isPersisting ? null : _commitNewRecipe,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                      ),
                      child: _isPersisting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
