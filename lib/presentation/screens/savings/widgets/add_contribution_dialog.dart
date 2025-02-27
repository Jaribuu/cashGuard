// lib/presentation/screens/savings/widgets/add_contribution_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddContributionDialog extends StatefulWidget {
  final String goalName;
  final double currentAmount;
  final double targetAmount;

  const AddContributionDialog({
    Key? key,
    required this.goalName,
    required this.currentAmount,
    required this.targetAmount,
  }) : super(key: key);

  @override
  State<AddContributionDialog> createState() => _AddContributionDialogState();
}

class _AddContributionDialogState extends State<AddContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  double _remainingAmount = 0;

  @override
  void initState() {
    super.initState();
    _remainingAmount = widget.targetAmount - widget.currentAmount;
    if (_remainingAmount < 0) _remainingAmount = 0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(double.parse(_amountController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Contribution'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adding to: ${widget.goalName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_remainingAmount > 0) ...[
              Text(
                'Remaining to reach target: ${CurrencyFormatter.format(_remainingAmount)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(
                'Target already reached! Additional contributions will exceed your goal.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Contribution Amount',
                prefixIcon: Icon(Icons.attach_money),
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }

                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid positive amount';
                }

                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 8),
            if (_remainingAmount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _amountController.text = _remainingAmount.toString();
                    },
                    child: const Text('Add Remaining Amount'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Add'),
        ),
      ],
    );
  }
}