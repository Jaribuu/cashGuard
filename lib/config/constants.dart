import 'package:flutter/material.dart';

// App Colors
class AppColors {
  // Light Theme
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color expenseColor = Color(0xFFF44336);
  static const Color savingsColor = Color(0xFF2196F3);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFFF5F5F5);

  // Dark Theme
  static const Color primaryDarkColor = Color(0xFF388E3C);
  static const Color accentDarkColor = Color(0xFF689F38);
}

// Expense Categories
class ExpenseCategories {
  static const String food = 'Food';
  static const String transportation = 'Transportation';
  static const String entertainment = 'Entertainment';
  static const String education = 'Education';
  static const String housing = 'Housing';
  static const String utilities = 'Utilities';
  static const String health = 'Health';
  static const String shopping = 'Shopping';
  static const String other = 'Other';

  static List<String> all = [
    food,
    transportation,
    entertainment,
    education,
    housing,
    utilities,
    health,
    shopping,
    other,
  ];

  static IconData getIconForCategory(String category) {
    switch (category) {
      case food: return Icons.restaurant;
      case transportation: return Icons.directions_bus;
      case entertainment: return Icons.movie;
      case education: return Icons.school;
      case housing: return Icons.home;
      case utilities: return Icons.flash_on;
      case health: return Icons.healing;
      case shopping: return Icons.shopping_cart;
      case other: return Icons.category;
      default: return Icons.category;
    }
  }

  static Color getColorForCategory(String category) {
    switch (category) {
      case food: return Colors.orange;
      case transportation: return Colors.blue;
      case entertainment: return Colors.purple;
      case education: return Colors.indigo;
      case housing: return Colors.brown;
      case utilities: return Colors.yellow[700]!;
      case health: return Colors.red;
      case shopping: return Colors.pink;
      case other: return Colors.grey;
      default: return Colors.grey;
    }
  }
}

// App Text
class AppText {
  static const String appName = 'Student Budget Tracker';
  static const String welcome = 'Welcome to Student Budget Tracker';
  static const String expenses = 'Expenses';
  static const String budget = 'Budget';
  static const String savings = 'Savings';
  static const String settings = 'Settings';
  static const String addExpense = 'Add Expense';
  static const String editExpense = 'Edit Expense';
  static const String addBudget = 'Set Budget';
  static const String addSavingsGoal = 'Add Savings Goal';
}