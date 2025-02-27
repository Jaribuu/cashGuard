import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../data_sources/local/database_helper.dart';
import '../../core/error/exceptions.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper;
  final String _tableName = 'categories';
  final Uuid _uuid = Uuid();

  CategoryRepository(this._dbHelper);

  // Default categories that will be created when the app is first installed
  final List<Category> _defaultCategories = [
    Category(
      id: 'food',
      name: 'Food & Dining',
      color: Colors.orange,
      icon: Icons.restaurant,
      isDefault: true,
    ),
    Category(
      id: 'transport',
      name: 'Transportation',
      color: Colors.blue,
      icon: Icons.directions_car,
      isDefault: true,
    ),
    Category(
      id: 'housing',
      name: 'Housing',
      color: Colors.green,
      icon: Icons.home,
      isDefault: true,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      color: Colors.purple,
      icon: Icons.movie,
      isDefault: true,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      color: Colors.pink,
      icon: Icons.shopping_bag,
      isDefault: true,
    ),
    Category(
      id: 'utilities',
      name: 'Utilities',
      color: Colors.teal,
      icon: Icons.power,
      isDefault: true,
    ),
  ];

  // Initialize default categories if none exist
  Future<void> initializeDefaultCategories() async {
    try {
      final categories = await getAllCategories();
      if (categories.isEmpty) {
        for (var category in _defaultCategories) {
          await addCategory(
            name: category.name,
            color: category.color,
            icon: category.icon,
            isDefault: true,
            isVisible: true,
            customId: category.id,
          );
        }
      }
    } catch (e) {
      throw RepositoryException('Failed to initialize default categories: ${e.toString()}');
    }
  }

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      final maps = await _dbHelper.queryAllRows(_tableName);
      return List.generate(maps.length, (i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      throw RepositoryException('Failed to get categories: ${e.toString()}');
    }
  }

  // Get visible categories only
  Future<List<Category>> getVisibleCategories() async {
    try {
      final maps = await _dbHelper.queryWithCondition(
        _tableName,
        'isVisible = ?',
        [1],
      );

      return List.generate(maps.length, (i) {
        return Category.fromMap(maps[i]);
      });
    } catch (e) {
      throw RepositoryException('Failed to get visible categories: ${e.toString()}');
    }
  }

  // Get a single category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final maps = await _dbHelper.queryWithCondition(
        _tableName,
        'id = ?',
        [id],
      );

      if (maps.isNotEmpty) {
        return Category.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw RepositoryException('Failed to get category by ID: ${e.toString()}');
    }
  }

  // Add a new category
  Future<Category> addCategory({
    required String name,
    required Color color,
    required IconData icon,
    bool isDefault = false,
    bool isVisible = true,
    String? customId,
  }) async {
    try {
      final category = Category(
        id: customId ?? _uuid.v4(),
        name: name,
        color: color,
        icon: icon,
        isDefault: isDefault,
        isVisible: isVisible,
      );

      await _dbHelper.insert(_tableName, category.toMap());
      return category;
    } catch (e) {
      throw RepositoryException('Failed to add category: ${e.toString()}');
    }
  }

  // Update an existing category
  Future<int> updateCategory(Category category) async {
    try {
      return await _dbHelper.update(_tableName, category.toMap(), 'id');
    } catch (e) {
      throw RepositoryException('Failed to update category: ${e.toString()}');
    }
  }

  // Delete a category by ID
  Future<int> deleteCategory(String id) async {
    try {
      // First check if it's a default category
      final category = await getCategoryById(id);
      if (category != null && category.isDefault) {
        // Don't delete default categories, just hide them
        return await updateCategory(
            category.copyWith(isVisible: false)
        );
      }

      return await _dbHelper.delete(_tableName, 'id', id);
    } catch (e) {
      throw RepositoryException('Failed to delete category: ${e.toString()}');
    }
  }

  // Toggle category visibility
  Future<int> toggleCategoryVisibility(String id) async {
    try {
      final category = await getCategoryById(id);
      if (category == null) return 0;

      return await updateCategory(
          category.copyWith(isVisible: !category.isVisible)
      );
    } catch (e) {
      throw RepositoryException('Failed to toggle category visibility: ${e.toString()}');
    }
  }

  // Reset to default categories
  Future<void> resetToDefaults() async {
    try {
      // Delete all non-default categories
      await _dbHelper.rawQuery(
          'DELETE FROM $_tableName WHERE isDefault = 0'
      );

      // Make all default categories visible
      await _dbHelper.rawQuery(
          'UPDATE $_tableName SET isVisible = 1 WHERE isDefault = 1'
      );
    } catch (e) {
      throw RepositoryException('Failed to reset categories: ${e.toString()}');
    }
  }

  // Get categories with expense counts
  Future<List<Map<String, dynamic>>> getCategoriesWithExpenseCounts() async {
    try {
      return await _dbHelper.rawQuery('''
        SELECT c.id, c.name, c.color, c.iconCodePoint, c.iconFontFamily, 
               c.iconFontPackage, c.isDefault, c.isVisible, 
               COUNT(e.id) as expenseCount, SUM(e.amount) as totalAmount
        FROM categories c
        LEFT JOIN expenses e ON c.id = e.category
        WHERE c.isVisible = 1
        GROUP BY c.id
        ORDER BY c.name
      ''');
    } catch (e) {
      throw RepositoryException('Failed to get categories with expense counts: ${e.toString()}');
    }
  }

  // Check if a category is in use by any expenses
  Future<bool> isCategoryInUse(String categoryId) async {
    try {
      final result = await _dbHelper.rawQuery(
          'SELECT COUNT(*) as count FROM expenses WHERE category = ?',
          [categoryId]
      );

      return result.first['count'] > 0;
    } catch (e) {
      throw RepositoryException('Failed to check if category is in use: ${e.toString()}');
    }
  }
}

// Custom exception for repository
class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);

  @override
  String toString() => message;
}