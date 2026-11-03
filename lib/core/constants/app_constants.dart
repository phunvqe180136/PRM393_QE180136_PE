// PRM393 - Practical Exam (Fall 2026)
// Student: Nguyen Vinh Phu (QE180136)
// Project: RecipeBox

class RecipeAppConstants {
  RecipeAppConstants._();

  static const String appTitle = 'RecipeBox';
  static const String firestoreCollection = 'recipes';

  // Recipe Categories (Strictly following exam specifications)
  static const String defaultCategoryPrompt = 'Choose category';
  static const List<String> categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
  ];

  // Recipe Difficulties
  static const String defaultDifficultyPrompt = 'Choose difficulty';
  static const List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];

  // Validation Limits
  static const int minCookTime = 1;
  static const int maxCookTime = 600;
  static const int minServings = 1;
  static const int maxServings = 20;
  static const int maxNameLength = 80;
  static const int maxNotesLength = 300;
}
