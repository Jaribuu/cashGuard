import 'package:flutter/material.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/expenses/expense_list_screen.dart';
import '../presentation/screens/expenses/add_expense_list.dart';
import '../presentation/screens/budget/budget_screen.dart';
import '../presentation/screens/savings/savings_screen.dart';

class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route names
  static const String home = '/';
  static const String expenseList = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String budget = '/budget';
  static const String savings = '/savings';

  // Route definitions
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    expenseList: (context) => const ExpenseListScreen(),
    addExpense: (context) => const AddExpenseScreen(),
    budget: (context) => const BudgetScreen(),
    savings: (context) => const SavingsScreen(),
  };
}