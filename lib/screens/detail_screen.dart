import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/validators.dart';
import '../models/recipe.dart';
import '../repositories/firestore_recipe_repository.dart';

/// Detailed Culinary Specification & In-place Modification View
/// Author: Nguyen Vinh Phu (QE180136)
class DetailScreen extends StatefulWidget {
  final Recipe recipe;

  const DetailScreen({super.key, required this.recipe});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Recipe _snapshot;
  final _repository = FirestoreRecipeRepository();

  bool _isEditingActive = false;
  bool _isSavingUpdates = false;
  String? _feedbackErrorMessage;
  AutovalidateMode _validationPolicy = AutovalidateMode.disabled;

  final _editorFormKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  late TextEditingController _portionController;
  late TextEditingController _notesController;

  String? _selectedCategory;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.recipe;
    _populateControllers();
  }

  void _populateControllers() {
    _titleController = TextEditingController(text: _snapshot.name);
    _durationController = TextEditingController(text: _snapshot.cookTime.toString());
    _portionController = TextEditingController(
      text: _snapshot.servings != null ? _snapshot.servings.toString() : '',
    );
    _notesController = TextEditingController(text: _snapshot.notes ?? '');
    _selectedCategory = _snapshot.category;
    _selectedDifficulty = _snapshot.difficulty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _portionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleFavoriteToggle() async {
    final nextState = !_snapshot.favorite;
    setState(() => _snapshot = _snapshot.copyWith(favorite: nextState));

    final res = await _repository.invertFavoriteFlag(_snapshot.id, !nextState);
    if (res.isFailure && mounted) {
      setState(() => _snapshot = _snapshot.copyWith(favorite: !nextState));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.errorOrNull!), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _triggerDeletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete "${_snapshot.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final res = await _repository.eraseRecipe(_snapshot.id);
      if (mounted) {
        if (res.isSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${_snapshot.name}"'),
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

  Future<void> _persistModifications() async {
    setState(() {
      _validationPolicy = AutovalidateMode.onUserInteraction;
      _feedbackErrorMessage = null;
    });

    if (!_editorFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSavingUpdates = true);

    final updated = _snapshot.copyWith(
      name: _titleController.text.trim(),
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      cookTime: int.parse(_durationController.text.trim()),
      servings: _portionController.text.trim().isNotEmpty
          ? int.parse(_portionController.text.trim())
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    final res = await _repository.modifyRecipe(updated);

    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _snapshot = updated;
        _isEditingActive = false;
        _isSavingUpdates = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe updated successfully'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _feedbackErrorMessage = res.errorOrNull;
        _isSavingUpdates = false;
      });
    }
  }

  void _discardModifications() {
    setState(() {
      _populateControllers();
      _isEditingActive = false;
      _feedbackErrorMessage = null;
      _validationPolicy = AutovalidateMode.disabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceCanvas,
      appBar: AppBar(
        title: Text(_isEditingActive ? 'Edit Recipe' : 'Recipe Details'),
        backgroundColor: AppTheme.primaryEmerald,
        actions: [
          if (!_isEditingActive) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Recipe',
              onPressed: () => setState(() => _isEditingActive = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete Recipe',
              onPressed: _triggerDeletion,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Cancel Edit',
              onPressed: _discardModifications,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: _isEditingActive ? _buildEditMode() : _buildViewMode(),
      ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Title Container
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _snapshot.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryEmerald,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Category: ${_snapshot.category}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                iconSize: 32,
                icon: Icon(
                  _snapshot.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: _snapshot.favorite ? AppTheme.accentAmber : const Color(0xFF94A3B8),
                ),
                onPressed: _handleFavoriteToggle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Metrics Bento Row
        Row(
          children: [
            Expanded(
              child: _buildSpecificationBadge(
                label: 'Category',
                value: _snapshot.category,
                icon: Icons.category_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSpecificationBadge(
                label: 'Difficulty',
                value: _snapshot.difficulty,
                icon: Icons.speed_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSpecificationBadge(
                label: 'Cooking Time',
                value: '${_snapshot.cookTime} minutes',
                icon: Icons.schedule_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSpecificationBadge(
                label: 'Servings',
                value: _snapshot.servings != null ? '${_snapshot.servings} people' : 'Not specified',
                icon: Icons.groups_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Notes Container
        const Text(
          'Notes & Cooking Instructions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            _snapshot.notes != null && _snapshot.notes!.isNotEmpty
                ? _snapshot.notes!
                : 'No notes provided for this recipe.',
            style: TextStyle(
              fontSize: 14,
              color: _snapshot.notes != null && _snapshot.notes!.isNotEmpty
                  ? const Color(0xFF334155)
                  : const Color(0xFF94A3B8),
              fontStyle: _snapshot.notes != null && _snapshot.notes!.isNotEmpty
                  ? FontStyle.normal
                  : FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Form(
        key: _editorFormKey,
        autovalidateMode: _validationPolicy,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: RecipeValidators.validateRecipeName,
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category *'),
              items: [
                RecipeAppConstants.defaultCategoryPrompt,
                ...RecipeAppConstants.categories,
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              validator: RecipeValidators.validateCategory,
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _selectedDifficulty,
              decoration: const InputDecoration(labelText: 'Difficulty *'),
              items: [
                RecipeAppConstants.defaultDifficultyPrompt,
                ...RecipeAppConstants.difficulties,
              ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _selectedDifficulty = v),
              validator: RecipeValidators.validateDifficulty,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cook Time (min) *'),
                    validator: RecipeValidators.validateCookTime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _portionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Servings'),
                    validator: RecipeValidators.validateServings,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notes', alignLabelWithHint: true),
              validator: RecipeValidators.validateNotes,
            ),
            const SizedBox(height: 18),

            if (_feedbackErrorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  _feedbackErrorMessage!,
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _discardModifications,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSavingUpdates ? null : _persistModifications,
                    child: _isSavingUpdates
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationBadge({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryEmerald, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
