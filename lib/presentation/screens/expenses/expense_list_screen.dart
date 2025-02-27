import 'package:flutter/material.dart';
import '../../../config/routes.dart'; // Updated import
import '../../../data/models/expense.dart';
import '../../../data/models/category.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/data_sources/local/database_helper.dart'; // Import DatabaseHelper
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/charts/expense_chart.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late ExpenseRepository _expenseRepository;
  late CategoryRepository _categoryRepository;
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Initialize DatabaseHelper
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _filterOption = 'all'; // all, week, month

  @override
  void initState() {
    super.initState();
    _expenseRepository = ExpenseRepository();
    _categoryRepository = CategoryRepository(_databaseHelper); // Pass DatabaseHelper
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _loadCategories();
      await _loadExpenses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getAllCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadExpenses() async {
    try {
      List<Expense> expenses;
      switch (_filterOption) {
        case 'week':
          expenses = await _expenseRepository.getExpensesForWeek();
          break;
        case 'month':
          expenses = await _expenseRepository.getExpensesForMonth();
          break;
        case 'all':
        default:
          expenses = await _expenseRepository.getAllExpenses();
          break;
      }

      setState(() {
        _expenses = expenses;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load expenses: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    try {
      // Handle potential null ID by providing a default empty string
      // (Better solution would be to fix the Expense model to ensure ID is non-nullable)
      await _expenseRepository.deleteExpense(expense.id ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted')),
      );
      _loadExpenses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete expense: ${e.toString()}')),
      );
    }
  }

  double _calculateTotal() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Helper to get Category object from categoryId
  Category _getCategoryFromId(String categoryId) {
    try {
      return _categories.firstWhere(
            (category) => category.id == categoryId,
        orElse: () => Category(
          id: categoryId,
          name: 'Unknown',
          color: Colors.grey,
          icon: Icons.help_outline,
        ),
      );
    } catch (e) {
      return Category(
        id: categoryId,
        name: 'Unknown',
        color: Colors.grey,
        icon: Icons.help_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterOption = value;
              });
              _loadExpenses();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Expenses'),
              ),
              const PopupMenuItem(
                value: 'week',
                child: Text('This Week'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('This Month'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            // Summary and Chart
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        CurrencyFormatter.format(_calculateTotal()),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: ExpenseChart(
                      expenses: _expenses,
                      categories: _categories,
                      startDate: DateTime.now().subtract(const Duration(days: 30)),
                      endDate: DateTime.now(),
                      chartType: ChartType.pie,
                    ),
                  ),
                ],
              ),
            ),

            // Expense List
            Expanded(
              child: _expenses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.addExpense)
                            .then((_) => _loadExpenses());
                      },
                      child: const Text('Add Expense'),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                itemCount: _expenses.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final expense = _expenses[index];
                  // Get the category object for this expense
                  final category = _getCategoryFromId(expense.category);

                  return Dismissible(
                    key: Key(expense.id ?? index.toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Expense'),
                          content: const Text('Are you sure you want to delete this expense?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      _deleteExpense(expense);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color,
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(expense.title),
                      subtitle: Text(
                        '${category.name} • ${DateFormatter.toShortDate(expense.date)}',
                      ),
                      trailing: Text(
                        CurrencyFormatter.format(expense.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addExpense,
                          arguments: expense,
                        ).then((_) => _loadExpenses());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addExpense)
              .then((_) => _loadExpenses());
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }
}