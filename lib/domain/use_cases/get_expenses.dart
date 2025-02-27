import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';

class GetExpenses {
  final ExpenseRepository _repository;

  GetExpenses(this._repository);

  // Get all expenses
  Future<List<Expense>> getAllExpenses() {
    return _repository.getAllExpenses();
  }

  // Get expenses for current month
  Future<List<Expense>> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _repository.getExpensesByDateRange(startOfMonth, endOfMonth);
  }

  // Get expenses for previous month
  Future<List<Expense>> getPreviousMonthExpenses() {
    final now = DateTime.now();
    final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPreviousMonth = DateTime(now.year, now.month, 0);

    return _repository.getExpensesByDateRange(startOfPreviousMonth, endOfPreviousMonth);
  }

  // Get expenses for a specific period
  Future<List<Expense>> getExpensesForPeriod(DateTime start, DateTime end) {
    return _repository.getExpensesByDateRange(start, end);
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String category) {
    return _repository.getExpensesByCategory(category);
  }

  // Get expenses by category for current month
  Future<List<Expense>> getCurrentMonthExpensesByCategory(String category) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final expenses = await _repository.getExpensesByDateRange(
        startOfMonth, endOfMonth
    );

    return expenses.where((expense) => expense.category == category).toList();
  }

  // Get total expenses for current month
  Future<double> getCurrentMonthTotal() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _repository.getTotalExpensesForPeriod(startOfMonth, endOfMonth);
  }

  // Get category distribution for current month
  Future<Map<String, double>> getCurrentMonthCategoryDistribution() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _repository.getExpensesTotalsByCategory(startOfMonth, endOfMonth);
  }

  // Get month-over-month spending comparison
  Future<Map<String, double>> getMonthOverMonthComparison() async {
    // Current month
    final now = DateTime.now();
    final startOfCurrentMonth = DateTime(now.year, now.month, 1);
    final endOfCurrentMonth = DateTime(now.year, now.month + 1, 0);

    // Previous month
    final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPreviousMonth = DateTime(now.year, now.month, 0);

    final currentMonthTotal = await _repository.getTotalExpensesForPeriod(
        startOfCurrentMonth, endOfCurrentMonth
    );

    final previousMonthTotal = await _repository.getTotalExpensesForPeriod(
        startOfPreviousMonth, endOfPreviousMonth
    );

    return {
      'currentMonth': currentMonthTotal,
      'previousMonth': previousMonthTotal,
    };
  }

  // Stream of expenses
  Stream<List<Expense>> watchAllExpenses() {
    // Initial load to populate the stream
    _repository.getAllExpenses();
    return _repository.expensesStream;
  }
}