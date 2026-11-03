import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_box/core/utils/validators.dart';
import 'package:recipe_box/models/recipe.dart';
import 'package:recipe_box/models/recipe_filter.dart';
import 'package:recipe_box/models/recipe_statistics.dart';

/// Comprehensive Unit Tests for RecipeBox Application Logic
/// Student: Nguyen Vinh Phu (QE180136)
/// Subject: PRM393 - Fall 2026
void main() {
  group('1. RecipeValidators Test Suite', () {
    test('validateEmail handles invalid and valid cases', () {
      expect(RecipeValidators.validateEmail(null), 'Email is required');
      expect(RecipeValidators.validateEmail(''), 'Email is required');
      expect(RecipeValidators.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(RecipeValidators.validateEmail('test@example'), 'Please enter a valid email address');
      expect(RecipeValidators.validateEmail('grader.qe180136@example.com'), isNull);
    });

    test('validatePassword enforces length restrictions', () {
      expect(RecipeValidators.validatePassword(null), 'Password is required');
      expect(RecipeValidators.validatePassword(''), 'Password is required');
      expect(RecipeValidators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(RecipeValidators.validatePassword('123456'), isNull);
    });

    test('validateConfirmPassword ensures password matching', () {
      expect(RecipeValidators.validateConfirmPassword(null, 'secret123'), 'Confirm password is required');
      expect(RecipeValidators.validateConfirmPassword('wrong', 'secret123'), 'Passwords do not match');
      expect(RecipeValidators.validateConfirmPassword('secret123', 'secret123'), isNull);
    });

    test('validateRecipeName enforces requirement and length <= 80', () {
      expect(RecipeValidators.validateRecipeName(null), 'Recipe name is required');
      expect(RecipeValidators.validateRecipeName('   '), 'Recipe name is required');
      expect(RecipeValidators.validateRecipeName('A' * 81), 'Recipe name cannot exceed 80 characters');
      expect(RecipeValidators.validateRecipeName('Phở Bò'), isNull);
      expect(RecipeValidators.validateRecipeName('A' * 80), isNull);
    });

    test('validateCategory verifies predefined options', () {
      expect(RecipeValidators.validateCategory(null), 'Please select a category');
      expect(RecipeValidators.validateCategory('Choose category'), 'Please select a category');
      expect(RecipeValidators.validateCategory('UnknownCategory'), 'Invalid category selected');
      expect(RecipeValidators.validateCategory('Breakfast'), isNull);
      expect(RecipeValidators.validateCategory('Lunch'), isNull);
      expect(RecipeValidators.validateCategory('Dinner'), isNull);
      expect(RecipeValidators.validateCategory('Dessert'), isNull);
    });

    test('validateDifficulty verifies predefined levels', () {
      expect(RecipeValidators.validateDifficulty(null), 'Please select a difficulty level');
      expect(RecipeValidators.validateDifficulty('Choose difficulty'), 'Please select a difficulty level');
      expect(RecipeValidators.validateDifficulty('Impossible'), 'Invalid difficulty selected');
      expect(RecipeValidators.validateDifficulty('Easy'), isNull);
      expect(RecipeValidators.validateDifficulty('Medium'), isNull);
      expect(RecipeValidators.validateDifficulty('Hard'), isNull);
    });

    test('validateCookTime requires whole number between 1 and 600', () {
      expect(RecipeValidators.validateCookTime(null), 'Cook time is required');
      expect(RecipeValidators.validateCookTime('abc'), 'Must be a valid integer');
      expect(RecipeValidators.validateCookTime('0'), 'Cook time must be between 1 and 600 minutes');
      expect(RecipeValidators.validateCookTime('-5'), 'Cook time must be between 1 and 600 minutes');
      expect(RecipeValidators.validateCookTime('601'), 'Cook time must be between 1 and 600 minutes');
      expect(RecipeValidators.validateCookTime('45'), isNull);
      expect(RecipeValidators.validateCookTime('1'), isNull);
      expect(RecipeValidators.validateCookTime('600'), isNull);
    });

    test('validateServings allows optional or whole number 1..20', () {
      expect(RecipeValidators.validateServings(null), isNull);
      expect(RecipeValidators.validateServings(''), isNull);
      expect(RecipeValidators.validateServings('xyz'), 'Servings must be a whole number between 1 and 20');
      expect(RecipeValidators.validateServings('0'), 'Servings must be a whole number between 1 and 20');
      expect(RecipeValidators.validateServings('21'), 'Servings must be a whole number between 1 and 20');
      expect(RecipeValidators.validateServings('4'), isNull);
    });

    test('validateNotes allows optional or max 300 characters', () {
      expect(RecipeValidators.validateNotes(null), isNull);
      expect(RecipeValidators.validateNotes(''), isNull);
      expect(RecipeValidators.validateNotes('A' * 301), 'Notes cannot exceed 300 characters');
      expect(RecipeValidators.validateNotes('A' * 300), isNull);
    });
  });

  group('2. Recipe Model & Serialization Tests', () {
    test('Recipe.fromMap parses standard payload correctly', () {
      final sampleData = {
        'userId': 'user_180136',
        'name': 'Bánh Mì Pate',
        'category': 'Breakfast',
        'difficulty': 'Easy',
        'cookTime': 15,
        'servings': 2,
        'favorite': true,
        'notes': 'Add extra cilantro and chili.',
      };

      final recipe = Recipe.fromMap(sampleData, 'doc_123');

      expect(recipe.id, 'doc_123');
      expect(recipe.userId, 'user_180136');
      expect(recipe.name, 'Bánh Mì Pate');
      expect(recipe.category, 'Breakfast');
      expect(recipe.difficulty, 'Easy');
      expect(recipe.cookTime, 15);
      expect(recipe.servings, 2);
      expect(recipe.favorite, true);
      expect(recipe.notes, 'Add extra cilantro and chili.');
      expect(recipe.hasServings, true);
      expect(recipe.hasNotes, true);
      expect(recipe.formattedCookTime, '15 min');
    });

    test('Recipe.copyWith duplicates and overrides attributes cleanly', () {
      const original = Recipe(
        id: 'r1',
        userId: 'u1',
        name: 'Gỏi Cuốn',
        category: 'Lunch',
        difficulty: 'Easy',
        cookTime: 20,
      );

      final modified = original.copyWith(
        name: 'Gỏi Cuốn Tôm Thịt',
        favorite: true,
        cookTime: 25,
      );

      expect(modified.id, 'r1');
      expect(modified.name, 'Gỏi Cuốn Tôm Thịt');
      expect(modified.favorite, true);
      expect(modified.cookTime, 25);
      expect(modified.category, 'Lunch');
    });
  });

  group('3. RecipeFilterCriteria Filtering Logic', () {
    final List<Recipe> testDataset = [
      const Recipe(
        id: '1',
        userId: 'u1',
        name: 'Pancakes',
        category: 'Breakfast',
        difficulty: 'Easy',
        cookTime: 15,
        favorite: true,
        notes: 'Serve warm with maple syrup',
      ),
      const Recipe(
        id: '2',
        userId: 'u1',
        name: 'Beef Stew',
        category: 'Dinner',
        difficulty: 'Hard',
        cookTime: 120,
        favorite: false,
        notes: 'Slow cook for tender meat',
      ),
      const Recipe(
        id: '3',
        userId: 'u1',
        name: 'Chicken Salad',
        category: 'Lunch',
        difficulty: 'Easy',
        cookTime: 20,
        favorite: true,
      ),
      const Recipe(
        id: '4',
        userId: 'u1',
        name: 'Chocolate Lava Cake',
        category: 'Dessert',
        difficulty: 'Medium',
        cookTime: 35,
        favorite: false,
      ),
    ];

    test('filter by Category works as expected', () {
      const criteria = RecipeFilterCriteria(category: 'Dinner');
      final result = criteria.apply(testDataset);
      expect(result.length, 1);
      expect(result.first.name, 'Beef Stew');
    });

    test('filter by Difficulty works as expected', () {
      const criteria = RecipeFilterCriteria(difficulty: 'Easy');
      final result = criteria.apply(testDataset);
      expect(result.length, 2);
      expect(result.map((r) => r.name), containsAll(['Pancakes', 'Chicken Salad']));
    });

    test('filter by Favorites Only works as expected', () {
      const criteria = RecipeFilterCriteria(onlyFavorites: true);
      final result = criteria.apply(testDataset);
      expect(result.length, 2);
      expect(result.every((r) => r.favorite), isTrue);
    });

    test('search query matches both name and notes', () {
      const nameQuery = RecipeFilterCriteria(searchQuery: 'cake');
      final nameMatches = nameQuery.apply(testDataset);
      expect(nameMatches.length, 2); // Pancakes, Chocolate Lava Cake

      const notesQuery = RecipeFilterCriteria(searchQuery: 'tender');
      final noteMatches = notesQuery.apply(testDataset);
      expect(noteMatches.length, 1);
      expect(noteMatches.first.name, 'Beef Stew');
    });
  });

  group('4. RecipeStatistics Aggregation', () {
    test('RecipeStatistics.compute calculates totals accurately', () {
      final dataset = [
        const Recipe(
          id: '1',
          userId: 'u1',
          name: 'Dish A',
          category: 'Breakfast',
          difficulty: 'Easy',
          cookTime: 10,
          favorite: true,
        ),
        const Recipe(
          id: '2',
          userId: 'u1',
          name: 'Dish B',
          category: 'Breakfast',
          difficulty: 'Medium',
          cookTime: 20,
          favorite: false,
        ),
        const Recipe(
          id: '3',
          userId: 'u1',
          name: 'Dish C',
          category: 'Dinner',
          difficulty: 'Hard',
          cookTime: 60,
          favorite: true,
        ),
      ];

      final stats = RecipeStatistics.compute(dataset);

      expect(stats.totalRecipes, 3);
      expect(stats.favoriteCount, 2);
      expect(stats.totalCookingMinutes, 90);
      expect(stats.categoryCounts['Breakfast'], 2);
      expect(stats.categoryCounts['Dinner'], 1);
      expect(stats.categoryCounts['Lunch'], 0);
      expect(stats.categoryCounts['Dessert'], 0);
    });
  });
}

