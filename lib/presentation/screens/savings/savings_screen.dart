import 'package:flutter/material.dart';
import '../../../data/models/savings_goal.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import './widgets/savings_goal_card.dart';
import './widgets/add_savings_goal_dialog.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  late SavingsRepository _savingsRepository;
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _savingsRepository = SavingsRepository();
    _loadSavingsGoals();
  }

  Future<void> _loadSavingsGoals() async {
    setState(() => _isLoading = true);
    try {
      final goals = await _savingsRepository.getAllSavingsGoals();
      setState(() {
        _savingsGoals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load savings goals: ${e.toString()}')),
      );
    }
  }

  Future<void> _addSavingsGoal() async {
    final result = await showDialog<SavingsGoal>(
      context: context,
      builder: (context) => const AddSavingsGoalDialog(),
    );

    if (result != null) {
      try {
        await _savingsRepository.addSavingsGoal(result);
        _loadSavingsGoals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add savings goal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _editSavingsGoal(SavingsGoal goal) async {
    final result = await showDialog<SavingsGoal>(
      context: context,
      builder: (context) => AddSavingsGoalDialog(goal: goal),
    );

    if (result != null) {
      try {
        await _savingsRepository.updateSavingsGoal(result);
        _loadSavingsGoals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update savings goal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteSavingsGoal(SavingsGoal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'), // Use `title`
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _savingsRepository.deleteSavingsGoal(goal.id!); // Ensure `id` is non-null
        _loadSavingsGoals();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Savings goal deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete savings goal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _addContribution(SavingsGoal goal, double amount) async {
    try {
      final updated = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      await _savingsRepository.updateSavingsGoal(updated);
      _loadSavingsGoals();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${CurrencyFormatter.format(amount)} to ${goal.title}')), // Use `title`
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add contribution: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavingsGoals,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadSavingsGoals,
        child: _savingsGoals.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.savings,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No savings goals yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addSavingsGoal,
                child: const Text('Add Savings Goal'),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _savingsGoals.length,
          itemBuilder: (context, index) {
            final goal = _savingsGoals[index];
            return SavingsGoalCard(
              goal: goal,
              onEdit: () => _editSavingsGoal(goal),
              onDelete: () => _deleteSavingsGoal(goal),
              onAddContribution: (amount) => _addContribution(goal, amount),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSavingsGoal,
        child: const Icon(Icons.add),
        tooltip: 'Add Savings Goal',
      ),
    );
  }
}