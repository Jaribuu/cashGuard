import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/category.dart'; // Ensure this import exists
import '../data_sources/local/database_helper.dart';
import '../../core/error/exceptions.dart';

class ExpenseRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  // Table names
  static const String expenseTableName = 'expenses';
  static const String categoryTableName = 'categories';

  // Stream controllers for reactive programming
  final _expenseStreamController = StreamController<List<Expense>>.broadcast();

  Stream<List<Expense>> get expensesStream => _expenseStreamController.stream;

  ExpenseRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    try {
      final rows = await _dbHelper.queryAllRows(expenseTableName);
      final expenses = rows.map((row) => Expense.fromMap(row)).toList();
      _expenseStreamController.add(expenses);
      return expenses;
    } catch (e) {
      throw DatabaseException('Failed to fetch expenses: ${e.toString()}');
    }
  }

  // Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final rows = await _dbHelper.queryAllRows(categoryTableName);
      return rows.map((row) => Category.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch categories: ${e.toString()}');
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final rows = await _dbHelper.queryWithCondition(
        categoryTableName,
        'id = ?',
        [id],
      );
      if (rows.isEmpty) return null;
      return Category.fromMap(rows.first);
    } catch (e) {
      throw DatabaseException('Failed to fetch category by id: ${e.toString()}');
    }
  }

  // Get expenses for current week
  Future<List<Expense>> getExpensesForWeek() async {
    try {
      final now = DateTime.now();
      // Find the start of the week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      // End of the week (Sunday)
      final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      return getExpensesByDateRange(start, end);
    } catch (e) {
      throw DatabaseException('Failed to fetch expenses for week: ${e.toString()}');
    }
  }

  // Get expenses for current month
  Future<List<Expense>> getExpensesForMonth() async {
    try {
      final now = DateTime.now();
      // First day of current month
      final start = DateTime(now.year, now.month, 1);
      // Last day of current month
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      return getExpensesByDateRange(start, end);
    } catch (e) {
      throw DatabaseException('Failed to fetch expenses for month: ${e.toString()}');
    }
  }

  // Get recent expenses with an optional limit
  Future<List<Expense>> getRecentExpenses({int limit = 5}) async {
    try {
      final rows = await _dbHelper.queryWithLimit(
        expenseTableName,
        orderBy: 'date DESC',
        limit: limit,
      );
      return rows.map((row) => Expense.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch recent expenses: ${e.toString()}');
    }
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final rows = await _dbHelper.queryWithCondition(
        expenseTableName,
        'date >= ? AND date <= ?',
        [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      );
      return rows.map((row) => Expense.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch expenses by date range: ${e.toString()}');
    }
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) async {
    try {
      final rows = await _dbHelper.queryWithCondition(
        expenseTableName,
        'category = ?',
        [category],
      );
      return rows.map((row) => Expense.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch expenses by category: ${e.toString()}');
    }
  }

  // Add new expense
  Future<Expense> addExpense(Expense expense) async {
    try {
      final newExpense = expense.copyWith(id: _uuid.v4());
      await _dbHelper.insert(expenseTableName, newExpense.toMap());
      await _refreshExpenses();
      return newExpense;
    } catch (e) {
      throw DatabaseException('Failed to add expense: ${e.toString()}');
    }
  }

  // Update existing expense
  Future<Expense> updateExpense(Expense expense) async {
    try {
      if (expense.id == null) {
        throw ValidationException('Expense ID cannot be null for update operation');
      }

      await _dbHelper.update(expenseTableName, expense.toMap(), 'id');
      await _refreshExpenses();
      return expense;
    } catch (e) {
      throw DatabaseException('Failed to update expense: ${e.toString()}');
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String id) async {
    try {
      final rowsAffected = await _dbHelper.delete(expenseTableName, 'id', id);
      await _refreshExpenses();
      return rowsAffected > 0;
    } catch (e) {
      throw DatabaseException('Failed to delete expense: ${e.toString()}');
    }
  }

  // Get total expenses for a period
  Future<double> getTotalExpensesForPeriod(DateTime start, DateTime end) async {
    try {
      final expenses = await getExpensesByDateRange(start, end);
      return expenses.fold<double>(0.0, (double sum, Expense expense) => sum + expense.amount);
    } catch (e) {
      throw DatabaseException('Failed to calculate total expenses: ${e.toString()}');
    }
  }

  // Get expenses by month
  Future<Map<String, double>> getMonthlyExpenseTotals(int year) async {
    try {
      final Map<String, double> monthlyTotals = {};

      for (int month = 1; month <= 12; month++) {
        final start = DateTime(year, month, 1);
        final end = DateTime(year, month + 1, 0); // Last day of month

        final expenses = await getExpensesByDateRange(start, end);
        final total = expenses.fold<double>(0.0, (double sum, Expense expense) => sum + expense.amount);

        // Month name (e.g., "Jan", "Feb")
        final monthName = _getMonthName(month);
        monthlyTotals[monthName] = total;
      }

      return monthlyTotals;
    } catch (e) {
      throw DatabaseException('Failed to get monthly expense totals: ${e.toString()}');
    }
  }

  // Get expenses by category for a period
  Future<Map<String, double>> getExpensesTotalsByCategory(DateTime start, DateTime end) async {
    try {
      final expenses = await getExpensesByDateRange(start, end);

      final Map<String, double> categoryTotals = {};
      for (var expense in expenses) {
        final currentTotal = categoryTotals[expense.category] ?? 0.0;
        categoryTotals[expense.category] = currentTotal + expense.amount;
      }

      return categoryTotals;
    } catch (e) {
      throw DatabaseException('Failed to get expenses by category: ${e.toString()}');
    }
  }

  // Helper method to refresh expenses stream
  Future<void> _refreshExpenses() async {
    final expenses = await getAllExpenses();
    _expenseStreamController.add(expenses);
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Dispose resources
  void dispose() {
    _expenseStreamController.close();
  }
}