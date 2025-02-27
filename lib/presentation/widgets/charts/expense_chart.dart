import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/category.dart';

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final DateTime startDate;
  final DateTime endDate;
  final ChartType chartType;

  const ExpenseChart({
    Key? key,
    required this.expenses,
    required this.categories,
    required this.startDate,
    required this.endDate,
    this.chartType = ChartType.pie,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expense data available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    switch (chartType) {
      case ChartType.pie:
        return _buildPieChart(context);
      case ChartType.bar:
        return _buildBarChart(context);
      case ChartType.line:
        return _buildLineChart(context);
      default:
        return _buildPieChart(context);
    }
  }

  Widget _buildPieChart(BuildContext context) {
    final Map<String, double> categoryTotals = {};

    // Calculate totals by category
    for (final expense in expenses) {
      final categoryName = _getCategoryName(expense.category); // Updated to use expense.category instead of categoryId
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + expense.amount;
    }

    // Convert to pie chart sections
    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];

    categoryTotals.forEach((category, amount) {
      final totalExpenses = _getTotalExpenses();
      // Added null check to prevent division by zero
      final percentage = totalExpenses > 0 ? (amount / totalExpenses * 100) : 0;

      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          color: colors[colorIndex % colors.length],
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(
            categoryTotals.length,
                (index) {
              final entry = categoryTotals.entries.elementAt(index);
              return _buildLegendItem(
                entry.key,
                CurrencyFormatter.format(entry.value),
                colors[index % colors.length],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context) {
    // Group expenses by day, week, or month depending on date range
    final Map<String, double> groupedData = {};
    final difference = endDate.difference(startDate).inDays;

    String Function(DateTime) groupingFunction;

    if (difference <= 31) {
      // Daily grouping for ranges up to a month
      groupingFunction = (date) => '${date.day}/${date.month}';
    } else if (difference <= 90) {
      // Weekly grouping for ranges up to 3 months
      groupingFunction = (date) {
        final weekNumber = (date.day / 7).ceil();
        return 'W$weekNumber ${date.month}';
      };
    } else {
      // Monthly grouping for longer ranges
      groupingFunction = (date) => '${date.month}/${date.year}';
    }

    for (final expense in expenses) {
      final group = groupingFunction(expense.date);
      groupedData[group] = (groupedData[group] ?? 0) + expense.amount;
    }

    // Sort the data chronologically
    final sortedKeys = groupedData.keys.toList()..sort();
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: groupedData[key]!,
              color: Theme.of(context).primaryColor,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    CurrencyFormatter.formatCompact(value),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < sortedKeys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        sortedKeys[value.toInt()],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          gridData: const FlGridData(
            show: true,
            horizontalInterval: 1,
            drawHorizontalLine: true,
            drawVerticalLine: false,
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    // Group expenses by date
    final Map<DateTime, double> dateMap = {};

    for (final expense in expenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      dateMap[date] = (dateMap[date] ?? 0) + expense.amount;
    }

    // Convert to sorted list of entries
    final sortedEntries = dateMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Create spots for the line chart
    final List<FlSpot> spots = List.generate(
      sortedEntries.length,
          (index) => FlSpot(index.toDouble(), sortedEntries[index].value),
    );

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    CurrencyFormatter.formatCompact(value),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedEntries.length) {
                    final date = sortedEntries[index].key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.grey, width: 1),
              left: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _getTotalExpenses() {
    if (expenses.isEmpty) return 0;
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  String _getCategoryName(String categoryId) {
    // Updated to use the new Category model
    try {
      final category = categories.firstWhere(
            (cat) => cat.id == categoryId,
        orElse: () => Category(
          id: categoryId,
          name: 'Unknown',
          color: Colors.grey,
          icon: Icons.help_outline,
        ),
      );
      return category.name;
    } catch (e) {
      return 'Unknown';
    }
  }
}

enum ChartType { pie, bar, line }