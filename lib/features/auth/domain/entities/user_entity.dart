class UserEntity {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
