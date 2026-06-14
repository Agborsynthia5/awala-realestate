class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // student, landlord, agent, admin
  final bool isVerified;
  final String preferredLanguage;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.preferredLanguage,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'preferred_language': preferredLanguage,
      'avatar_url': avatarUrl,
    };
  }
}
