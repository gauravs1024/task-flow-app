import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? orgId;
  final String? role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.orgId,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? orgId, String? role}) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String,
      orgId: orgId ?? json['org_id'] as String?,
      role: role ?? json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      if (orgId != null) 'org_id': orgId,
      if (role != null) 'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? orgId,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      orgId: orgId ?? this.orgId,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, orgId, role];
}
