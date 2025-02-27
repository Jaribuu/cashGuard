import 'dart:convert';

class SavingsGoal {
  final String? id;
  final String title; // Use `title` instead of `name`
  final double targetAmount;
  final double currentAmount;
  final DateTime createdDate;
  final DateTime targetDate;
  final String? notes;
  final bool isCompleted;

  SavingsGoal({
    this.id,
    required this.title, // Use `title` instead of `name`
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdDate,
    required this.targetDate,
    this.notes,
    this.isCompleted = false,
  });

  // Get progress percentage
  double get progressPercentage => (currentAmount / targetAmount) * 100;

  // Check if goal is overdue
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);

  // Get remaining amount
  double get remainingAmount => targetAmount - currentAmount;

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdDate,
    DateTime? targetDate,
    String? notes,
    bool? isCompleted,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdDate: createdDate ?? this.createdDate,
      targetDate: targetDate ?? this.targetDate,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate']),
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate']),
      notes: map['notes'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory SavingsGoal.fromJson(String source) => SavingsGoal.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SavingsGoal(id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, createdDate: $createdDate, targetDate: $targetDate, notes: $notes, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SavingsGoal &&
        other.id == id &&
        other.title == title &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.createdDate == createdDate &&
        other.targetDate == targetDate &&
        other.notes == notes &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    targetAmount.hashCode ^
    currentAmount.hashCode ^
    createdDate.hashCode ^
    targetDate.hashCode ^
    notes.hashCode ^
    isCompleted.hashCode;
  }
}