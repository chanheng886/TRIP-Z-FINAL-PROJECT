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
  final String? profileImage;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.gender,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'Customer'),
      gender: json['gender'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? json['profile_image'] as String?,
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
      if (profileImage != null) 'profileImage': profileImage,
    };
  }

  User copyWith({
    int? id,
    String? username,
    UserRole? role,
    String? gender,
    String? email,
    String? phone,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
