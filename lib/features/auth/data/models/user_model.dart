import '../../domain/entities/user_entity.dart';

class UserModel {
  final int id;
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String role;
  final String createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      password: json['password'] as String? ?? '',
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: (json['role'] as String?) ?? 'user',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': role,
      'created_at': createdAt,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      role: role,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
