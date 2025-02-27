import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/budget.dart';
import '../../../../data/models/categoryBudget.dart';
import '../../../../data/models/category.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/data_sources/local/database_helper.dart';

class AddBudgetDialog extends StatefulWidget {
  final Budget? budget;

  // Made categories optional since we'll load them if not provided
  final List<Category>? categories;

  const AddBudgetDialog({
    Key? key,
    this.budget,
    this.categories,
  }) : super(key: key);

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _totalController;
  final Map<String, TextEditingController> _categoryControllers = {};
  double _allocated = 0;
  double _total = 0;
  String? _selectedCategory;

  // Add repository and loading state
  late CategoryRepository _categoryRepository;
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController(
      text: widget.budget?.amount.toString() ?? '',
    );

    // Initialize repository
    _categoryRepository = CategoryRepository(DatabaseHelper());

    // If categories were provided, use them, otherwise load them
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      _categories = widget.categories!;
      _initializeControllers();
      _isLoading = false;
    } else {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getVisibleCategories();

      setState(() {
        _categories = categories;
        _initializeControllers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error if we're mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: ${e.toString()}')),
        );
      }
    }
  }

  void _initializeControllers() {
    // Initialize category controllers
    for (final category in _categories) {
      final categoryBudget = widget.budget?.categoryBudgets.firstWhere(
            (cb) => cb.categoryId == category.id,
        orElse: () => CategoryBudget(
          categoryId: category.id,
          amount: 0,
        ),
      );

      _categoryControllers[category.id] = TextEditingController(
        text: categoryBudget?.amount.toString() ?? '',
      );
    }

    // Set the initial selected category
    if (_categories.isNotEmpty) {
      // If editing an existing budget, try to use its category
      if (widget.budget != null) {
        _selectedCategory = widget.budget!.category;
      } else {
        _selectedCategory = _categories.first.id;
      }
    }

    _calculateTotals();
  }

  @override
  void dispose() {
    _totalController.dispose();
    for (final controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateTotals() {
    double allocated = 0;

    for (final controller in _categoryControllers.values) {
      if (controller.text.isNotEmpty) {
        allocated += double.tryParse(controller.text) ?? 0;
      }
    }

    setState(() {
      _allocated = allocated;
      _total = double.tryParse(_totalController.text) ?? 0;
    });
  }

  Budget _createBudget() {
    List<CategoryBudget> categoryBudgets = [];

    for (final entry in _categoryControllers.entries) {
      final amount = double.tryParse(entry.value.text) ?? 0;
      if (amount > 0) {
        categoryBudgets.add(CategoryBudget(
          categoryId: entry.key,
          amount: amount,
        ));
      }
    }

    return Budget(
      id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory ?? _categories.first.id, // Fallback to first category if somehow none selected
      amount: double.parse(_totalController.text),
      startDate: widget.budget?.startDate ?? DateTime.now(),
      endDate: widget.budget?.endDate ?? DateTime.now().add(const Duration(days: 30)),
      categoryBudgets: categoryBudgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.budget == null ? 'Create Budget' : 'Edit Budget'),
      content: _isLoading ?
      // Show loading indicator while categories are being loaded
      const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ) :
      // Show form once categories are loaded
      Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Total Budget Input
              TextFormField(
                controller: _totalController,
                decoration: const InputDecoration(
                  labelText: 'Total Budget',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total budget amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  _calculateTotals();
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Category Allocations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Only show dropdown if we have categories
              if (_categories.isNotEmpty) ...[
                // Category Selection Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
              ] else ...[
                // Show a message if no categories are available
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No categories available. Please create categories first.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(),

              // Summary Section
              ListTile(
                title: const Text('Total Allocated'),
                trailing: Text(
                  CurrencyFormatter.format(_allocated),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _allocated > _total ? Colors.red : Colors.black,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Total Budget'),
                trailing: Text(
                  CurrencyFormatter.format(_total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Unallocated'),
                trailing: Text(
                  CurrencyFormatter.format(_total - _allocated),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _allocated > _total ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        // Disable the Create/Update button if loading or no categories
        ElevatedButton(
          onPressed: _isLoading || _categories.isEmpty ? null : () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_createBudget());
            }
          },
          child: Text(widget.budget == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}