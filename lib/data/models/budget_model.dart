import 'package:finanzas_app1/domain/entities/budget_entity.dart';

class BudgetModel {
  final String id;
  final String categoryId;
  final double amount;
  final DateTime month;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.createdAt,
  });

  // Convertir de Model a Entity
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      categoryId: categoryId,
      amount: amount,
      month: month,
      createdAt: createdAt,
    );
  }

  // Convertir de Entity a Model
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      month: entity.month,
      createdAt: entity.createdAt,
    );
  }

  // Convertir a Map para SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'month': month.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Crear desde Map de SharedPreferences
  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      amount: (map['amount'] as num).toDouble(),
      month: DateTime.fromMillisecondsSinceEpoch(map['month'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BudgetModel{id: $id, categoryId: $categoryId, amount: $amount, month: $month}';
  }

  // Método para crear una copia con nuevos valores
  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amount,
    DateTime? month,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}