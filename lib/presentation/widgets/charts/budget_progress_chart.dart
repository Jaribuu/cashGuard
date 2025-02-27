import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/category.dart';
import '../../../data/models/budget.dart';

class BudgetProgressChart extends StatelessWidget {
  final List<Budget> budgets;
  final List<Category> categories;
  final Map<String, double> expensesByCategory;
  final BudgetChartType chartType;

  const BudgetProgressChart({
    Key? key,
    required this.budgets,
    required this.categories,
    required this.expensesByCategory,
    this.chartType = BudgetChartType.linear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return const Center(
        child: Text(
          'No budget data available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    switch (chartType) {
      case BudgetChartType.linear:
        return _buildLinearChart(context);
      case BudgetChartType.circular:
        return _buildCircularChart(context);
      case BudgetChartType.detailed:
        return _buildDetailedView(context);
      default:
        return _buildLinearChart(context);
    }
  }

  Widget _buildLinearChart(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: budgets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final budget = budgets[index];
        final categoryId = budget.category ?? '';
        final spent = expensesByCategory[categoryId] ?? 0;
        final progress = budget.amount > 0 ? spent / budget.amount : 0.0;
        final isOverBudget = progress > 1.0;

        return _buildBudgetProgressItem(
          context,
          budget,
          spent,
          progress,
          isOverBudget,
        );
      },
    );
  }

  Widget _buildBudgetProgressItem(
      BuildContext context,
      Budget budget,
      double spent,
      double progress,
      bool isOverBudget,
      ) {
    final theme = Theme.of(context);
    final categoryId = budget.category ?? '';
    final categoryName = _getCategoryName(categoryId);
    final category = _getCategory(categoryId);

    Color progressColor;
    if (isOverBudget) {
      progressColor = Colors.red;
    } else if (progress > 0.9) {
      progressColor = Colors.orange;
    } else {
      progressColor = category.color;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget.amount)}',
              style: TextStyle(
                fontSize: 14,
                color: isOverBudget ? Colors.red : theme.textTheme.bodyMedium?.color,
                fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: isOverBudget ? 1.0 : progress,
            minHeight: 10,
            backgroundColor: theme.dividerColor,
            color: progressColor,
          ),
        ),
        if (isOverBudget)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${((progress - 1) * 100).toStringAsFixed(1)}% over budget',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCircularChart(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: budgets.map((budget) {
        final categoryId = budget.category ?? '';
        final spent = expensesByCategory[categoryId] ?? 0;
        final progress = budget.amount > 0 ? spent / budget.amount : 0.0;
        final isOverBudget = progress > 1.0;

        final category = _getCategory(categoryId);
        Color progressColor;
        if (isOverBudget) {
          progressColor = Colors.red;
        } else if (progress > 0.9) {
          progressColor = Colors.orange;
        } else {
          progressColor = category.color;
        }

        return SizedBox(
          width: 150,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: isOverBudget ? 1.0 : progress,
                      strokeWidth: 10,
                      backgroundColor: Theme.of(context).dividerColor,
                      color: progressColor,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isOverBudget ? Colors.red : null,
                        ),
                      ),
                      if (isOverBudget)
                        const Icon(
                          Icons.warning,
                          color: Colors.red,
                          size: 18,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getCategoryName(categoryId),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget.amount)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailedView(BuildContext context) {
    final sortedBudgets = List<Budget>.from(budgets);
    sortedBudgets.sort((a, b) {
      final spentA = expensesByCategory[a.category ?? ''] ?? 0;
      final spentB = expensesByCategory[b.category ?? ''] ?? 0;
      final percentA = a.amount > 0 ? spentA / a.amount : 0;
      final percentB = b.amount > 0 ? spentB / b.amount : 0;
      return percentB.compareTo(percentA);
    });

    final theme = Theme.of(context);
    final totalBudget = _getTotalBudget();
    final totalSpent = _getTotalSpent();
    final totalSpentPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0;

    return Column(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Budget',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(totalBudget),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Spent',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(totalSpent),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(totalBudget - totalSpent),
                      style: TextStyle(
                        fontSize: 16,
                        color: totalBudget < totalSpent ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: totalBudget > 0
                      ? (totalSpent / totalBudget > 1.0 ? 1.0 : totalSpent / totalBudget)
                      : 0.0,
                  minHeight: 8,
                  backgroundColor: theme.dividerColor,
                  color: totalBudget < totalSpent ? Colors.red : theme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalSpentPercentage.toStringAsFixed(1)}% of total budget spent',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Budget Details by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedBudgets.length,
          separatorBuilder: (context, index) => Divider(
            color: theme.dividerColor,
            height: 32,
          ),
          itemBuilder: (context, index) {
            final budget = sortedBudgets[index];
            final categoryId = budget.category ?? '';
            final spent = expensesByCategory[categoryId] ?? 0;
            final progress = budget.amount > 0 ? spent / budget.amount : 0.0;
            final isOverBudget = progress > 1.0;

            return _buildDetailedBudgetItem(
              context,
              budget,
              spent,
              progress,
              isOverBudget,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailedBudgetItem(
      BuildContext context,
      Budget budget,
      double spent,
      double progress,
      bool isOverBudget,
      ) {
    final theme = Theme.of(context);
    final categoryId = budget.category ?? '';
    final categoryName = _getCategoryName(categoryId);
    final category = _getCategory(categoryId);

    Color progressColor;
    if (isOverBudget) {
      progressColor = Colors.red;
    } else if (progress > 0.9) {
      progressColor = Colors.orange;
    } else {
      progressColor = category.color;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isOverBudget)
              const Icon(
                Icons.warning,
                color: Colors.red,
                size: 18,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget: ${CurrencyFormatter.format(budget.amount)}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            Text(
              'Spent: ${CurrencyFormatter.format(spent)}',
              style: TextStyle(
                fontSize: 14,
                color: isOverBudget ? Colors.red : null,
                fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: isOverBudget ? 1.0 : progress,
            minHeight: 10,
            backgroundColor: theme.dividerColor,
            color: progressColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: isOverBudget ? Colors.red : theme.textTheme.bodySmall?.color,
                fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isOverBudget)
              Text(
                '${CurrencyFormatter.format(spent - budget.amount)} over budget',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Text(
                '${CurrencyFormatter.format(budget.amount - spent)} remaining',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // In BudgetProgressChart
  String _getCategoryName(String categoryId) {
    try {
      final category = categories.firstWhere(
            (cat) => cat.id == categoryId,
        orElse: () => Category(
          id: categoryId,
          name: 'Unknown',
          color: Colors.grey, // Provide a default color
          icon: Icons.category, // Provide a default icon
        ),
      );
      return category.name;
    } catch (e) {
      return 'Unknown';
    }
  }

  Category _getCategory(String categoryId) {
    try {
      return categories.firstWhere(
            (cat) => cat.id == categoryId,
        orElse: () => Category(
          id: categoryId,
          name: 'Unknown',
          color: Colors.grey, // Provide a default color
          icon: Icons.category, // Provide a default icon
        ),
      );
    } catch (e) {
      return Category(
        id: categoryId,
        name: 'Unknown',
        color: Colors.grey, // Provide a default color
        icon: Icons.category, // Provide a default icon
      );
    }
  }

  double _getTotalBudget() {
    if (budgets.isEmpty) return 0.0;
    return budgets.fold(0, (sum, budget) => sum + budget.amount);
  }

  double _getTotalSpent() {
    double total = 0;
    for (final budget in budgets) {
      final categoryId = budget.category ?? '';
      total += expensesByCategory[categoryId] ?? 0;
    }
    return total;
  }
}

enum BudgetChartType { linear, circular, detailed }