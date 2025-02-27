import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/savings_goal.dart';
import '../data_sources/local/database_helper.dart';
import '../../core/error/exceptions.dart';

class SavingsRepository {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  // Table name
  static const String tableName = 'savings_goals';

  // Stream controllers for reactive programming
  final _savingsGoalStreamController = StreamController<List<SavingsGoal>>.broadcast();

  Stream<List<SavingsGoal>> get savingsGoalsStream => _savingsGoalStreamController.stream;

  SavingsRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  // Get all savings goals
  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    try {
      final rows = await _dbHelper.queryAllRows(tableName);
      final goals = rows.map((row) => SavingsGoal.fromMap(row)).toList();
      _savingsGoalStreamController.add(goals);
      return goals;
    } catch (e) {
      throw DatabaseException('Failed to fetch savings goals: ${e.toString()}');
    }
  }

  // Get active savings goals
  Future<List<SavingsGoal>> getActiveSavingsGoals() async {
    try {
      final rows = await _dbHelper.queryWithCondition(
        tableName,
        'isCompleted = ?',
        [0],
      );
      return rows.map((row) => SavingsGoal.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch active savings goals: ${e.toString()}');
    }
  }

  // Get completed savings goals
  Future<List<SavingsGoal>> getCompletedSavingsGoals() async {
    try {
      final rows = await _dbHelper.queryWithCondition(
        tableName,
        'isCompleted = ?',
        [1],
      );
      return rows.map((row) => SavingsGoal.fromMap(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch completed savings goals: ${e.toString()}');
    }
  }

  // Get savings goal by ID
  Future<SavingsGoal?> getSavingsGoalById(String id) async {
    try {
      final rows = await _dbHelper.queryWithCondition(
        tableName,
        'id = ?',
        [id],
      );

      if (rows.isEmpty) return null;
      return SavingsGoal.fromMap(rows.first);
    } catch (e) {
      throw DatabaseException('Failed to fetch savings goal by id: ${e.toString()}');
    }
  }

  // Add new savings goal
  Future<SavingsGoal> addSavingsGoal(SavingsGoal goal) async {
    try {
      final newGoal = goal.copyWith(id: _uuid.v4());
      await _dbHelper.insert(tableName, newGoal.toMap());
      await _refreshSavingsGoals();
      return newGoal;
    } catch (e) {
      throw DatabaseException('Failed to add savings goal: ${e.toString()}');
    }
  }

  // Update existing savings goal
  Future<SavingsGoal> updateSavingsGoal(SavingsGoal goal) async {
    try {
      if (goal.id == null) {
        throw ValidationException('Savings goal ID cannot be null for update operation');
      }

      await _dbHelper.update(tableName, goal.toMap(), 'id');
      await _refreshSavingsGoals();

      // Check if goal is completed
      if (goal.currentAmount >= goal.targetAmount && !goal.isCompleted) {
        final completedGoal = goal.copyWith(isCompleted: true);
        await _dbHelper.update(tableName, completedGoal.toMap(), 'id');
        await _refreshSavingsGoals();
        return completedGoal;
      }

      return goal;
    } catch (e) {
      throw DatabaseException('Failed to update savings goal: ${e.toString()}');
    }
  }

  // Add funds to a savings goal
  Future<SavingsGoal> addFundsToGoal(String goalId, double amount) async {
    try {
      final goal = await getSavingsGoalById(goalId);
      if (goal == null) {
        throw ValidationException('Savings goal not found');
      }

      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );

      return await updateSavingsGoal(updatedGoal);
    } catch (e) {
      throw DatabaseException('Failed to add funds to savings goal: ${e.toString()}');
    }
  }

  // Delete savings goal
  Future<bool> deleteSavingsGoal(String id) async {
    try {
      if (id.isEmpty) {
        throw ValidationException('Savings goal ID cannot be empty');
      }

      final rowsAffected = await _dbHelper.delete(tableName, 'id', id);
      await _refreshSavingsGoals();
      return rowsAffected > 0;
    } catch (e) {
      throw DatabaseException('Failed to delete savings goal: ${e.toString()}');
    }
  }

  // Get total current savings across all goals
  Future<double> getTotalCurrentSavings() async {
    try {
      final goals = await getAllSavingsGoals();
      return goals.fold<double>(0.0, (sum, goal) => sum + goal.currentAmount);
    } catch (e) {
      throw DatabaseException('Failed to calculate total savings: ${e.toString()}');
    }
  }

  // Get total target savings across all active goals
  Future<double> getTotalTargetSavings() async {
    try {
      final goals = await getActiveSavingsGoals();
      return goals.fold<double>(0.0, (sum, goal) => sum + goal.targetAmount);
    } catch (e) {
      throw DatabaseException('Failed to calculate total target savings: ${e.toString()}');
    }
  }

  // Get overall savings progress percentage
  Future<double> getOverallSavingsProgress() async {
    try {
      final current = await getTotalCurrentSavings();
      final target = await getTotalTargetSavings();

      if (target == 0) return 0.0;
      return (current / target) * 100;
    } catch (e) {
      throw DatabaseException('Failed to calculate overall savings progress: ${e.toString()}');
    }
  }

  // Helper method to refresh savings goals stream
  Future<void> _refreshSavingsGoals() async {
    final goals = await getAllSavingsGoals();
    _savingsGoalStreamController.add(goals);
  }

  // Dispose resources
  void dispose() {
    _savingsGoalStreamController.close();
  }
}