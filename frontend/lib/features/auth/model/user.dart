enum UserRole {
  Customer,
  Admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.Customer,
    );
  }
}

class User {
  final int id;
  final String username;
  final UserRole role;
  final String gender;
  final String email;
  final String phone;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.gender,
    required this.email,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'Customer'),
      gender: json['gender'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role.name,
      'gender': gender,
      'email': email,
      'phone': phone,
    };
  }
}
