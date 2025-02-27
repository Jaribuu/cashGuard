import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/savings_goal.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class AddSavingsGoalDialog extends StatefulWidget {
  final SavingsGoal? goal;

  const AddSavingsGoalDialog({Key? key, this.goal}) : super(key: key);

  @override
  State<AddSavingsGoalDialog> createState() => _AddSavingsGoalDialogState();
}

class _AddSavingsGoalDialogState extends State<AddSavingsGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _notesController;
  late DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _nameController = TextEditingController(text: goal?.title ?? ''); // Use `title`
    _targetAmountController = TextEditingController(
      text: goal?.targetAmount.toString() ?? '',
    );
    _currentAmountController = TextEditingController(
      text: goal?.currentAmount.toString() ?? '0',
    );
    _notesController = TextEditingController(text: goal?.notes ?? '');
    _targetDate = goal?.targetDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text.trim();
      final double targetAmount = double.parse(_targetAmountController.text);
      final double currentAmount = double.parse(_currentAmountController.text);
      final String? notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      final savingsGoal = SavingsGoal(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: name, // Use `title` instead of `name`
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        createdDate: widget.goal?.createdDate ?? DateTime.now(), // Add `createdDate`
        targetDate: _targetDate,
        notes: notes,
      );
      Navigator.of(context).pop(savingsGoal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Savings Goal' : 'Add New Savings Goal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g., New Car, Vacation, Emergency Fund',
                  prefixIcon: Icon(Icons.savings),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name for your goal';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Target amount field
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target amount';
                  }

                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid positive amount';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Current amount field (shown only when editing or if needed)
              if (isEditing) ...[
                TextFormField(
                  controller: _currentAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Current Amount',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the current amount';
                    }

                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Amount cannot be negative';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Target date field
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Target Date'),
                subtitle: Text(
                  DateFormatter.toShortDate(_targetDate), // Use `toShortDate`
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional information about this goal',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}