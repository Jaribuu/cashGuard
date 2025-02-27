import '../../data/models/budget.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/expense_repository.dart';

class CalculateBudget {
  final BudgetRepository _budgetRepository;
  final ExpenseRepository _expenseRepository;

  CalculateBudget(this._budgetRepository, this._expenseRepository);

  // Calculate budget status for all categories
  Future<Map<String, Map<String, dynamic>>> calculateBudgetStatus() async {
    // Get active budgets
    final budgets = await _budgetRepository.getActiveBudgets();

    // Get current date range
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Get category expenses
    final categoryExpenses = await _expenseRepository.getExpensesTotalsByCategory(
        startOfMonth, endOfMonth
    );

    // Calculate status for each budget
    final Map<String, Map<String, dynamic>> budgetStatus = {};

    for (var budget in budgets) {
      final spent = categoryExpenses[budget.category] ?? 0.0;
      final remaining = budget.amount - spent;
      final percentage = (spent / budget.amount) * 100;

      budgetStatus[budget.category] = {
        'budget': budget.amount,
        'spent': spent,
        'remaining': remaining,
        'percentage': percentage,
        'status': _getBudgetHealthStatus(percentage),
      };
    }

    return budgetStatus;
  }

  // Helper method to determine budget health status
  String _getBudgetHealthStatus(double percentage) {
    if (percentage < 50) {
      return 'good';
    } else if (percentage < 85) {
      return 'warning';
    } else {
      return 'danger';
    }
  }

  // Get detailed budget report with recommendations
  Future<Map<String, dynamic>> getBudgetReport() async {
    final status = await calculateBudgetStatus();

    int categoriesOverBudget = 0;
    int categoriesNearLimit = 0;
    double totalBudget = 0;
    double totalSpent = 0;

    List<String> atRiskCategories = [];

    status.forEach((category, data) {
      totalBudget += data['budget'];
      totalSpent += data['spent'];

      if (data['percentage'] >= 100) {
        categoriesOverBudget++;
      } else if (data['percentage'] >= 85) {
        categoriesNearLimit++;
        atRiskCategories.add(category);
      }
    });

    return {
      'categoryStatus': status,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'totalRemaining': totalBudget - totalSpent,
      'overallPercentage': (totalSpent / totalBudget) * 100,
      'categoriesOverBudget': categoriesOverBudget,
      'categoriesNearLimit': categoriesNearLimit,
      'atRiskCategories': atRiskCategories,
    };
  }
}