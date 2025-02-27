import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../core/error/exceptions.dart';

class AddExpense {
  final ExpenseRepository _expenseRepository;
  final BudgetRepository _budgetRepository;

  AddExpense(this._expenseRepository, this._budgetRepository);

  // Add a new expense
  Future<Expense> execute(Expense expense) async {
    return await _expenseRepository.addExpense(expense);
  }

  // Add expense and check budget
  Future<Map<String, dynamic>> executeWithBudgetCheck(Expense expense) async {
    // Add the expense
    final newExpense = await _expenseRepository.addExpense(expense);

    // Get current month expenses for this category
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final expenses = await _expenseRepository.getExpensesByDateRange(
        startOfMonth, endOfMonth
    );

    // Calculate total spent in this category this month
    final categoryExpenses = expenses
        .where((e) => e.category == expense.category)
        .fold(0.0, (sum, e) => sum + e.amount);

    // Check if there's a budget for this category
    final budget = await _budgetRepository.getBudgetByCategory(expense.category);

    if (budget == null) {
      return {
        'expense': newExpense,
        'budgetExceeded': false,
        'budgetPercentage': 0.0,
      };
    }

    // Check if budget is exceeded
    final budgetExceeded = categoryExpenses > budget.amount;

    // Calculate percentage of budget used
    final budgetPercentage = (categoryExpenses / budget.amount) * 100;

    return {
      'expense': newExpense,
      'budgetExceeded': budgetExceeded,
      'budgetPercentage': budgetPercentage > 100 ? 100.0 : budgetPercentage,
    };
  }

  // Update an existing expense
  Future<Expense> update(Expense expense) async {
    if (expense.id == null) {
      throw ValidationException('Cannot update expense without ID');
    }

    return await _expenseRepository.updateExpense(expense);
  }

  // Delete an expense
  Future<bool> delete(String id) async {
    return await _expenseRepository.deleteExpense(id);
  }
}