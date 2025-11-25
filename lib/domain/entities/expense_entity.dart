// domain/entities/expense_entity.dart
class ExpenseEntity {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String description;

  ExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.description,
  });

  // Getter para compatibilidad con código existente
  String get category => categoryId;

  // Getter para compatibilidad con código existente
  String get categoryName => categoryId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExpenseEntity{id: $id, title: $title, amount: $amount, categoryId: $categoryId, date: $date}';
  }
}