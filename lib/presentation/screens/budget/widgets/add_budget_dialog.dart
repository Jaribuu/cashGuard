import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/budget.dart';
import '../../../../data/models/categoryBudget.dart';
import '../../../../data/models/category.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddBudgetDialog extends StatefulWidget {
  final Budget? budget;
  final List<Category> categories;

  const AddBudgetDialog({
    Key? key,
    this.budget,
    required this.categories,
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
  String? _selectedCategory; // Define the selected category

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController(
      text: widget.budget?.amount.toString() ?? '',
    );

    // Initialize category controllers and set the selected category
    for (final category in widget.categories) {
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

    // Set the initial selected category (e.g., the first category in the list)
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first.id;
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
      category: _selectedCategory!, // Use the selected category
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
      content: Form(
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

              // Category Selection Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                items: widget.categories.map((category) {
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
              const SizedBox(height: 16),

              // Category Allocations Inputs
              ...widget.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: _categoryControllers[category.id],
                    decoration: InputDecoration(
                      labelText: category.name,
                      prefixIcon: const Icon(Icons.category),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      _calculateTotals();
                    },
                  ),
                );
              }).toList(),
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
        ElevatedButton(
          onPressed: () {
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