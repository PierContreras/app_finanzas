import 'package:finanzas_app1/domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final String name;
  final int color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
  });

  // Convertir de Model a Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      color: color,
    );
  }

  // Convertir de Entity a Model
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
    );
  }

  // Convertir a Map para SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  // Crear desde Map de SharedPreferences
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name, color: $color}';
  }

  // Método para crear una copia con nuevos valores
  CategoryModel copyWith({
    String? id,
    String? name,
    int? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}