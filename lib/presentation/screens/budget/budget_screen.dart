import 'package:flutter/material.dart';
import '../../../data/models/budget.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/data_sources/local/database_helper.dart'; // Import DatabaseHelper
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/charts/budget_progress_chart.dart';
import './widgets/budget_category_tile.dart';
import './widgets/add_budget_dialog.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late BudgetRepository _budgetRepository;
  late ExpenseRepository _expenseRepository;
  late CategoryRepository _categoryRepository;
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Initialize DatabaseHelper

  Budget? _currentBudget;
  List<Category> _categories = [];
  Map<String, double> _categorySpending = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _budgetRepository = BudgetRepository();
    _expenseRepository = ExpenseRepository();
    _categoryRepository = CategoryRepository(_databaseHelper); // Pass DatabaseHelper
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final budget = await _budgetRepository.getCurrentBudget();
      final categories = await _categoryRepository.getAllCategories();

      // Calculate category spending manually if not available
      final spending = <String, double>{};
      // You'll need to calculate spending from expenses or implement this method

      setState(() {
        _currentBudget = budget;
        _categories = categories;
        _categorySpending = spending;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addOrEditBudget() async {
    final result = await showDialog<Budget>(
      context: context,
      builder: (context) => AddBudgetDialog(
        budget: _currentBudget,
        categories: _categories,
      ),
    );

    if (result != null) {
      try {
        if (_currentBudget == null) {
          await _budgetRepository.addBudget(result);
        } else {
          await _budgetRepository.updateBudget(result);
        }
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save budget: ${e.toString()}')),
        );
      }
    }
  }

  double _calculateTotalSpent() {
    return _categorySpending.values.fold(0, (sum, amount) => sum + amount);
  }

  double _calculateRemainingBudget() {
    if (_currentBudget == null) return 0;
    return _currentBudget!.amount - _calculateTotalSpent();
  }

  double _calculatePercentUsed() {
    if (_currentBudget == null || _currentBudget!.amount == 0) return 0;
    return (_calculateTotalSpent() / _currentBudget!.amount) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: _currentBudget == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No budget set',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addOrEditBudget,
                child: const Text('Create Budget'),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monthly Budget',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _addOrEditBudget,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(_currentBudget!.amount),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem(
                            context,
                            'Spent',
                            _calculateTotalSpent(),
                            Colors.red.shade100,
                          ),
                          _buildSummaryItem(
                            context,
                            'Remaining',
                            _calculateRemainingBudget(),
                            Colors.green.shade100,
                          ),
                          _buildSummaryItem(
                            context,
                            'Used',
                            _calculatePercentUsed(),
                            Colors.blue.shade100,
                            isPercentage: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Budget Progress Chart
              Text(
                'Budget Progress',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 180,
                child: BudgetProgressChart(
                  budgets: [_currentBudget!], // Pass the current budget as a list
                  categories: _categories, // Pass the list of categories
                  expensesByCategory: _categorySpending, // Pass the expenses map
                ),
              ),

              const SizedBox(height: 24),
              // Category Breakdown
              Text(
                'Category Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...(_currentBudget?.categoryBudgets ?? []).map((categoryBudget) {
                final category = _categories.firstWhere(
                      (c) => c.id == categoryBudget.categoryId,
                  orElse: () => Category(
                    id: categoryBudget.categoryId,
                    name: 'Unknown',
                    color: Colors.grey, // Provide a default color
                    icon: Icons.category, // Provide a default icon
                  ),
                );
                final spent = _categorySpending[category.id] ?? 0;

                return BudgetCategoryTile(
                  category: category,
                  allocated: categoryBudget.amount,
                  spent: spent,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context,
      String label,
      double value,
      Color color, {
        bool isPercentage = false,
      }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            isPercentage
                ? '${value.toStringAsFixed(1)}%'
                : CurrencyFormatter.format(value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}