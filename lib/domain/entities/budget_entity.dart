class BudgetEntity {
  final String id;
  final String categoryId;
  final double amount;
  final DateTime month;
  final DateTime createdAt;

  BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BudgetEntity{id: $id, categoryId: $categoryId, amount: $amount, month: $month}';
  }

  // Método para crear una copia con nuevos valores
  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    double? amount,
    DateTime? month,
    DateTime? createdAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}