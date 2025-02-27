import 'package:flutter/material.dart';
import '../../../../data/models/expense.dart';
import '../../../../data/models/category.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Expense> expenses;

  const RecentTransactionsList({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No recent transactions',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expenses.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(expense.category),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: Colors.white,
              ),
            ),
            title: Text(expense.title),
            subtitle: Text(DateFormatter.toShortDate(expense.date)),
            trailing: Text(
              CurrencyFormatter.format(expense.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            onTap: () {
              // Navigate to expense details or edit screen
            },
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // This is a simple implementation - you might want to have more consistent mappings
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transportation': return Colors.blue;
      case 'entertainment': return Colors.purple;
      case 'shopping': return Colors.pink;
      case 'utilities': return Colors.teal;
      case 'housing': return Colors.brown;
      case 'health': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transportation': return Icons.directions_car;
      case 'entertainment': return Icons.movie;
      case 'shopping': return Icons.shopping_bag;
      case 'utilities': return Icons.power;
      case 'housing': return Icons.home;
      case 'health': return Icons.medical_services;
      default: return Icons.category;
    }
  }
}