import 'package:flutter/material.dart';
import '../../../../data/models/savings_goal.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import './add_contribution_dialog.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(double) onAddContribution;

  const SavingsGoalCard({
    Key? key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    required this.onAddContribution,
  }) : super(key: key);

  double get _progressPercentage {
    if (goal.targetAmount == 0) return 0;
    return (goal.currentAmount / goal.targetAmount) * 100;
  }

  bool get _isCompleted {
    return goal.currentAmount >= goal.targetAmount;
  }

  int _daysRemaining(BuildContext context) {
    final now = DateTime.now();
    final difference = goal.targetDate.difference(now);
    return difference.inDays;
  }

  Color get _progressColor {
    if (_isCompleted) return Colors.green;
    if (_progressPercentage >= 75) return Colors.green.shade600;
    if (_progressPercentage >= 50) return Colors.amber.shade700;
    if (_progressPercentage >= 25) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _isCompleted
                  ? Colors.green.shade100
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isCompleted ? Icons.check_circle : Icons.savings,
                      color: _isCompleted ? Colors.green : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      goal.title, // Use `title` instead of `name`
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          CurrencyFormatter.format(goal.targetAmount),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Current',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          CurrencyFormatter.format(goal.currentAmount),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _isCompleted ? Colors.green : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${_progressPercentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _progressColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goal.targetAmount == 0 ? 0 : goal.currentAmount / goal.targetAmount,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: _progressColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Target date info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Date',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          DateFormatter.toShortDate(goal.targetDate), // Use `toShortDate`
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Days Remaining',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _isCompleted
                              ? 'Completed!'
                              : '${_daysRemaining(context)} days',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isCompleted
                                ? Colors.green
                                : _daysRemaining(context) < 7
                                ? Colors.red
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Goal notes (if any)
                if (goal.notes != null && goal.notes!.isNotEmpty) ...[
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      goal.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final amount = await showDialog<double>(
                          context: context,
                          builder: (context) => AddContributionDialog(
                            goalName: goal.title, // Use `title` instead of `name`
                            currentAmount: goal.currentAmount,
                            targetAmount: goal.targetAmount,
                          ),
                        );

                        if (amount != null && amount > 0) {
                          onAddContribution(amount);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Contribution'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCompleted ? Colors.grey : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}