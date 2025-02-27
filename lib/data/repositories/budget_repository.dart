import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/budget.dart';
import '../data_sources/local/database_helper.dart';
import '../../core/error/exceptions.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  // Table name
  static const String tableName = 'budgets';

  // Stream controllers for reactive programming
  final _budgetStreamController = StreamController<List<Budget>>.broadcast();

  Stream<List<Budget>> get budgetsStream => _budgetStreamController.stream;

  BudgetRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  // Get all budgets
  Future<List<Budget>> getAllBudgets() async {
    try {
      final rows = await _dbHelper.queryAllRows(tableName);
      final budgets = rows.map((row) => Budget.fromMap(row)).toList();
      _budgetStreamController.add(budgets);
      return budgets;
    } catch (e) {
      throw DatabaseException('Failed to fetch budgets: ${e.toString()}');
    }
  }

  Future<Map<String, double>> getCategorySpending() async {
    // You'll need to implement this by querying expenses by category
    try {
      // Example implementation:
      final Map<String, double> categorySpending = {};
      final budgets = await getActiveBudgets();

      // For each active budget, calculate the spending
      for (var budget in budgets) {
        // You'll need to get expenses for the budget's category and time period
        // This is pseudo-code - adjust based on your actual implementation
        // final expenses = await _expenseRepository.getExpensesByCategory(budget.category);
        // final totalSpent = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
        // categorySpending[budget.category] = totalSpent;

        // For now, just set a placeholder value
        categorySpending[budget.category] = 0.0;
      }

      return categorySpending;
    } catch (e) {
      throw DatabaseException('Failed to get category spending: ${e.toString()}');
    }
  }

  // Get active budgets
  Future<List<Budget>> getActiveBudgets() async {
    try {
      final rows = await _dbHelper.queryWithCondition(
          tableName,
          'isActive = ?',
          [1]
      );
      return rows.map((row) => Budget.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch active budgets: ${e.toString()}');
    }
  }

  // Get current budget (assumes a single current/main budget)
  Future<Budget?> getCurrentBudget() async {
    try {
      // First try to get the main budget if it exists
      final rows = await _dbHelper.queryWithCondition(
          tableName,
          'isActive = ? AND isMain = ?',
          [1, 1]
      );

      // If there's a main budget, return it
      if (rows.isNotEmpty) {
        return Budget.fromMap(rows.first);
      }

      // Otherwise, try to get any active budget (first one)
      final activeRows = await _dbHelper.queryWithCondition(
          tableName,
          'isActive = ?',
          [1]
      );

      if (activeRows.isEmpty) return null;

      // Return the first active budget
      return Budget.fromMap(activeRows.first);
    } catch (e) {
      throw DatabaseException('Failed to fetch current budget: ${e.toString()}');
    }
  }

  // Get budget by category
  Future<Budget?> getBudgetByCategory(String category) async {
    try {
      final rows = await _dbHelper.queryWithCondition(
          tableName,
          'category = ? AND isActive = ?',
          [category, 1]
      );

      if (rows.isEmpty) return null;
      return Budget.fromMap(rows.first);
    } catch (e) {
      throw DatabaseException('Failed to fetch budget by category: ${e.toString()}');
    }
  }

  // Add new budget
  Future<Budget> addBudget(Budget budget) async {
    try {
      // Check if budget for this category already exists
      final existingBudget = await getBudgetByCategory(budget.category);

      if (existingBudget != null) {
        // Deactivate existing budget
        await updateBudget(existingBudget.copyWith(isActive: false));
      }

      final newBudget = budget.copyWith(id: _uuid.v4());
      await _dbHelper.insert(tableName, newBudget.toMap());
      await _refreshBudgets();
      return newBudget;
    } catch (e) {
      throw DatabaseException('Failed to add budget: ${e.toString()}');
    }
  }

  // Update existing budget
  Future<Budget> updateBudget(Budget budget) async {
    try {
      if (budget.id == null) {
        throw ValidationException('Budget ID cannot be null for update operation');
      }

      await _dbHelper.update(tableName, budget.toMap(), 'id');
      await _refreshBudgets();
      return budget;
    } catch (e) {
      throw DatabaseException('Failed to update budget: ${e.toString()}');
    }
  }

  // Delete budget
  Future<bool> deleteBudget(String id) async {
    try {
      final rowsAffected = await _dbHelper.delete(tableName, 'id', id);
      await _refreshBudgets();
      return rowsAffected > 0;
    } catch (e) {
      throw DatabaseException('Failed to delete budget: ${e.toString()}');
    }
  }

  // Get total budget amount for current period
  Future<double> getTotalBudgetAmount() async {
    try {
      final activeBudgets = await getActiveBudgets();
      return activeBudgets.fold<double>(0.0, (double sum, budget) => sum + budget.amount);
    } catch (e) {
      throw DatabaseException('Failed to calculate total budget: ${e.toString()}');
    }
  }

  // Check if budget limit is exceeded for a category
  Future<bool> isBudgetExceeded(String category, double currentAmount) async {
    try {
      final budget = await getBudgetByCategory(category);
      if (budget == null) return false;

      return currentAmount > budget.amount;
    } catch (e) {
      throw DatabaseException('Failed to check budget limit: ${e.toString()}');
    }
  }

  // Get budget usage percentage for a category
  Future<double> getBudgetUsagePercentage(String category, double currentAmount) async {
    try {
      final budget = await getBudgetByCategory(category);
      if (budget == null) return 0.0;

      double percentage = (currentAmount / budget.amount) * 100;
      return percentage > 100 ? 100 : percentage;
    } catch (e) {
      throw DatabaseException('Failed to calculate budget usage: ${e.toString()}');
    }
  }

  // Helper method to refresh budgets stream
  Future<void> _refreshBudgets() async {
    final budgets = await getAllBudgets();
    _budgetStreamController.add(budgets);
  }

  // Dispose resources
  void dispose() {
    _budgetStreamController.close();
  }
}