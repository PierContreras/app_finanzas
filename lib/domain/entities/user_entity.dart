class UserEntity {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserEntity{id: $id, email: $email, name: $name}';
  }
}