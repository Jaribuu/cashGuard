import 'dart:convert';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final bool isDefault;
  final bool isVisible;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.isDefault = false,
    this.isVisible = true,
  });

  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    bool? isDefault,
    bool? isVisible,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'isDefault': isDefault ? 1 : 0,
      'isVisible': isVisible ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
      icon: IconData(
        map['iconCodePoint'],
        fontFamily: map['iconFontFamily'],
        fontPackage: map['iconFontPackage'],
      ),
      isDefault: map['isDefault'] == 1,
      isVisible: map['isVisible'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) => Category.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color, icon: $icon, isDefault: $isDefault, isVisible: $isVisible)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.icon == icon &&
        other.isDefault == isDefault &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    color.hashCode ^
    icon.hashCode ^
    isDefault.hashCode ^
    isVisible.hashCode;
  }
}