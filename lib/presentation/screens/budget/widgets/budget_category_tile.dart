import 'package:flutter/material.dart';
import '../../../../data/models/category.dart';
import '../../../../core/utils/currency_formatter.dart';

class BudgetCategoryTile extends StatelessWidget {
  final Category category;
  final double allocated;
  final double spent;

  const BudgetCategoryTile({
    Key? key,
    required this.category,
    required this.allocated,
    required this.spent,
  }) : super(key: key);

  double get _percentUsed {
    if (allocated == 0) return 0;
    return (spent / allocated) * 100;
  }

  Color get _progressColor {
    if (_percentUsed >= 100) return Colors.red;
    if (_percentUsed >= 75) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${spent.toStringAsFixed(1)}/${allocated.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _percentUsed / 100,
              color: _progressColor,
              backgroundColor: Colors.grey.shade200,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_percentUsed.toStringAsFixed(1)}% used',
                  style: TextStyle(
                    color: _progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Remaining: ${CurrencyFormatter.format(allocated - spent)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}