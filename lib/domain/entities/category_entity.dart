class CategoryEntity {
  final String id;
  final String name;
  final int color;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryEntity{id: $id, name: $name, color: $color}';
  }

  // Método para crear una copia con nuevos valores
  CategoryEntity copyWith({
    String? id,
    String? name,
    int? color,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}