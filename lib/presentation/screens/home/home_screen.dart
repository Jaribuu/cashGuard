import 'package:flutter/material.dart';
import '../../../data/models/category.dart'; // Import your actual Category model
import '../../../data/models/budget.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/data_sources/local/database_helper.dart'; // Import DatabaseHelper
import '../../../config/routes.dart'; // Import Routes
import '../../widgets/charts/budget_progress_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  Budget? _currentBudget;
  int _selectedIndex = 0;

  // Initialize DatabaseHelper
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Declare repositories
  late final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository = BudgetRepository();

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
  }

  // Initialize repositories
  void _initializeRepositories() {
    _categoryRepository = CategoryRepository(_databaseHelper); // Pass DatabaseHelper
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await _categoryRepository.getAllCategories();
      final currentBudget = await _budgetRepository.getCurrentBudget();

      setState(() {
        _categories = categories;
        _currentBudget = currentBudget;
      });
    } catch (e) {
      // Handle error, maybe show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CashGuard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Budget overview card
              if (_currentBudget != null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Budget',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        // Budget progress chart
                        BudgetProgressChart(
                          budgets: [_currentBudget!],
                          categories: _categories,
                          expensesByCategory: {
                            _currentBudget!.category ?? '': 0 // Fixed: changed categoryId to category
                          },
                          chartType: BudgetChartType.detailed,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Amount: \$${_currentBudget!.amount}'),
                            Text('Remaining: \$${_currentBudget!.amount}'), // Calculate remaining
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent expenses section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.expenseList);
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // List recent expenses here

              // Category section
              const SizedBox(height: 24),
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              // Display categories in a grid
              _buildCategoryGrid(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addExpense);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
            // Home - already here
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.expenseList);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.budget);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.savings);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Savings',
          ),
        ],
      ),
    );
  }

  // Helper method to build the category grid
  Widget _buildCategoryGrid() {
    if (_categories.isEmpty) {
      return const Center(
        child: Text('No categories found. Add some to get started!'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        // Only show visible categories
        if (!category.isVisible) return const SizedBox.shrink();

        return InkWell(
          onTap: () {
            // Navigate to category details or filtered expenses
          },
          child: Card(
            color: category.color.withOpacity(0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  color: category.color,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: category.color.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}