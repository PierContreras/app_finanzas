// data/models/expense_model.dart
import 'package:finanzas_app1/domain/entities/expense_entity.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
  });

  // Convertir de Model a Entity
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      title: title,
      amount: amount,
      date: date,
      categoryId: category, // Mapear category a categoryId en la entidad
      description: description ?? '', // Si description es null, usar string vacío
    );
  }

  // Convertir de Entity a Model
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      category: entity.categoryId, // Mapear categoryId a category en el modelo
      description: entity.description,
    );
  }

  // Convertir a Map para SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'description': description ?? '',
    };
  }

  // Crear desde Map de SharedPreferences
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'Otros',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      description: map['description'] as String?,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description ?? '',
    };
  }

  // Crear desde JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? 'Otros',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      description: json['description']?.toString(),
    );
  }

  // Método para crear una copia con nuevos valores
  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExpenseModel{id: $id, title: $title, amount: $amount, category: $category, date: $date}';
  }
}