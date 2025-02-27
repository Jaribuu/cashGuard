import 'dart:convert';
import 'categoryBudget.dart';


class Budget {
  final String? id;
  final String category;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<CategoryBudget> categoryBudgets;

  Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.categoryBudgets = const [],
  });

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      isActive: map['isActive'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Budget.fromJson(String source) => Budget.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Budget(id: $id, category: $category, amount: $amount, startDate: $startDate, endDate: $endDate, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Budget &&
        other.id == id &&
        other.category == category &&
        other.amount == amount &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    category.hashCode ^
    amount.hashCode ^
    startDate.hashCode ^
    endDate.hashCode ^
    isActive.hashCode;
  }
}