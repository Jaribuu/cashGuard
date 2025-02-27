import 'package:flutter/material.dart';
import '../../../data/models/category.dart';
import '../../../data/models/budget.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/data_sources/local/database_helper.dart';
import '../../../config/routes.dart';
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
  bool _isLoading = true;
  String? _errorMessage;

  // Initialize DatabaseHelper
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Declare repositories
  late final CategoryRepository _categoryRepository;
  late final BudgetRepository _budgetRepository;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
  }

  // Initialize repositories
  Future<void> _initializeRepositories() async {
    try {
      // Initialize both repositories with the same database helper instance
      _categoryRepository = CategoryRepository(_databaseHelper);
      _budgetRepository = BudgetRepository();

      // First ensure the database is ready
      await _databaseHelper.database;

      // Initialize default categories if needed
      await _categoryRepository.initializeDefaultCategories();

      // Then load the data
      await _loadData();
    } catch (e) {
      print("Repository initialization error: $e");
      setState(() {
        _errorMessage = "Failed to initialize app: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      print("Loading categories started");
      final categories = await _categoryRepository.getAllCategories();
      print("Categories loaded: ${categories.length}");

      Budget? currentBudget;
      try {
        currentBudget = await _budgetRepository.getCurrentBudget();
      } catch (budgetError) {
        print("Error loading budget: $budgetError");
        // Continue even if budget fails to load
      }

      if (mounted) {
        setState(() {
          _categories = categories;
          _currentBudget = currentBudget;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Error loading data: $e";
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CashGuard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addExpense);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                                  _currentBudget!.category ?? '': 0
                                },
                                chartType: BudgetChartType.detailed,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Amount: \$${_currentBudget!.amount}'),
                                  Text('Remaining: \$${_currentBudget!.amount}'),
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
                    _buildRecentExpenses(),

                    // Category section
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to category management screen
                          },
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Display categories in a grid
                    _buildCategoryGrid(),

                    // Add some space at the bottom
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build the category grid
  Widget _buildCategoryGrid() {
    if (_categories.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.category_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No categories found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Default categories should appear here. Try restarting the app or check for errors.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _categoryRepository.initializeDefaultCategories().then((_) {
                    _loadData();
                  });
                },
                child: const Text('Initialize Default Categories'),
              ),
            ],
          ),
        ),
      );
    }

    // Only show visible categories
    final visibleCategories = _categories.where((c) => c.isVisible).toList();

    if (visibleCategories.isEmpty) {
      return const Center(
        child: Text('No visible categories. Check your settings.'),
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
      itemCount: visibleCategories.length,
      itemBuilder: (context, index) {
        final category = visibleCategories[index];

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: category.color.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build recent expenses
  Widget _buildRecentExpenses() {
    // Placeholder for recent expenses
    // You'll want to replace this with actual expense data
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'No recent expenses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('Track your spending by adding expenses'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addExpense);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}