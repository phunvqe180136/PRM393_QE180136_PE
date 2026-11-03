import '../constants/app_constants.dart';

/// Centralized Form Validators for RecipeBox
/// Author: Nguyen Vinh Phu - QE180136
class RecipeValidators {
  RecipeValidators._();

  // -------------------------------------------------------------
  // Authentication Validators
  // -------------------------------------------------------------

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // -------------------------------------------------------------
  // Recipe Form Validators (Matching Fall 2026 PE Spec)
  // -------------------------------------------------------------

  static String? validateRecipeName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Recipe name is required';
    }
    if (value.trim().length > RecipeAppConstants.maxNameLength) {
      return 'Recipe name cannot exceed 80 characters';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value == RecipeAppConstants.defaultCategoryPrompt) {
      return 'Please select a category';
    }
    if (!RecipeAppConstants.categories.contains(value)) {
      return 'Invalid category selected';
    }
    return null;
  }

  static String? validateDifficulty(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value == RecipeAppConstants.defaultDifficultyPrompt) {
      return 'Please select a difficulty level';
    }
    if (!RecipeAppConstants.difficulties.contains(value)) {
      return 'Invalid difficulty selected';
    }
    return null;
  }

  static String? validateCookTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cook time is required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Must be a valid integer';
    }
    if (parsed < RecipeAppConstants.minCookTime ||
        parsed > RecipeAppConstants.maxCookTime) {
      return 'Cook time must be between 1 and 600 minutes';
    }
    return null;
  }

  static String? validateServings(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Servings is optional
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null ||
        parsed < RecipeAppConstants.minServings ||
        parsed > RecipeAppConstants.maxServings) {
      return 'Servings must be a whole number between 1 and 20';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Notes is optional
    }
    if (value.trim().length > RecipeAppConstants.maxNotesLength) {
      return 'Notes cannot exceed 300 characters';
    }
    return null;
  }
}

