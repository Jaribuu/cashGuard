import 'package:flutter/material.dart';
import 'dart:convert';

class CategoryBudget {
  final String categoryId;
  final double amount;

  CategoryBudget({
    required this.categoryId,
    required this.amount,
  });

  // Creates a copy of the CategoryBudget with updated fields
  CategoryBudget copyWith({
    String? categoryId,
    double? amount,
  }) {
    return CategoryBudget(
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
    );
  }

  // Converts the CategoryBudget object to a Map
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'amount': amount,
    };
  }

  // Creates a CategoryBudget object from a Map
  factory CategoryBudget.fromMap(Map<String, dynamic> map) {
    return CategoryBudget(
      categoryId: map['categoryId'],
      amount: map['amount'],
    );
  }

  // Converts the CategoryBudget object to a JSON string
  String toJson() => json.encode(toMap());

  // Creates a CategoryBudget object from a JSON string
  factory CategoryBudget.fromJson(String source) =>
      CategoryBudget.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CategoryBudget(categoryId: $categoryId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryBudget &&
        other.categoryId == categoryId &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return categoryId.hashCode ^ amount.hashCode;
  }
}